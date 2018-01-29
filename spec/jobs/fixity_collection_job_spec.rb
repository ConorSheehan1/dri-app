require 'rails_helper'

describe "FixityCollectionJob" do
  
  before(:each) do
    @tmp_assets_dir = Dir.mktmpdir
    Settings.dri.files = @tmp_assets_dir

    @login_user = FactoryGirl.create(:collection_manager)

    @collection = FactoryGirl.create(:collection)
    
    @object = FactoryGirl.create(:sound)
  
    @collection.governed_items << @object
    @collection.save

    @subcollection = FactoryGirl.create(:collection)
    @subcollection.governing_collection = @collection
    @subcollection.save

    @subcollection2 = FactoryGirl.create(:collection)
    @subcollection2.governing_collection = @collection
    @subcollection2.save
  end

  after(:each) do
    @collection.delete
    @login_user.delete

    FileUtils.remove_dir(@tmp_assets_dir, force: true)
  end
  
  describe "perform" do
    it "should trigger jobs for subcollections" do
      expect(Resque).to receive(:enqueue).exactly(3).times
      FixityCollectionJob.perform(@collection.id, @login_user.id)
    end
  end

end