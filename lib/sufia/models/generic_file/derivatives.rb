module Sufia
  module GenericFile
    module Derivatives
      extend ActiveSupport::Concern

      included do
        include Hydra::Derivatives

        makes_derivatives do |obj|
          case obj.mime_type
          when *pdf_mime_types
            obj.transform_datastream :content,
              { :thumbnail => {size: "338x493", datastream: 'thumbnail'} }
          when *audio_mime_types
            obj.transform_datastream :content,
              { :mp3 => {format: 'mp3', datastream: 'mp3'},
                :ogg => {format: 'ogg', datastream: 'ogg'} }, processor: :audio
          when *video_mime_types
            obj.transform_datastream :content,
              { :webm => {format: "webm", datastream: 'webm'},
                :mp4 => {format: "mp4", datastream: 'mp4'} }, processor: :video
          when *image_mime_types
            obj.transform_datastream :content,
              { :small => {size: "75x75", datastream: 'thumbnail_small'},
                :medium => {size: "200x150", datastream: 'thumbnail_medium'},
                :large => {size: "400x300", datastream: 'thumbnail_large'},
                :lightbox => {size: "600x450", datastream: 'lightbox_format'},
                :full => {size: "100%", datastream: 'full_size_web_format'},
                :crop16_9_small => {size: "200", crop: "100%x56.25%+0+0", gravity: "Center", datastream: 'crop16_9_thumbnail_small'},
                :crop16_9_medium => {size: "228", crop: "100%x56.25%+0+0", gravity: "Center", datastream: 'crop16_9_thumbnail_medium'} }
          end
        end
      end

    end
  end
end
