require 'rails_helper'

describe ObjectsController do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @tmp_assets_dir = Dir.mktmpdir
    Settings.dri.files = @tmp_assets_dir
  end

  after(:each) do
    FileUtils.remove_dir(@tmp_assets_dir, force: true)
  end

  describe 'destroy' do
    
    before(:each) do
      @login_user = FactoryGirl.create(:collection_manager)
      sign_in @login_user
    end

    after(:each) do
      @login_user.delete
    end

    it 'should delete a draft object' do
      collection = FactoryGirl.create(:collection)
      collection.depositor = User.find_by_email(@login_user.email).to_s
      collection.manager_users_string=User.find_by_email(@login_user.email).to_s
      collection.discover_groups_string="public"
      collection.read_groups_string="registered"
      collection.creator = [@login_user.email]

      object = FactoryGirl.create(:sound) 
      object[:status] = "draft"
      object.depositor=User.find_by_email(@login_user.email).to_s
      object.manager_users_string=User.find_by_email(@login_user.email).to_s
      object.creator = [@login_user.email]  
  
      object.save

      collection.governed_items << object

      expect {
        delete :destroy, :id => object.noid
      }.to change { DRI::Identifier.object_exists?(object.noid) }.from(true).to(false)

      collection.reload
      collection.destroy
    end

    it 'should not delete a published object for non-admin' do
      @collection = FactoryGirl.create(:collection)
      @collection.depositor = User.find_by_email(@login_user.email).to_s
      @collection.manager_users_string=User.find_by_email(@login_user.email).to_s
      @collection.discover_groups_string="public"
      @collection.read_groups_string="registered"
      @collection.creator = [@login_user.email]

      @object = FactoryGirl.create(:sound) 
      @object[:status] = "published"
      @object.save

      @collection.governed_items << @object

      delete :destroy, :id => @object.noid

      expect(DRI::Identifier.object_exists?(@object.noid)).to be true

      @collection.reload
      @collection.destroy
    end

    it 'should delete a published object for an admin' do
      sign_out @login_user
      @admin_user = FactoryGirl.create(:admin)
      sign_in @admin_user

      @collection = FactoryGirl.create(:collection)
   
      @object = FactoryGirl.create(:sound) 
      @object[:status] = "published"
      @object.save

      @collection.governed_items << @object

      delete :destroy, :id => @object.noid

      expect(DRI::Identifier.object_exists?(@object.noid)).to be false

      @collection.reload
      @collection.destroy
    end

  end

  describe 'create' do

    before(:each) do
      @login_user = FactoryGirl.create(:admin)
      sign_in @login_user
      @collection = FactoryGirl.create(:collection)
    end

    after(:each) do
      @collection.destroy if DRI::Identifier.object_exists?(@collection)
      @login_user.delete
    end

    it 'returns a bad request if no schema' do
      request.env["HTTP_ACCEPT"] = 'application/json'
      @request.env["CONTENT_TYPE"] = "multipart/form-data"

      @file = fixture_file_upload("/invalid_metadata_noschema.xml", "text/xml")
      class << @file
        # The reader method is present in a real invocation,
        # but missing from the fixture object for some reason (Rails 3.1.1)
        attr_reader :tempfile
      end

      post :create, digital_object: { governing_collection: @collection.noid }, metadata_file: @file 
      expect(flash[:error]).to match(/Validation Errors/)
      expect(response.status).to eq(400)
    end

    it 'returns a bad request if schema invalid' do
      request.env["HTTP_ACCEPT"] = 'application/json'
      @request.env["CONTENT_TYPE"] = "multipart/form-data"

      @file = fixture_file_upload("/invalid_metadata_schemaparse.xml", "text/xml")
      class << @file
        # The reader method is present in a real invocation,
        # but missing from the fixture object for some reason (Rails 3.1.1)
        attr_reader :tempfile
      end

      post :create, digital_object: { governing_collection: @collection.noid }, metadata_file: @file 
      expect(flash[:error]).to match(/Validation Errors/)
      expect(response.status).to eq(400)
    end

  end


  describe 'status' do

    before(:each) do
      @login_user = FactoryGirl.create(:collection_manager)
      sign_in @login_user
      @collection = FactoryGirl.create(:collection)
      @collection.depositor = User.find_by_email(@login_user.email).to_s
      @collection.manager_users_string=User.find_by_email(@login_user.email).to_s
      @collection.discover_groups_string="public"
      @collection.read_groups_string="registered"
      @collection.creator = [@login_user.email]
   
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
      @collection.destroy if DRI::Identifier.object_exists?(@collection.noid)
      @login_user.delete
    end

    it 'should set an object status' do
      post :status, :id => @object.noid, :status => "reviewed"

      @object.reload

      expect(@object.status).to eql("reviewed")

      post :status, :id => @object.noid, :status => "draft"

      @object.reload

      expect(@object.status).to eql("draft")
    end

    it 'should not set the status of a published object' do
      @object.status = "published"
      @object.save

      post :status, :id => @object.noid, :status => "draft"

      @object.reload

      expect(@object.status).to eql("published") 
    end

    it 'should mint a doi for an update of mandatory fields' do
      stub_const(
        'DoiConfig',
        OpenStruct.new(
          { :username => "user",
            :password => "password",
            :prefix => '10.5072',
            :base_url => "http://repository.dri.ie",
            :publisher => "Digital Repository of Ireland" }
            )
        )
      Settings.doi.enable = true

      @object.status = "published"
      @object.save
      DataciteDoi.create(object_id: @object.noid)

      expect(DRI.queue).to receive(:push).with(an_instance_of(MintDoiJob)).once
      params = {}
      params[:digital_object] = {}
      params[:digital_object][:title] = ["A modified title"]
      params[:digital_object][:read_users_string] = "public"
      params[:digital_object][:edit_users_string] = @login_user.email
      put :update, :id => @object.noid, :digital_object => params[:digital_object]

      DataciteDoi.where(object_id: @object.noid).first.delete
      Settings.doi.enable = false
    end

    it 'should not mint a doi for no update of mandatory fields' do
      stub_const(
        'DoiConfig',
        OpenStruct.new(
          { :username => "user",
            :password => "password",
            :prefix => '10.5072',
            :base_url => "http://repository.dri.ie",
            :publisher => "Digital Repository of Ireland" }
            )
        )
      Settings.doi.enable = true

      @object.status = "published"
      @object.save
      DataciteDoi.create(object_id: @object.noid)

      expect(DRI.queue).to_not receive(:push).with(an_instance_of(MintDoiJob))
      params = {}
      params[:digital_object] = {}
      params[:digital_object][:title] = ["An Audio Title"]
      params[:digital_object][:read_users_string] = "public"
      params[:digital_object][:edit_users_string] = @login_user.email
      put :update, :id => @object.noid, :digital_object => params[:digital_object]

      DataciteDoi.where(object_id: @object.noid).first.delete
      Settings.doi.enable = false
    end

  end

  describe "read only is set" do

      before(:each) do
        Settings.reload_from_files(
          Rails.root.join(fixture_path, "settings-ro.yml").to_s
        )
        @tmp_assets_dir = Dir.mktmpdir
        Settings.dri.files = @tmp_assets_dir
        
        @login_user = FactoryGirl.create(:admin)
        sign_in @login_user
        @collection = FactoryGirl.create(:collection)
        @object = FactoryGirl.create(:sound) 

        request.env["HTTP_REFERER"] = catalog_path(@collection.id)
      end

      after(:each) do
        @collection.destroy if DRI::Identifier.object_exists?(@collection.id)
        @login_user.delete
        
        FileUtils.remove_dir(@tmp_assets_dir, force: true)
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

        post :create, digital_object: { governing_collection: @collection.id }, metadata_file: @file
        expect(flash[:error]).to be_present
      end

      it 'should not allow object updates' do
        params = {}
        params[:digital_object] = {}
        params[:digital_object][:title] = ["An Audio Title"]
        params[:digital_object][:read_users_string] = "public"
        params[:digital_object][:edit_users_string] = @login_user.email
        put :update, :id => @object.noid, :digital_object => params[:digital_object]

        expect(flash[:error]).to be_present
      end

  end

  describe "collection is locked" do

      before(:each) do
        @login_user = FactoryGirl.create(:admin)
        sign_in @login_user
        @collection = FactoryGirl.create(:collection)
        @object = FactoryGirl.create(:sound)
        CollectionLock.create(collection_id: @collection.noid)

        request.env["HTTP_REFERER"] = catalog_path(@collection.noid)
      end

      after(:each) do
        CollectionLock.delete_all(collection_id: @collection.noid)
        @collection.destroy if DRI::Identifier.object_exists?(@collection.noid)
        @login_user.delete
      end

      it 'should not allow object creation' do
        @request.env["CONTENT_TYPE"] = "multipart/form-data"

        @file = fixture_file_upload("/valid_metadata.xml", "text/xml")
        class << @file
          # The reader method is present in a real invocation,
          # but missing from the fixture object for some reason (Rails 3.1.1)
          attr_reader :tempfile
        end

        post :create, digital_object: { governing_collection: @collection.noid }, metadata_file: @file
        expect(flash[:error]).to be_present
      end

      it 'should not allow object updates' do
        @object.governing_collection = @collection
        @object.save
        
        params = {}
        params[:digital_object] = {}
        params[:digital_object][:title] = ["An Audio Title"]
        params[:digital_object][:read_users_string] = "public"
        params[:digital_object][:edit_users_string] = @login_user.email
        put :update, :id => @object.noid, :digital_object => params[:digital_object]

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
      @object.destroy
      @login_user.delete
    end

    it 'should assign valid JSON to @list' do
      request.env["HTTP_ACCEPT"] = 'application/json'

      post :index, objects: [{ 'pid' => @object.noid }]
      list = controller.instance_variable_get(:@list)
      expect { JSON.parse(list.to_json) }.not_to raise_error
    end

    it 'should contain the metadata fields' do
      request.env["HTTP_ACCEPT"] = 'application/json'

      post :index, objects: [{ 'pid' => @object.noid }]
      list = controller.instance_variable_get(:@list)
      json = JSON.parse(list.to_json)

      expect(json.first['metadata']['title']).to eq(@object.title)
      expect(json.first['metadata']['description']).to eq(@object.description)
      expect(json.first['metadata']['contributor']).to eq(@object.contributor)
    end

    it 'should only return the requested fields' do
      request.env["HTTP_ACCEPT"] = 'application/json'

      post :index, objects: [{ 'pid' => @object.noid }], metadata: ['title', 'description']
      list = controller.instance_variable_get(:@list)
      json = JSON.parse(list.to_json)

      expect(json.first['metadata']['title']).to eq(@object.title)
      expect(json.first['metadata']['description']).to eq(@object.description)
      expect(json.first['metadata']['contributor']).to be nil
    end

    it 'should include assets and surrogates' do
      @gf = DRI::GenericFile.new
      @gf.apply_depositor_metadata(@login_user)
      @gf.digital_object = @object
      @gf.save

      storage = StorageService.new
      storage.create_bucket(@object.noid)
      storage.store_surrogate(@object.noid, File.join(fixture_path, "SAMPLEA.mp3"), "#{@gf.noid}_mp3.mp3")

      request.env["HTTP_ACCEPT"] = 'application/json'
      post :index, objects: [{ 'pid' => @object.noid }]
      list = controller.instance_variable_get(:@list)

      expect(list.first).to include('files')
      expect(list.first['files'].first).to include('masterfile')
      expect(list.first['files'].first).to include('mp3')
    end
  end
end
