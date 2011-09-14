# encoding: utf-8
require 'mime/types'

class SiteAssetUploader < CarrierWave::Uploader::Base

  # Choose what kind of storage to use for this uploader:
  storage :file

  def store_dir
    "assets/#{model._parent.site_id}/#{model._parent.name}/#{mounted_as}/#{model.id}"
  end    
  
  before :store, :remember_cache_id
  after :store, :delete_tmp_dir

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
     %w(jpg jpeg gif png pdf mp4 m4v ogv webm flv)
   end
    
  # Override the filename of the uploaded files:
   def filename
     "#{model.name}.#{file.extension}" if original_filename
   end    

   def image?(sanitized_file)    
     types = mime_types(sanitized_file)
     if types.empty?
       false
      else
        types.first.content_type.include? 'image'
      end
   end
   
   
   private
   
    def mime_types(file)
      MIME::Types.of(file.extension)
    end
end
