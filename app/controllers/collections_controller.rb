# Controller for the Collection model
#

class CollectionsController < CatalogController

  before_filter :authenticate_user!, :only => [:index, :create, :new, :show, :edit, :update]

  # Shows list of user's collections
  #
  def index
    unless current_user.is_admin?
      @mycollections = Batch.find(:depositor => current_user.to_s)
    else
      @mycollections = Batch.all
    end

    respond_to do |format|
      format.html
      format.json { 
        collectionhash = []
        @mycollections.each do |collection|
          collectionhash << { :id => collection.id,
                               :title => collection.title,
                               :description => collection.description,
                               :publisher => collection.publisher,
                               :objectcount => collection.governed_items.count + collection.items.count }.to_json
        end
        @mycollections = collectionhash
      }
    end
  end

  # Creates a new model.
  #
  def new
    enforce_permissions!("create", Batch)
    @collection = Batch.new
    
    # configure default permissions
    @collection.apply_depositor_metadata(current_user.to_s)
    @collection.manager_users_string=current_user.to_s
    @collection.discover_groups_string="public"
    @collection.read_groups_string="public"
    @collection.private_metadata="0"
    @collection.master_file="1"
    @collection.object_type = ["Collection"]

    respond_to do |format|
      format.html
    end
  end

  # Edits an existing model.
  #
  def edit
    enforce_permissions!("edit",params[:id])
    @collection = retrieve_object!(params[:id])

    respond_to do |format|
      format.html
    end
  end

  # Retrieves an existing model.
  #
  def show
    enforce_permissions!("show",params[:id])
    @collection = retrieve_object!(params[:id])

    respond_to do |format|
      format.html  
      format.json  {
        @response = {}
        @response[:id] = @collection.pid
        @response[:title] = @collection.title
        @response[:description] = @collection.description
        @response[:publisher] = @collection.publisher
        @response[:objectcount] = @collection.governed_items.count + @collection.items.count
      }
    end
  end

  # Updates the attributes of an existing model.
  #
  def update
    update_object_permission_check(params[:batch][:manager_groups_string],params[:batch][:manager_users_string], params[:id])

    @collection = retrieve_object!(params[:id])

    #For sub collections will have to set a governing_collection_id
    #Create a sub collections controller?

    set_access_permissions(:batch)

    if !valid_permissions? 
      flash[:error] = t('dri.flash.error.not_updated', :item => params[:id])
    else
      @collection.update_attributes(params[:batch])
      #Apply private_metadata & properties to each DO/Subcollection within this collection
      flash[:notice] = t('dri.flash.notice.updated', :item => params[:id])
    end

    respond_to do |format|
      format.html  { render :action => "edit" }
    end
  end

  # Creates a new model using the parameters passed in the request.
  #
  def create
    enforce_permissions!("create",Batch)
    
    set_access_permissions(:batch)

    @collection = Batch.new
    @collection.update_attributes(params[:batch])
    @collection.object_type = ["Collection"]

    # depositor is not submitted as part of the form
    @collection.depositor = current_user.to_s

    if !valid_permissions?
      flash[:alert] = t('dri.flash.error.not_created')
      render :action => :new
      return 
    end

    respond_to do |format|
      if @collection.save

        format.html { flash[:notice] = t('dri.flash.notice.collection_created')
            redirect_to :controller => "collections", :action => "show", :id => @collection.id }
        format.json {
          @response = {}
          @response[:id] = @collection.pid
          @response[:title] = @collection.title
          @response[:description] = @collection.description
          @response[:publisher] = @collection.publisher
          render(:json => @response, :status => :created)
        }
      else
        format.html {
          flash[:alert] = @collection.errors.messages.values.to_s
          render :action => :new
        }
        format.json { render(:json => @collection.errors.messages.values.to_s) }
        raise Exceptions::BadRequest, t('dri.views.exceptions.invalid_collection')
      end
    end
  end

  def destroy
    enforce_permissions!("edit",params[:id])

    if current_user.is_admin?
      @collection = retrieve_object!(params[:id])
  
      @collection.governed_items.each do |object|
        object.delete
      end
      @collection.reload
      @collection.delete
    end

    respond_to do |format|
      format.html { flash[:notice] = t('dri.flash.notice.collection_deleted')
      redirect_to :controller => "collections", :action => "index" }
    end

  end

  private

    def valid_permissions?
      if ((params[:batch][:private_metadata].blank? || params[:batch][:private_metadata]==UserGroup::Permissions::INHERIT_METADATA) ||
       (params[:batch][:master_file].blank? || params[:batch][:master_file]==UserGroup::Permissions::INHERIT_MASTERFILE) ||
       (params[:batch][:read_groups_string].blank? && params[:batch][:read_users_string].blank?) ||
       (params[:batch][:manager_users_string].blank? && params[:batch][:manager_groups_string].blank? && params[:batch][:edit_users_string].blank? && params[:batch][:edit_groups_string].blank?))
         return false
      else
         return true
      end
   end

end

