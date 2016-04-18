@req-17 @duplicates @req-17.1.1 @done @javascript
Feature: Duplicates

When I ingest a digital object into a collection in the repository
As an authenticated and authorised depositor
I want to be warned of any possible duplicate objects already contained in the collection

Background:
  Given I am logged in as "user1" in the group "cm" and accept cookies

Scenario: Ingesting a duplicate Digital Object using metadata file upload
  Given a collection with pid "dupxxxx" and title "Test Collection" created by "user1"
  And I have created an object with metadata "SAMPLEA.xml" in the collection with pid "dupxxxx"
  When I go to the "metadata" "upload" page for "dupxxxx" 
  And I attach the metadata file "SAMPLEA.xml"
  And I press the button to "ingest metadata"
  Then I should see a success message for ingestion
  And I should see the message "Possible duplicate objects found"

Scenario: Ingesting a duplicate Digital Object using form input
  Given a collection with pid "xxxxxxxx2" and title "Test Collection" created by "user1"
  And I have created an object with title "SAMPLE OBJECT A" in the collection with pid "xxxxxxxx2"  
  When I go to the "collection" "show" page for "xxxxxxxx2"
  And I follow the link to add an object
  When I enter valid metadata with title "SAMPLE OBJECT A"
  And I press the button to "continue"
  Then I should see a success message for ingestion
  And I should see the message "Possible duplicate objects found"

Scenario: Creating a duplicate Digital Object by replacing the metadata file
  Given a collection with pid "xxxx3" and title "Test Collection" created by "user1"
  And I have created an object with metadata "SAMPLEA.xml" in the collection with pid "xxxx3"
  And a Digital Object with pid "2222" created by "user1"
  And the object with pid "2222" is in the collection with pid "xxxx3"
  When I go to the "object" "show" page for "2222"
  And I click the link to edit
  And I attach the metadata file "SAMPLEB.xml"
  And I press the button to "upload metadata"
  Then I should not see the message "Possible duplicate objects found"
  When I go to the "object" "show" page for "2222"
  And I click the link to edit
  And I attach the metadata file "SAMPLEA.xml" 
  And I press the button to "upload metadata"
  Then I should see the message "Possible duplicate objects found"

Scenario: Creating a duplicate Digital Object by editing with the metadata form
 Given a collection with pid "xxxxxxxx4" and title "Test Collection" created by "user1"
 Given a Digital Object with pid "333333333" created by "user1"
 And a Digital Object with pid "444444444" created by "user1"
 And the object with pid "333333333" is in the collection with pid "xxxxxxxx4"
 And the object with pid "444444444" is in the collection with pid "xxxxxxxx4"
 When I go to the "object" "edit" page for "333333333"
 And I enter valid metadata with title "SAMPLE OBJECT A"
 And I press the button to "save changes"
 And I go to the "object" "edit" page for "444444444"
 And I enter valid metadata with title "SAMPLE OBJECT A"
 And I press the button to "save changes"
 Then I should see a success message for updating metadata
 And I should see the message "Possible duplicate objects found"

