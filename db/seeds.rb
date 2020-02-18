require "#{Rails.root}/db/seeders/category_generator"
require "#{Rails.root}/db/seeders/offering_generator"


CategoryGenerator.generate!
OfferingGenerator.generate!
