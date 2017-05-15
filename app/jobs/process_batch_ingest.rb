require 'ostruct'

class ProcessBatchIngest
  extend DRI::MetadataBehaviour
  extend DRI::AssetBehaviour

  @queue = :process_batch_ingest

  def self.auth_url(user, url)
    "#{url}?user_email=#{user.email}&user_token=#{user.authentication_token}"
  end

  def self.perform(user_id, collection_id, ingest_json)
    ingest_batch = JSON.parse(ingest_json)

    user = UserGroup::User.find(user_id)
    collection = DRI::Batch.find(collection_id, cast: true)

    download_path = File.join(Settings.downloads.directory, collection_id)
    FileUtils.mkdir_p(download_path)

    ingest_metadata = ingest_batch['metadata']

    if ingest_metadata['object_id'].present?
      # metadata ingest was successful so only ingest missing assets
      object = DRI::Batch.find(ingest_metadata['object_id'], cast: true)
    else
      metadata = retrieve_files(download_path, [ingest_metadata])[0]
      object = ingest_metadata(collection, user, metadata)
    end

    ingest_files = ingest_batch['files']
    assets = retrieve_files(download_path, ingest_files)

    ingest_assets(user, object, assets)
  end

  def self.ingest_assets(user, object, assets)
    assets.each do |asset|
      @generic_file = DRI::GenericFile.new(id: DRI::Noid::Service.new.mint)
      @generic_file.batch = object
      @generic_file.apply_depositor_metadata(user)
      @generic_file.preservation_only = 'true' if asset[:label] == 'preservation'

      original_file_name = File.basename(asset[:path])
      file_name = "#{@generic_file.id}_#{original_file_name}"

      version = ingest_file(asset[:path], object, 'content', file_name)
      if version < 1
        saved = false
      else
        saved = true
        url = Rails.application.routes.url_helpers.url_for(
          controller: 'assets',
          action: 'download',
          object_id: object.id,
          id: @generic_file.id,
          version: version
        )
        DRI::Asset::Actor.new(@generic_file, user).create_external_content(
                  url,
                  'content', file_name
                )
      end
    
      message = if saved
                  { status_code: 'COMPLETED',
                    file_location: Rails.application.routes.url_helpers.object_file_path(object, @generic_file) }
                else
                  { status_code: 'FAILED' }
                end

      send_message(auth_url(user, asset[:callback_url]), message)
    end
  end

  def self.ingest_metadata(collection, user, metadata)
    xml = load_xml(file_data(metadata[:path]))
    object = create_object(collection, user, xml)

    if object.valid? && object.save
      create_reader_group if object.collection?

      DRI::Object::Actor.new(object, user).version_and_record_committer

      preservation = Preservation::Preservator.new(object)
      preservation.preserve(true, true, ['descMetadata','properties'])

      message = { status_code: 'COMPLETED',
                  file_location: Rails.application.routes.url_helpers.catalog_path(object) }
    else
      message = { status_code: 'FAILED', file_location: "error:#{object.errors.full_messages.inspect}" }
    end

    send_message(auth_url(user, metadata[:callback_url]), message)
    object
  end

  def self.ingest_file(file_path, object, datastream, filename)
    filedata = OpenStruct.new
    filedata.path = file_path
    
    current_version = object.object_version || 1
    object_version = (current_version.to_i+1).to_s

    object.object_version = object_version
    
    # Update object version
    begin
      object.save
    rescue ActiveRecord::ActiveRecordError => e
      logger.error "Could not update object version number for #{object.id} to version #{object_version}"
      return -1
    end

    begin
      create_file(object, filedata, datastream, nil, filename)
    rescue StandardError => e
      Rails.logger.error "Could not save the asset file #{filedata.path} for #{object.id} to #{datastream}: #{e.message}"
      return -1
    end

    preservation = Preservation::Preservator.new(object)
    preservation.preserve_assets([filename],[])

    object.object_version.to_i
  end

  def self.create_object(collection, user, xml)
    standard = metadata_standard_from_xml(xml)

    object = DRI::Batch.with_standard standard
    object.governing_collection = collection
    object.depositor = user.to_s
    object.status = 'draft'
    object.object_version = 1

    set_metadata_datastream(object, xml)
    checksum_metadata(object)

    object
  end

  def self.create_reader_group(object)
    group = UserGroup::Group.new(
      name: object.id.to_s,
      description: "Default Reader group for collection #{object.id}"
    )
    group.reader_group = true
    group.save
  end

  def self.download_url(generic_file)
    Rails.application.routes.url_helpers.url_for controller: 'assets',
             action: 'download', object_id: generic_file.batch.id, id: generic_file.id
  end

  def self.file_data(path)
    file_upload = OpenStruct.new
    file_upload.tempfile = File.new(path)
    file_upload.original_filename = File.basename(path)

    file_upload
  end

  def self.retrieve_files(download_path, files)
    retriever = BrowseEverything::Retriever.new

    downloaded_files = []

    files.each do |file|
      download_location = File.join(download_path, file['download_spec']['file_name'])
      downloaded = 0
      File.open download_location, 'wb' do |dest|
        # Retrieve the file, yielding each chunk to a block
        retriever.retrieve(file['download_spec']) do |chunk, retrieved, total|
          dest.write chunk
          downloaded = retrieved
        end
      end

      download = { label: file['label'], path: download_location, callback_url: file['callback_url'] }
      downloaded_files << download
    end

    downloaded_files
  end

  def self.send_message(url, message)
    RestClient.put url, { 'master_file' => message }, content_type: :json, accept: :json
  rescue RestClient::Exception => e
    Rails.logger.error "Error sending callback: #{e}"
  end
end
