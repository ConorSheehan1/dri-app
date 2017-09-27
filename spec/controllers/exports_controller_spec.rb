require 'rails_helper'

describe ExportsController do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @tmp_assets_dir = Dir.mktmpdir
    Settings.dri.files = @tmp_assets_dir
  end

  after(:each) do
    FileUtils.remove_dir(@tmp_assets_dir, force: true)
  end

  describe 'create' do
    
    before(:each) do
      @login_user = FactoryGirl.create(:admin)
      sign_in @login_user
    end

    after(:each) do
      @login_user.delete
    end

    it 'should start an export' do
      @collection = FactoryGirl.create(:collection)
      @request.env['HTTP_REFERER'] = "/collections/#{@collection.noid}/export/new"
            
      expect(Resque).to receive(:enqueue).once
      post :create, id: @collection.noid
    end
  end
end