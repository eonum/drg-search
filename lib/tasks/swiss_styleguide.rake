require 'fileutils'

namespace :swiss_styleguide do |t|
  desc "Imports swiss styleguide from git submodule"
  task import: :environment do
    origin = './styleguide/build/'
    js_origin = origin + 'js/'
    css_origin = origin + 'css/'
    images_origin = origin + 'img/'
    fonts_origin = origin + 'fonts'

    dest = './vendor/assets/'
    js_dest = dest + 'javascripts/'
    css_dest = dest + 'stylesheets/'
    images_dest = dest + 'images/'
    fonts_dest = './public/'

    FileUtils.cp css_origin+'admin.css', css_dest+'styleguide.css'
    FileUtils.cp_r css_origin+'images', css_dest+'images'

    FileUtils.cp js_origin+'main.js', js_dest+'styleguide.js'
    FileUtils.cp js_origin+'main.min.js', js_dest+'styleguide.min.js'
    FileUtils.cp_r images_origin, images_dest
    FileUtils.cp_r fonts_origin, fonts_dest
  end

end
