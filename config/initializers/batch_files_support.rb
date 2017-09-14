require 'dri/model_support/files'
require 'validators'

DRI::ModelSupport::Files.module_eval do
  def add_file(file, dsid='content', original_file_name)
    @mime_type = Validators.file_type(file.path)
    pass_validation = false

    begin
      pass_validation = Validators.validate_file(file.path, @mime_type)
    rescue Exception => e
      Rails.logger.error "Error validating file: #{e.message}"
      return false
    end

    return false unless pass_validation

    @generic_file = DRI::GenericFile.new(noid: DRI::Noid::Service.new.mint)
    @generic_file.digital_object = self
    filename = "#{@generic_file.noid}_#{original_file_name}"
      
    # Apply depositor metadata, other permissions currently unused for generic files
    ingest_user = UserGroup::User.find_by_email(self.depositor)    
    @generic_file.apply_depositor_metadata(self.depositor)

    @actor = DRI::Asset::Actor.new(@generic_file, ingest_user)

    current_version = self.object_version || '1'
    object_version = (current_version.to_i+1).to_s
    self.object_version = object_version

    # Update object version
    begin
      self.save!
    rescue ActiveRecord::ActiveRecordError => e
      logger.error "Could not update object version number for #{self.noid} to version #{object_version}"
      raise Exceptions::InternalError
    end
            
    preservation = Preservation::Preservator.new(self)
    preservation.preserve_assets([filename],[])
    
    url = Rails.application.routes.url_helpers.url_for(
      controller: 'assets',
      action: 'download',
      object_id: self.noid,
      id: @generic_file.noid,
      version: object_version
    )

    if @actor.create_external_content(file, dsid, filename, @mime_type)
      true
    else
      Rails.logger.error "Error saving file: #{e.message}"
      false
    end
  end
end
