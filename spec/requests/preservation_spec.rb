require "rails_helper"

RSpec.describe "Preservation actions", :type => :request do

  context 'Adding a licence' do

    before(:each) do
      @tmp_assets_dir = Dir.mktmpdir
      Settings.dri.files = @tmp_assets_dir

      @login_user = FactoryBot.create(:admin)
      sign_in @login_user

      @collection = FactoryBot.create(:collection)
    end

    after(:each) do
      @collection.delete

      @login_user.delete
      FileUtils.remove_dir(@tmp_assets_dir, force: true)
    end
    

    it "creates a new AIP when a licence is added" do
      expect(aip_version(@collection.id)).to eq 1

      put "/collections/#{@collection.id}/licences", batch: { licence: "New licence" }
      
      expect(aip_version(@collection.id)).to eq 2
    end

  end
end
