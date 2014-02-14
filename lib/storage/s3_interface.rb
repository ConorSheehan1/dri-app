module Storage
  class S3Interface

    def initialize
      AWS::S3::Base.establish_connection!(:server => Settings.S3.server,
                                          :access_key_id => Settings.S3.access_key_id,
                                          :secret_access_key => Settings.S3.secret_access_key)
      AWS::S3::Service.buckets
    end


    # Return the best available surrogate for delivery
    def deliverable_surrogate?(doc, file_doc, list = nil)
      deliverable_surrogate = nil
      deliverable_surrogates = []

      bucket = doc.id.sub('dri:', '')
      generic_file = file_doc.id.sub('dri:', '')

      object_type = doc["object_type_ssm"][0]
      files = list_files(bucket)

      if list == nil
        unless Settings.surrogates[object_type.downcase.to_sym].nil?
          Settings.surrogates[object_type.downcase.to_sym].each do |surrogate_type|
            filename = "dri:#{generic_file}_#{surrogate_type}"
            deliverable_surrogate = files.find { |e| /#{filename}/ =~ e }
            break unless deliverable_surrogate.nil?
          end
        end

        return deliverable_surrogate
      else
        unless Settings.surrogates[object_type.downcase.to_sym].nil?
          Settings.surrogates[object_type.downcase.to_sym].each do |surrogate_type|
            filename = "dri:#{generic_file}_#{surrogate_type}"
            deliverable_surrogates << files.find { |e| /#{filename}/ =~ e }
          end
        end

        return deliverable_surrogates
      end

    end

    # Get a hash of all surrogates for an object
    def get_surrogates(doc, file_doc)

      bucket = doc.id.sub('dri:', '')
      generic_file = file_doc.id.sub('dri:','')

      files = list_files(bucket)

      @surrogates_hash = {}
      files.each do |file|
        begin
          if file.match(/dri:#{generic_file}_([-a-zA-z0-9]*)\..*/)
            url = AWS::S3::S3Object.url_for(file, bucket, :authenticated => true, :expires_in => 60 * 30)
            @surrogates_hash[$1] = url
          end
        rescue Exception => e
          logger.debug "Problem getting url for file #{file} : #{e.to_s}"
        end
      end

      return @surrogates_hash
    end

    def surrogate_url( doc, file_doc, name )

      bucket = doc.id.sub('dri:', '')
      generic_file = file_doc.id.sub('dri:', '')
      files = list_files(bucket)

      filename = "dri:#{generic_file}_#{name}"
      surrogate = files.find { |e| /#{filename}/ =~ e }

      unless surrogate.blank?
        begin
          url = AWS::S3::S3Object.url_for(surrogate, bucket, :authenticated => true, :expires_in => 60 * 30)
        rescue Exception => e
          logger.debug "Problem getting url for file #{file} : #{e.to_s}"
        end
      end

      return url
    end

    # Create bucket
    def create_bucket(bucket)
      begin
        AWS::S3::Bucket.create(bucket)
      rescue Exception => e
        logger.error "Could not create Storage Bucket #{bucket}: #{e.to_s}"
        return false
      end
      return true
    end

    # Delete bucket
    def delete_bucket(bucket)
      begin
        AWS::S3::Bucket.delete(bucket, :force => true)
      rescue Exception => e
        logger.error "Could not delete Storage Bucket #{bucket}: #{e.to_s}"
        return false
      end
      return true
    end

    # Save Surrogate File
    def store_surrogate(object_id, outputfile, filename)
      bucket = object_id.sub('dri:', '')
      begin
        AWS::S3::S3Object.store(filename, open(outputfile), bucket)
      rescue Exception  => e
        logger.error "Problem saving Surrogate file #{filename} : #{e.to_s}"
      end
    end

    # Save arbitrary file
    def store_file(file, filename, bucket)
      begin
        AWS::S3::S3Object.store(filename, open(file), bucket, :access => :public_read)
      rescue Exception => e
        logger.error "Problem saving file #{filename} : #{e.to_s}"
        raise
      end
    end

    # Get an authenticated short-duration url for a file
    def get_link_for_surrogate(bucket, file)
      begin
        url = AWS::S3::S3Object.url_for(file, bucket, :authenticated => true, :expires_in => 60 * 30)
      rescue Exception => e
        logger.error "Problem getting link for file #{file} : #{e.to_s}"
      end
      return url
    end

    # Get link for arbitrary file
    def get_link_for_file(bucket, file)
      begin
        url = AWS::S3::S3Object.url_for(file, bucket, :authenticated => false)
      rescue Exception => e
        logger.error "Problem getting link for file #{file} : #{e.to_s}"
      end
      return url
    end

    def close
      AWS::S3::Base.disconnect!()
    end

    def list_files(bucket)
      files = []
      begin
        bucketobj = AWS::S3::Bucket.find(bucket)
        bucketobj.each do |fileobj|
          files << fileobj.key
        end
      rescue
        logger.debug "Problem listing files in bucket #{bucket}"
      end

      files
    end

  end

end
