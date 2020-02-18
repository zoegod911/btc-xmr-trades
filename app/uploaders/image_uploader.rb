require 'image_processing/mini_magick'

class ImageUploader < Shrine
  include ImageProcessing::MiniMagick

  plugin :determine_mime_type
  plugin :remove_attachment
  plugin :store_dimensions
  plugin :derivatives

  Attacher.derivatives do |original|
   magick = ImageProcessing::MiniMagick.source(original).saver(quality: 99)
   
   thumb = magick.resize_to_limit!(125, 125)
   thumb = ImageProcessing::MiniMagick.source(thumb).strip!

   checkout = magick.resize_to_limit!(400, 400)
   checkout = ImageProcessing::MiniMagick.source(checkout).strip!

   { thumb: thumb, checkout: checkout }
 end

end
