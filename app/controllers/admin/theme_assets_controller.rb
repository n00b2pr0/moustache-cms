class Admin::ThemeAssetsController < AdminBaseController
  include MoustacheCms::AssetCache  
  
  load_resource :theme_collection
  load_and_authorize_resource :theme_asset, :through => :theme_collection  

  respond_to :html, :xml, :json

  # GET /admin/theme_assets 
  def index
    respond_with(:admin, @theme_collection, @theme_assets) do |format|
      format.html { redirect_to [:admin, @theme_collection] }
    end

  end  

  # GET /admin/theme_assets/new 
  def new
    respond_with(:admin, @theme_collection, @theme_asset) 
  end
    
  # GET /admin/theme_assets/1/edit
  def show
    respond_with(:admin, @theme_collection, @theme_asset) do |format|
      format.html { render :edit }
    end
  end
  
  # POST /admin/theme_assets
  def create
    creator_updator_set_id @theme_asset    
    try_theme_asset_cache 
    respond_with(:admin, @theme_collection, @theme_asset) do |format| 
      if @theme_asset.save
        format.html { redirect_to [:admin, @theme_collection, :theme_assets], :notice => "Successfully created the theme asset #{@theme_asset.name}"  }
      end
    end
  end    
  
  # GET /admin/theme_asset/1/edit
  def edit
    respond_with(:admin, @theme_collection, @theme_asset)
  end
   
  # PUT /admin/theme_assets/1 
  def update   
    @theme_asset.updator_id = current_admin_user.id
    @theme_asset.name = params[:theme_asset][:name]
    if params[:theme_asset_file_content]
      md5_update(params[:theme_asset_file_content]) 
    else
      change_name_md5
    end
    respond_with(:admin, @theme_collection, @theme_asset) do |format|
      if @theme_asset.update_file_content(params[:theme_asset_file_content]) && @theme_asset.update_attributes(params[:theme_asset]) 
        format.html { redirect_to [:admin, @theme_collection, :theme_assets], :notice => "Successfully updated the theme asset #{@theme_asset.name}" }
      end
    end
  end                                                            
  
  def destroy
    @theme_asset.destroy
    flash[:notice] = "Successfully deleted the theme asset #{@theme_asset.name}"
    respond_with(:admin, @theme_collection, @theme_asset)
  end   
  
  private
    def try_theme_asset_cache 
      if !params[:theme_asset][:asset_cache].empty? && params[:theme_asset][:asset].nil?
        set_from_cache(:cache_name => params[:theme_asset][:asset_cache], :asset => @theme_asset)
      end
    end

    def md5_update(data)
      md5 = ::Digest::MD5.hexdigest(data)
      @theme_asset.filename_md5 = "#{@theme_asset.name}-#{md5}.#{@theme_asset.asset.file.extension}"
    end

    def change_name_md5
      if @theme_asset.name_changed?
        @theme_asset.filename_md5_old = @theme_asset.filename_md5_was
        old_name_split = @theme_asset.filename_md5_was.split('-')
        hash_ext = old_name_split.pop
        hash = hash_ext.split('.').shift
        @theme_asset.filename_md5 = "#{@theme_asset.name.split('.').first}-#{hash}.#{@theme_asset.asset.file.extension}"
      end
    end
end
