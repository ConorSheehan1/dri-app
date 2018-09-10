shared_context 'collection_manager_user' do
  before(:all) do
    UserGroup::Group.find_or_create_by(
      name: SETTING_GROUP_CM, 
      description: "collection manager test group"
    )
    @login_user = FactoryBot.create(:collection_manager)
  end

  after(:all) do
    UserGroup::Group.find_by(name: SETTING_GROUP_CM).delete
  end
end

shared_context 'tmp_assets' do
  before(:each) do
    @tmp_assets_dir = Dir.mktmpdir
    Settings.dri.files = @tmp_assets_dir
  end

  after(:each) do
    FileUtils.remove_dir(@tmp_assets_dir, force: true)
  end
end

shared_context 'collections_with_items' do |num_collections=2, num_items=1, status='draft'|
  before(:each) do
    @collections = []

    # have to create new user here to grant access to collection
    # otherwise we depend on the context for the user to already exist
    @new_user = FactoryBot.create(:collection_manager)
    sign_in @new_user

    num_collections.times do |i|
      collection = FactoryBot.create(:collection)
      # collection = Collection.new
      collection[:status] = status
      collection[:creator] = [@new_user.to_s]
      collection[:date] = [DateTime.now.strftime("%Y-%m-%d")]
      collection.apply_depositor_metadata(@new_user.to_s)

      # collections must contain items 
      # in order to take up space on the json output!
      # otherwise docs=[], total_pages=0
      num_items.times do |j|
        object = FactoryBot.create(:sound)
        object[:status] = status
        object[:title] = ["Not a Duplicate#{j}"]
        object.apply_depositor_metadata(@new_user.to_s)
        object.save
        collection.governed_items << object
      end

      collection.save
      @collections.push(collection)
    end
  end

  after(:each) do
    @collections.map(&:delete)
  end
end
