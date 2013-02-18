Given /^a collection that does not exist$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I create a Digital Object in the collection "(.*?)"$/ do |collection_pid|
  steps %{
    Given I am on the new Digital Object page
    And I select "#{collection_pid}" from the selectbox for ingest collection
    And I press the button to continue
    And I select "audio" from the selectbox for object type
    And I press the button to continue
    And I select "upload" from the selectbox for ingest methods
    And I press the button to continue
    And I attach the metadata file "valid_metadata.xml"
    And I press the button to ingest metadata
  }
end

When /^I add the Digital Object "(.*?)" to the non-governing collection "(.*?)" using the web forms$/ do |object_pid,collection_pid|
  steps %{
    Given I am on the edit Digital Object page for id #{object_pid}
    And I select "#{collection_pid}" from the selectbox for add to collection
    And I press the button to add to collection
  }
end

When /^I enter valid metadata for a collection$/ do
  steps %{
    When I fill in "dri_model_collection_title" with "Test collection"
    And I fill in "dri_model_collection_description" with "Test description"
    And I fill in "dri_model_collection_publisher" with "Test publisher"
  }
end

When /^I enter valid metadata for a collection with title (.*?)$/ do |title|
  steps %{
    When I fill in "dri_model_collection_title" with "#{title}"
    And I fill in "dri_model_collection_description" with "Test description"
    And I fill in "dri_model_collection_publisher" with "Test publisher"
  }
end

When /^I add the Digital Object "(.*?)" to the collection "(.*?)" as type ([^"]*)$/ do |object_pid,collection_pid,type|
  object = ActiveFedora::Base.find(object_pid, {:cast => true})
  collection = ActiveFedora::Base.find(collection_pid, {:cast => true})
  case type
    when "governing"
      object.title = SecureRandom.hex(5)
      collection.governed_items << object
    when "non-governing"
      object.title = SecureRandom.hex(5)
      collection.items << object
  end
end

Then /^the collection should exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the collection "(.*?)" should contain the Digital Object "(.*?)"(?: as type ([^"]*))?$/ do |collection_pid,object_pid,*type|
  object = ActiveFedora::Base.find(object_pid, {:cast => true})
  collection = ActiveFedora::Base.find(collection_pid, {:cast => true})
  case type
    when "governing"
      collection.governed_items.length.should == 1
      collection.governed_items[0].title.should == object.title
    when "non-governing"
      collection.items.length.should == 1
      collection.items[0].title.should == object.title
  end
end

Then /^I should get a duplicate object warning$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^a collection with pid "(.*?)"(?: and title "(.*?)")?$/ do |pid, title|
  collection = DRI::Model::Collection.new(:pid => pid)
  collection.title = title ? title : SecureRandom.hex(5)
  collection.save
end

Given /^a Digital Object with pid "(.*?)" and title "(.*?)"/ do |pid, title|
  digital_object = DRI::Model::Audio.new(:pid => pid)
  digital_object.title = title
  digital_object.rights = "This is a statement of rights"
  digital_object.save
end

Given /^the collection already contains the Digital Object$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I retrieve the collection$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I press the remove from collection button for Digital Object "(.*?)"/ do |object_pid|
   click_link_or_button(button_to_id("remove from collection #{object_pid}"))
end

Then /^I should see my Digital Objects$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be given a choice of using the existing object or creating a new one$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see my collections$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Digital Object "(.*?)" as part of the collection$/ do |object_pid|
  object = DRI::Model::Audio.all.first
  page.should have_content object.title
end

Then /^I should not see the Digital Object as part of the non-governing collection$/ do
  object = DRI::Model::Audio.all.first
  page.should_not have_content object.title
end
