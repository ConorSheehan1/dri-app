@javascript
Feature:
  I should be able to add institutes, associate them with collections,
  and view them in the repository

  Background:
    Given I am logged in as "user1" in the group "cm"
    And I have created a collection with title "Institute Test Collection"
    And I have created a "Sound" object with title "Insitute Test Object" in the collection "Institute Test Collection"

  Scenario: Adding a new insititute
    Given I am on the home page
    When I perform a search
    And I press "Institute Test Collection"
    And I follow the link to edit this record
    And I fill in "institute[name]" with "TestInstitute"
    And I fill in "institute[url]" with "http://www.dri.ie/"
    And I attach the institute logo file "sample_logo.png"
    And I press the button to add an institute
    And I wait for the ajax request to finish
    Then the "select_institute" drop-down should contain the option "TestInstitute"

  Scenario: Associating an insititute with a collection
    Given I am on the home page
    When I perform a search
    And I press "Institute Test Collection"
    And I follow the link to edit this record
    And I fill in "institute[name]" with "TestInstitute"
    And I fill in "institute[url]" with "http://www.dri.ie/"
    And I attach the institute logo file "sample_logo.png"
    And I press the button to add an institute
    And I wait for the ajax request to finish
    Then the "select_institute" drop-down should contain the option "TestInstitute"
    When I select "TestInstitute" from the selectbox for institute
    And I press the button to associate an institute
    And I wait for the ajax request to finish
    Then I should see the image "TestInstitute.png"

  Scenario: Viewing associated institutes for a collection
    Given I have associated the institute "TestInstitute" with the colleciton entitled "Institute Test Collection"
    When I perform a search
    And I press "Institute Test Collection"
    Then I should see the image "TestInstitute.png"

  Scenario: viewing associated institutes for an object
    Given I have associated the institute "TestInstitute" with the colleciton entitled "Institute Test Collection"
    When I perform a search
    And I press "Insitute Test Object"
    Then I should see the image "TestInstitute.png"