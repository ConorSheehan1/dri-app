require 'rails_helper'

feature 'Deleting a single object' do
  describe 'as a manager user' do
  before(:each) do
    @tmp_assets_dir = Dir.mktmpdir
    Settings.dri.files = @tmp_assets_dir

    @login_user = FactoryGirl.create(:collection_manager)

    visit new_user_session_path
    fill_in "user_email", with: @login_user.email
    fill_in "user_password", with: @login_user.password
    click_button "Login"
  end

  after(:each) do
    @login_user.delete
    FileUtils.remove_dir(@tmp_assets_dir, force: true)
  end

  scenario 'unable to delete a published object' do
    collection = FactoryGirl.create(:collection)
    collection.depositor = User.find_by_email(@login_user.email).to_s
    collection.manager_users_string=User.find_by_email(@login_user.email).to_s
    collection.discover_groups_string="public"
    collection.read_groups_string="registered"
    collection.creator = [@login_user.email]
    collection.save

    object = FactoryGirl.create(:sound) 
    object[:status] = "published"
    object.depositor=User.find_by_email(@login_user.email).to_s
    object.manager_users_string=User.find_by_email(@login_user.email).to_s
    object.creator = [@login_user.email]  
  
    object.save

    collection.governed_items << object
  
    visit(my_collections_path(object.noid))
    
    expect(page).not_to have_link(I18n.t('dri.views.objects.buttons.delete_object'))

    collection.destroy
  end

  scenario 'deleting a draft object' do
    collection = FactoryGirl.create(:collection)
    collection.depositor = User.find_by_email(@login_user.email).to_s
    collection.manager_users_string=User.find_by_email(@login_user.email).to_s
    collection.discover_groups_string="public"
    collection.read_groups_string="registered"
    collection.creator = [@login_user.email]
    collection.save

    object = FactoryGirl.create(:sound)
    object[:status] = "draft"
    object.depositor=User.find_by_email(@login_user.email).to_s
    object.manager_users_string=User.find_by_email(@login_user.email).to_s
    object.creator = [@login_user.email]

    object.save

    collection.governed_items << object
  
    visit(my_collections_path(object.noid))
    click_button "submit_delete"

    expect(current_path).to eq(my_collections_index_path)
    expect(page.find('.dri_alert_text')).to have_content I18n.t('dri.flash.notice.object_deleted')

    collection.reload
    collection.destroy
   end
  end

  describe 'as an admin user' do
    before(:each) do
      @tmp_assets_dir = Dir.mktmpdir
      Settings.dri.files = @tmp_assets_dir

      @login_user = FactoryGirl.create(:admin)

      visit new_user_session_path
      fill_in "user_email", with: @login_user.email
      fill_in "user_password", with: @login_user.password
      click_button "Login"
    end

    after(:each) do
      @login_user.delete
      FileUtils.remove_dir(@tmp_assets_dir, force: true)
    end

    scenario 'able to delete as admin' do
      collection = FactoryGirl.create(:collection)
      collection.depositor = User.find_by_email(@login_user.email).to_s
      collection.manager_users_string=User.find_by_email(@login_user.email).to_s
      collection.discover_groups_string="public"
      collection.read_groups_string="registered"
      collection.creator = [@login_user.email]
      collection.save

      object = FactoryGirl.create(:sound) 
      object[:status] = "published"
      object.depositor=User.find_by_email(@login_user.email).to_s
      object.manager_users_string=User.find_by_email(@login_user.email).to_s
      object.creator = [@login_user.email]  
  
      object.save

      collection.governed_items << object
  
      visit(my_collections_path(object.noid))
    
      expect(page).to have_link(I18n.t('dri.views.objects.buttons.delete_object'))

      collection.destroy
    end
  end

end
    
