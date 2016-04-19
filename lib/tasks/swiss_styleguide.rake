require 'fileutils'

namespace :swiss_styleguide do |t|
  desc "Imports Swiss styleguide from git submodule"
  task import: :environment do
    print 'Importing styleguide ...'
    origin = './styleguide/build/'
    js_origin = origin + 'js/'
    css_origin = origin + 'css/'
    images_origin = origin + 'img/'
    fonts_origin = origin + 'fonts'

    dest = './vendor/assets/'
    js_dest = dest + 'javascripts/'
    css_dest = dest + 'stylesheets/'
    images_dest = dest + 'images/'
    images_dest_public = 'public/img/'
    fonts_dest = './public/'

    FileUtils.cp css_origin+'admin.css', css_dest+'styleguide.css'
    FileUtils.cp css_origin+'print.css', css_dest+'styleguide_print.css'
    FileUtils.cp css_origin+'vendors.css', css_dest+'styleguide_vendors.css'
    FileUtils.cp_r css_origin+'images', css_dest+'images'

    FileUtils.cp js_origin+'main.js', js_dest+'styleguide.js'
    FileUtils.cp js_origin+'main.min.js', js_dest+'styleguide.min.js'
    FileUtils.cp js_origin+'vendors.min.js', js_dest+'styleguide_vendors.min.js'
    FileUtils.cp js_origin+'polyfills.min.js', js_dest+'styleguide_polyfills.min.js'
    FileUtils.cp_r images_origin, images_dest
    FileUtils.cp_r images_origin, images_dest_public
    FileUtils.cp_r fonts_origin, fonts_dest
  end

  desc "Updates Swiss styleguide git submodule"
  task update_submodule: :environment do
    print "Updating styleguide ...\n"
    print `cd styleguide && git pull origin master`
  end

  desc 'Updates Swiss styleguide git submodule and imports it'
  task update_and_import: :environment do
    Rake::Task['swiss_styleguide:update_submodule'].invoke
    Rake::Task['swiss_styleguide:import'].invoke
  end
end
