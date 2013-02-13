class RelationshipsController < AssetsController

  def create

    @object = ActiveFedora::Base.find(params[:id], {:cast => true})
    @collection = Collection.find(params[:collection_id])

    @collection.items << @object

    if @collection.save
      respond_to do |format|
        format.html { flash[:notice] = t('dri.flash.notice.added_to_collection')
          redirect_to :controller => "collections", :action => "show", :id => params[:collection_id] }
        format.json { render :json => @collection }
      end
    else
      respond_to do |format|
        format.html {
          flash["alert"] = t('dri.flash.alert.not_added_to_collection') 
          redirect_to :controller => "objects", :action => "edit", :id => params[:id]
        }
        format.json { render :json => @collection.errors}
      end
    end

  end

  def delete
    @object = ActiveFedora::Base.find(params[:id], {:cast => true})
    @collection = Collection.find(params[:collection_id])

    @collection.items.delete(@object)
    
    if @object.save
      respond_to do |format|
        format.html { flash[:notice] = t('dri.flash.notice.removed_from_collection')
        }
        format.json { render :json => @collection }
      end
    else
      respond_to do |format|
        format.html {
          flash["alert"] = t('dri.flash.alert.not_removed_from_collection')
        }
        format.json { render :json => @object.errors}
      end
    end
  
    redirect_to :controller => "collections", :action => "show", :id => params[:collection_id]
  end

end
