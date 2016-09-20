require 'spec_helper'

describe ObjectsController do
  include Devise::TestHelpers

  describe 'destroy' do
    
    before(:each) do
      @login_user = FactoryGirl.create(:admin)
      sign_in @login_user
    end

    after(:each) do
      @login_user.delete
    end

    it 'should delete a draft object' do
      @collection = FactoryGirl.create(:collection)
   
      @object = FactoryGirl.create(:sound) 
      @object[:status] = "draft"
      @object.save

      @collection.governed_items << @object

      expect {
        delete :destroy, :id => @object.id
      }.to change { ActiveFedora::Base.exists?(@object.id) }.from(true).to(false)

      @collection.reload
      @collection.delete
    end

    it 'should not delete a published object' do
      @collection = FactoryGirl.create(:collection)
   
      @object = FactoryGirl.create(:sound) 
      @object[:status] = "published"
      @object.save

      @collection.governed_items << @object

      delete :destroy, :id => @object.id

      expect(ActiveFedora::Base.exists?(@object.id)).to be true

      @collection.reload
      @collection.delete
    end

  end

  describe 'status' do

    before(:each) do
      @login_user = FactoryGirl.create(:admin)
      sign_in @login_user
      @collection = FactoryGirl.create(:collection)
   
      @object = FactoryGirl.create(:sound) 
      @object[:status] = "draft"
      @object.save

      @object2 = FactoryGirl.create(:sound)
      @object2[:status] = "draft"
      @object2.save

      @collection.governed_items << @object
      @collection.governed_items << @object2

      @collection.save    
    end

    after(:each) do
      @object2.delete
      @object.delete if ActiveFedora::Base.exists?(@object.id)
      @collection.delete if ActiveFedora::Base.exists?(@collection.id)
      @login_user.delete
    end

    it 'should set an object status' do
      post :status, :id => @object.id, :status => "reviewed"

      @object.reload

      expect(@object.status).to eql("reviewed")

      post :status, :id => @object.id, :status => "draft"

      @object.reload

      expect(@object.status).to eql("draft")
    end

    it 'should not set the status of a published object' do
      @object.status = "published"
      @object.save

      post :status, :id => @object.id, :status => "draft"

      @object.reload

      expect(@object.status).to eql("published") 
    end

    it 'should mint a doi for an update of mandatory fields' do
      DoiConfig = OpenStruct.new({ :username => "user", :password => "password", :prefix => '10.5072', :base_url => "http://repository.dri.ie", :publisher => "Digital Repository of Ireland" })
      Settings.doi.enable = true

      @object.status = "published"
      @object.save
      DataciteDoi.create(object_id: @object.id)

      Sufia.queue.should_receive(:push).with(an_instance_of(MintDoiJob)).once
      params = {}
      params[:batch] = {}
      params[:batch][:title] = ["A modified title"]
      params[:batch][:read_users_string] = "public"
      params[:batch][:edit_users_string] = @login_user.email
      put :update, :id => @object.id, :batch => params[:batch]

      DataciteDoi.where(object_id: @object.id).first.delete
      DoiConfig = nil
      Settings.doi.enable = false
    end

    it 'should not mint a doi for no update of mandatory fields' do
      DoiConfig = OpenStruct.new({ :username => "user", :password => "password", :prefix => '10.5072', :base_url => "http://repository.dri.ie", :publisher => "Digital Repository of Ireland" })
      Settings.doi.enable = true

      @object.status = "published"
      @object.save
      DataciteDoi.create(object_id: @object.id)

      Sufia.queue.should_not_receive(:push).with(an_instance_of(MintDoiJob))
      params = {}
      params[:batch] = {}
      params[:batch][:title] = ["An Audio Title"]
      params[:batch][:read_users_string] = "public"
      params[:batch][:edit_users_string] = @login_user.email
      put :update, :id => @object.id, :batch => params[:batch]

      DataciteDoi.where(object_id: @object.id).first.delete
      DoiConfig = nil
      Settings.doi.enable = false
    end

  end

  describe "read only is set" do

      before(:each) do
        Settings.reload_from_files(
          Rails.root.join(fixture_path, "settings-ro.yml").to_s
        )
        @login_user = FactoryGirl.create(:admin)
        sign_in @login_user
        @collection = FactoryGirl.create(:collection)
        @object = FactoryGirl.create(:sound) 

        request.env["HTTP_REFERER"] = catalog_path(@collection.id)
      end

      after(:each) do
        @collection.delete if ActiveFedora::Base.exists?(@collection.id)
        @login_user.delete

        Settings.reload_from_files(
          Rails.root.join("config", "settings.yml").to_s
        )
      end

      it 'should not allow object creation' do
        @request.env["CONTENT_TYPE"] = "multipart/form-data"

        @file = fixture_file_upload("/valid_metadata.xml", "text/xml")
        class << @file
          # The reader method is present in a real invocation,
          # but missing from the fixture object for some reason (Rails 3.1.1)
          attr_reader :tempfile
        end

        post :create, batch: { governing_collection: @collection.id }, metadata_file: @file
        expect(flash[:error]).to be_present
      end

      it 'should not allow object updates' do
        params = {}
        params[:batch] = {}
        params[:batch][:title] = ["An Audio Title"]
        params[:batch][:read_users_string] = "public"
        params[:batch][:edit_users_string] = @login_user.email
        put :update, :id => @object.id, :batch => params[:batch]

        expect(flash[:error]).to be_present
      end

  end

  describe 'get_objects' do

    before(:each) do
      @login_user = FactoryGirl.create(:admin)
      sign_in @login_user

      @object = FactoryGirl.create(:sound)
      @object.status = 'published'
      @object.save
    end

    after(:each) do
      @object.delete
      @login_user.delete
    end

    it 'should assign valid JSON to @list' do
      request.env["HTTP_ACCEPT"] = 'application/json'
      
      post :index, objects: [{ 'pid' => @object.id }]
      list = controller.instance_variable_get(:@list)
      expect { JSON.parse(list.to_json) }.not_to raise_error
    end

    it 'should contain the metadata fields' do
      request.env["HTTP_ACCEPT"] = 'application/json'
      
      post :index, objects: [{ 'pid' => @object.id }]
      list = controller.instance_variable_get(:@list)
      json = JSON.parse(list.to_json)
      
      expect(json.first['metadata']['title']).to eq(@object.title)
      expect(json.first['metadata']['description']).to eq(@object.description)
      expect(json.first['metadata']['contributor']).to eq(@object.contributor)
    end

    it 'should only return the requested fields' do
      request.env["HTTP_ACCEPT"] = 'application/json'
      
      post :index, objects: [{ 'pid' => @object.id }], metadata: ['title', 'description']
      list = controller.instance_variable_get(:@list)
      json = JSON.parse(list.to_json)
      
      expect(json.first['metadata']['title']).to eq(@object.title)
      expect(json.first['metadata']['description']).to eq(@object.description)
      expect(json.first['metadata']['contributor']).to be nil
    end

    it 'should include assets and surrogates' do
      @gf = DRI::GenericFile.new
      @gf.apply_depositor_metadata(@login_user)
      @gf.batch = @object
      @gf.save

      storage = StorageService.new
      storage.create_bucket(@object.id)
      storage.store_surrogate(@object.id, File.join(fixture_path, "SAMPLEA.mp3"), "#{@gf.id}_mp3.mp3")

      request.env["HTTP_ACCEPT"] = 'application/json'
      post :index, objects: [{ 'pid' => @object.id }]
      list = controller.instance_variable_get(:@list)
      expect(list.first).to include('files')
      expect(list.first['files'].first).to include('masterfile')
      expect(list.first['files'].first).to include('mp3')
    end
  end
  
end
