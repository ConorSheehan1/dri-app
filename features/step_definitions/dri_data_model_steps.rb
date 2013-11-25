Given /^we have a "(.*?)" Model$/ do |model_name|
  eval("defined?(#{model_name}) && ['Collection', 'Sound', 'Text'].includes?(#{model_name})")
end

When /^we test the "(.*?)" Model$/ do |model_name|
  model = model_name.split(":").last.downcase
  @test_model = FactoryGirl.build(model.to_sym)
  @test_model.should be_valid
end

Then /^it should have attribute "(.*?)"$/ do |attribute_name|
  @test_model.should respond_to(attribute_name)
end

Then /^it should validate presence of attribute "(.*?)"$/ do |attribute_name|
  @test_model.should validate_presence_of(attribute_name)
end

When /^we test an empty "(.*?)" Model$/ do |model_name|
  @test_model = Batch.new
  @test_model.type = [ model_name ]
end

Then /^the "(.*?)" Model should not be valid$/ do |model_name|
  @test_model.should_not be_valid
end

Given /^an object in collection "(.*?)" with metadata from file "(.*?)"$/ do |collection,file|
  col = Batch.find(collection)
  col.status = 'published'
  col.save
  obj = Batch.new(:pid => "dri:9999")
  tmp_xml = Nokogiri::XML(File.new(File.join(cc_fixture_path, file)).read)
  obj.update_metadata tmp_xml
  obj.status = 'published'
  obj.governing_collection = col
  obj.rightsMetadata.metadata.machine.integer = '0'
  obj.rightsMetadata.discover_access.machine.group = 'public'
  obj.rightsMetadata.masterfile.machine.integer = '1'
  obj.save
end
