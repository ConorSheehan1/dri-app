module DRI
  module MetadataBehaviour
    extend ActiveSupport::Concern

    def set_metadata_datastream(object, xml)
      object.update_metadata xml
    end
      
    def checksum_metadata(object)
      if object.attached_files.key?(:descMetadata)
        xml = object.attached_files[:descMetadata].content
        object.metadata_md5 = Checksum.md5_string(xml)
      end
    end

    def load_xml(upload)
      if upload.respond_to?(:original_filename)
        types = MIME::Types.type_for(upload.original_filename)
        if types.blank?
          raise Exceptions::InvalidXML
        end

        if types.first.content_type.eql? 'application/xml'
          xml_upload = upload.tempfile
        end
      else
        xml_upload = upload
      end
        
      begin
        xml_content = xml_upload.respond_to?(:read) ? xml_upload.read : xml_upload
        xml = Nokogiri::XML(xml_content) { |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
      rescue Nokogiri::XML::SyntaxError => e
        raise Exceptions::InvalidXML, e
      end

      standard = metadata_class_from_xml(xml)
      result, @msg = MetadataValidator.valid?(xml, standard)
      raise Exceptions::ValidationErrors, @msg unless result
          
      xml
    end

    def metadata_class_from_xml(xml_text)
      result = nil
      xml = nil

      if xml_text.is_a? Nokogiri::XML::Document
        xml = xml_text
      else
        xml = Nokogiri::XML xml_text
      end

      namespace = xml.namespaces
      root_name = xml.root.name

      if namespace.value?('http://purl.org/dc/elements/1.1/')
       result = 'DRI::Metadata::QualifiedDublinCore'
      elsif namespace.value?('http://www.loc.gov/mods/v3')
        result = 'DRI::Metadata::Mods'
      elsif ((xml.internal_subset != nil && xml.internal_subset.name == 'ead') || namespace.value?('urn:isbn:1-931666-22-9'))
        result = 'DRI::Metadata::EncodedArchivalDescription'
      elsif ['c', 'c01', 'c02', 'c03', 'c04', 'c05', 'c06', 'c07', 'c08', 'c09', 'c10', 'c11', 'c12'].include? root_name
        result = 'DRI::Metadata::EncodedArchivalDescriptionComponent'
      elsif namespace.value?('http://www.loc.gov/MARC21/slim')
        result = 'DRI::Metadata::Marc'
      end

      result
    end

    def metadata_standard_from_xml(xml_text)
      metadata_class = metadata_class_from_xml(xml_text)

      case metadata_class
      when 'DRI::Metadata::QualifiedDublinCore'
        :qdc
      when 'DRI::Metadata::Mods'
        :mods
      when 'DRI::Metadata::EncodedArchivalDescription'
        :ead_collection
      when 'DRI::Metadata::EncodedArchivalDescriptionComponent'
        :ead_component
      when 'DRI::Metadata::Marc'
        :marc
      end
    end
  end
end
