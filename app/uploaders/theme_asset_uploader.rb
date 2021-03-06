# encoding: utf-8
require 'carrierwave/processing/mime_types'

class ThemeAssetUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  # Choose what kind of storage to use for this uploader:
  storage :file

  def store_dir
    if model.new_record?
      "theme_assets/#{model._parent.site_id}/#{model._parent.name}/#{asset_type(model.asset.identifier)}" 
    else 
      "theme_assets/#{model._parent.site_id}/#{model._parent.name}/#{asset_type(model.asset_identifier)}" 
    end
  end
  
  before :store, :remember_cache_id
  after :store, :delete_tmp_dir

  process :set_content_type

  # store! nil's the cache_id after it finishes so we need to remember it for deletition
  def remember_cache_id(new_file)
    @cache_id_was = cache_id
  end
  
  def delete_tmp_dir(new_file)
    # make sure we don't delete other things accidentally by checking the name pattern
    if @cache_id_was.present? && @cache_id_was =~ /\A[\d]{8}\-[\d]{4}\-[\d]+\-[\d]{4}\z/
      if Rails.env == "test"                                            
        FileUtils.rm_rf(File.join(Rails.root, "spec", "tmp", cache_dir, @cache_id_was))  
      else
        FileUtils.rm_rf(File.join(Rails.root, cache_dir, @cache_id_was))
      end
    end
  end             

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
   def extension_white_list
     %w(jpg jpeg gif png css js swf flv eot svg ttf woff otf ico pdf mp4 m4v ogv webm flv)
   end
    
  # Override the filename of the uploaded files:
  def filename
    @name ||= "#{model.name}.#{model.asset.file.extension}"
  end    

   def image?(sanitized_file)    
     types = mime_types(sanitized_file)
     if types.empty?
       false
      else
        types.first.content_type.include? 'image'
      end
   end
  
   def stylesheet?(sanitized_file)
     types = mime_types(sanitized_file)
     if types.empty?
       false
      else
        types.first.content_type.include? 'css'
      end
   end
   
   def javascript?(sanitized_file)
     types = mime_types(sanitized_file)
     if types.empty?
       false
      else
        types.first.content_type.include? 'javascript'
      end
   end

   private
   
    def mime_types(file)
      MIME::Types.of(file.extension)
    end
    
    def asset_type(name)
      sanitized_file = CarrierWave::SanitizedFile.new(name)
      case 
      when stylesheet?(sanitized_file)
        "stylesheets"
      when image?(sanitized_file)
        "images"
      when javascript?(sanitized_file)
        "javascripts"
      when image?(sanitized_file)
        "images"
      else
        "assets"
      end
    end
end
