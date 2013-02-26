# Controller for Digital Objects
#

require 'stepped_forms'

class ObjectsController < ApplicationController
  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  include DRI::Model
  include SteppedForms

  before_filter :authenticate_user!, :only => [:create, :new, :edit, :update]

  # Edits an existing model.
  #
  def edit
    @document_fedora = ActiveFedora::Base.find(params[:id], {:cast => true})
    respond_to do |format|
      format.html
      format.json  { render :json => @document_fedora }
    end
  end

  # Updates the attributes of an existing model.
  #
  def update
    @document_fedora = ActiveFedora::Base.find(params[:id], {:cast => true})
    if params[:dri_model][:governing_collection_id].present?
      collection = Collection.find(params[:dri_model][:governing_collection_id])
      @document_fedora.governing_collection = collection
    end
    @document_fedora.update_attributes(params[:dri_model])

    respond_to do |format|
      flash["notice"] = t('dri.flash.notice.updated', :item => params[:id])
      format.html  { render :action => "edit" }
      format.json  { render :json => @document_fedora }
    end
  end

  # Creates a new audio model using the parameters passed in the request.
  #
  def create
    @supported_types = get_supported_types

    if !session[:ingest][:type].blank?
     @document_fedora = DRI::Model::DigitalObject.construct(session[:ingest][:type].to_sym, params[:dri_model])
    else
      @document_fedora = DRI::Model::DigitalObject.construct(:Audio, params[:dri_model])
    end

    if session[:ingest][:collection]
      collection = Collection.find(session[:ingest][:collection])
      @document_fedora.governing_collection = collection
    end
    if @document_fedora.valid? && @document_fedora.save
      respond_to do |format|
        format.html { flash[:notice] = t('dri.flash.notice.digital_object_ingested')
          redirect_to :controller => "catalog", :action => "show", :id => @document_fedora.id }
        format.json { render :json => @document_fedora }
      end
    else
      respond_to do |format|
        format.html {
          flash["alert"] = @document_fedora.errors.messages.values.to_s
          raise Exceptions::BadRequest, t('dri.views.exceptions.invalid_metadata_input')
          return
        }
        format.json { render :json => @document_fedora.errors}
      end
    end

  end

end

