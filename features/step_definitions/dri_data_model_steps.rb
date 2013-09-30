Given /^we have a "(.*?)" Model$/ do |model_name|
  eval("defined?(#{model_name}) && ['Collection', 'Audio', 'Text'].includes?(#{model_name})")
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
  @test_model.object_type = [ model_name ]
end

Then /^the "(.*?)" Model should not be valid$/ do |model_name|
  @test_model.should_not be_valid
end
