require "hydra/derivatives/shell_based_processor"
require 'open3'
require 'storage/s3_interface'

Hydra::Derivatives::ShellBasedProcessor.module_eval do

  # Force the Hydra Derivatives processors to save surrogates to CEPH instead of FEDORA datastream
  def encode_datastream(dest_dsid, file_suffix, mime_type, options = '')
        out_file = nil
        output_file = Dir::Tmpname.create(['sufia', ".#{file_suffix}"], Hydra::Derivatives.temp_file_base){}
        source_datastream.to_tempfile do |f|
          self.class.encode(f.path, options, output_file)
        end
        out_file = File.open(output_file, "rb")
        #object.add_file_datastream(out_file.read, :dsid=>dest_dsid, :mimeType=>mime_type)
        Storage::S3Interface.store_surrogate(pid, out_file, dest_dsid+".#{file_suffix}")
        File.unlink(output_file)
  end

end