require 'moab'
require 'preservation/preservation_helpers'

module Preservation
  class Preservator

    include PreservationHelpers

    attr_accessor :base_dir, :object, :version

    def initialize(object)
     self.object = object
     self.version = object.object_version.to_i
    end

    # create_moab_dir
    # Creates MOAB preservation directory structure and saves metadata there
    #
    def create_moab_dirs()
      if File.directory?(manifest_path(self.object.noid, self.version))
        Rails.logger.error("the Moab directory for #{self.object.noid} version #{self.version} already exists")
        raise DRI::Exceptions::InternalError
      end
      make_dir(
        [
          version_path(self.object.noid, self.version),
          metadata_path(self.object.noid, self.version),
          content_path(self.object.noid, self.version)
        ]
      )
    end

    # moabify_datastream
    # Takes two paramenters
    # - name (datastream and file name)
    # - datastream (the value for that key from the datastreams hash
    def moabify_datastream(name, datastream)
      data = datastream.content
      return if data.nil?

      begin
        File.write(File.join(metadata_path(self.object.noid, self.version), "#{name.to_s}.xml"), data)
      rescue StandardError => e
        Rails.logger.error "unable to write datastream: #{e}"
        false
      end
    end


    # moabify_resource
    def moabify_resource
      begin
        File.write(File.join(metadata_path(self.object.noid, self.version), 'resource.rdf'), object.resource.dump(:ttl))
        true
      rescue StandardError => e
        Rails.logger.error "unable to write resource: #{e}"
        false
      end
    end


    # moabify_permissions
    def moabify_permissions
      begin
        File.write(File.join(metadata_path(self.object.noid, self.version), 'permissions.rdf'), object.permissions.inspect )
      rescue StandardError => e
        Rails.logger.error "unable to write permissions: #{e}"
        false
      end
    end


    # preserve
    def preserve(resource=false, permissions=false, datastreams=nil)
      create_moab_dirs()
      dslist = []
      added = []
      deleted = []
      modified = []

      if resource
        saved = moabify_resource
        return false unless saved
        dslist << 'resource.rdf'
      end
      
      if permissions
        saved = moabify_permissions
        return false unless saved
        dslist << 'permissions.rdf'
      end

      if datastreams.present?
        #object.reload # we must refresh the datastreams list
        datastreams.each do |ds|
          if object.attached_files.key?(ds)
            saved = moabify_datastream(ds, object.attached_files[ds])
            return false unless saved
          end
        end
        dslist.push(datastreams.map { |item| item << ".xml" }).flatten!
      end

      if @object.object_version == '1'
        created = create_manifests
        return false unless created
      else
        # metadata files cannot be added or deleted after object creation
        updated = update_manifests({:modified => {'metadata' => dslist}})
        return false unless updated
      end

      true
    end


    # preserve_assets
    def preserve_assets(addfiles, delfiles)
      create_moab_dirs()
      moabify_datastream('properties', object.attached_files['properties'])
      update_manifests({:added => {'content' => addfiles}, deleted: {'content' => delfiles}, modified: {'metadata' => ['properties.xml']}})
    end
    
    # create_manifests
    def create_manifests
      begin
        signature_catalog = Moab::SignatureCatalog.new(digital_object_id: @object.noid, version_id: 0)
        new_version_id = signature_catalog.version_id + 1

        version_inventory = Moab::FileInventory.new(type: 'version', version_id: new_version_id, digital_object_id: @object.noid)
        file_group = Moab::FileGroup.new(:group_id=>'metadata').group_from_directory(Pathname.new(metadata_path(@object.noid, new_version_id)))
        version_inventory.groups << file_group
        file_group = Moab::FileGroup.new(:group_id=>'content').group_from_directory(Pathname.new(content_path(@object.noid, new_version_id)))
        version_inventory.groups << file_group

        version_additions = signature_catalog.version_additions(version_inventory)

        signature_catalog.update(version_inventory, Pathname.new( data_path(@object.noid, new_version_id) ))

        file_inventory_difference = Moab::FileInventoryDifference.new
        file_inventory_difference.compare(Moab::FileInventory.new(), version_inventory)

        signature_catalog.write_xml_file(Pathname.new(manifest_path(@object.noid, new_version_id)))
        version_inventory.write_xml_file(Pathname.new(manifest_path(@object.noid, new_version_id)))
        version_additions.write_xml_file(Pathname.new(manifest_path(@object.noid, new_version_id)))
        file_inventory_difference.write_xml_file(Pathname.new(manifest_path(@object.noid, new_version_id)))

        manifest_inventory = Moab::FileInventory.new(type: 'manifests', digital_object_id: @object.noid, version_id: new_version_id)
        manifest_inventory.groups << Moab::FileGroup.new(group_id: 'manifests').group_from_directory(manifest_path(@object.noid, new_version_id), recursive=false)
        
        manifest_inventory.write_xml_file(Pathname.new(manifest_path(@object.noid, new_version_id)))
      rescue StandardError => e
        Rails.logger.error "unable to create manifests: #{e}"
        return false
      end

      true
    end

    # update_manifests
    # changes: hash with keys :added, :modified and :deleted. Each is an array of filenames (excluding directory paths)
    def update_manifests(changes)
      begin
        last_version_inventory = Moab::FileInventory.new(type: 'version', version_id: self.version.to_i-1, digital_object_id: @object.noid)
        last_version_inventory.parse(Pathname.new(File.join(manifest_path(@object.noid, self.version.to_i-1),'versionInventory.xml')).read)

        @version_inventory = Moab::FileInventory.new(type: 'version', version_id: self.version.to_i-1, digital_object_id: @object.noid)
        @version_inventory.parse(Pathname.new(File.join(manifest_path(@object.noid, self.version.to_i-1),'versionInventory.xml')).read)
        @version_inventory.version_id = @version_inventory.version_id+1

        if changes.key?(:added)
          changes[:added].keys.each do |type|
            path = path_for_type(type)
            
            changes[:added][type].each { |file| moab_add_file_instance(path, file, type) }
          end
        end

        if changes.key?(:modified)
          changes[:modified].keys.each do |type|
            path = path_for_type(type)

            changes[:modified][type].each do |file|
              @version_inventory.groups.find {|g| g.group_id == type.to_s }.remove_file_having_path(file)

              moab_add_file_instance(path, file, type)
            end
          end
        end

        if changes.key?(:deleted)
          changes[:deleted].keys.each do |type|
            path = path_for_type(type)

            changes[:deleted][type].each do |file|
              @version_inventory.groups.find {|g| g.group_id == type.to_s }.remove_file_having_path(file)
            end
          end
        end

        signature_catalog = Moab::SignatureCatalog.new(digital_object_id: @object.noid)
        signature_catalog.parse(Pathname.new(File.join(manifest_path(@object.noid, self.version.to_i-1),'signatureCatalog.xml')).read)
        version_additions = signature_catalog.version_additions(@version_inventory)
        signature_catalog.update(@version_inventory, Pathname.new( data_path(@object.noid, self.version) ))
        file_inventory_difference = Moab::FileInventoryDifference.new
        file_inventory_difference.compare(last_version_inventory, @version_inventory)

        signature_catalog.write_xml_file(Pathname.new(manifest_path(@object.noid, self.version)))
        @version_inventory.write_xml_file(Pathname.new(manifest_path(@object.noid, self.version)))
        version_additions.write_xml_file(Pathname.new(manifest_path(@object.noid, self.version)))
        file_inventory_difference.write_xml_file(Pathname.new(manifest_path(@object.noid, self.version)))

        manifest_inventory = Moab::FileInventory.new(type: 'manifests', digital_object_id: @object.noid, version_id: self.version)
        manifest_inventory.groups << Moab::FileGroup.new(group_id: 'manifests').group_from_directory(manifest_path(@object.noid, self.version), recursive=false)
        manifest_inventory.write_xml_file(Pathname.new(manifest_path(@object.noid, self.version)))
      rescue StandardError => e
        Rails.logger.error "unable to update manifests: #{e}"
        return false
      end

      true

    end


    private

      def make_dir(paths)
        begin
          FileUtils.mkdir_p(paths)
        rescue StandardError => e
          Rails.logger.error "Unable to create MOAB directory #{path}. Error: #{e.message}"
          raise DRI::Exceptions::InternalError
        end
      end

      def moab_add_file_instance(path, file, type)
        file_signature = Moab::FileSignature.new()
        file_signature.signature_from_file(Pathname.new(File.join(path, file)))

        file_instance = Moab::FileInstance.new()
        file_instance.instance_from_file(Pathname.new(File.join(path, file)), Pathname.new(path))

        @version_inventory.groups.find {|g| g.group_id == type.to_s }.add_file_instance(file_signature, file_instance)
      end

      def path_for_type(type)
        if type == 'content'
          content_path(@object.noid, self.version)
        elsif type == 'metadata'
          metadata_path(@object.noid, self.version)
        end
      end

  end
end
