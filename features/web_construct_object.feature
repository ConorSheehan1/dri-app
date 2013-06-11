@web @req-17.6 @done
Feature: 
  In order to add a digital object into the repository
  As an authenticated and authorised depositor
  I want to construct a Digital Object with web forms

Background:
  Given I am logged in as "user1"

Scenario: Navigating to the ingest page
  When I go to "the home page"
  Then I should see a link to ingest an object
  When I follow the link to ingest an object
  Then I should be on the new Digital Object page

Scenario: Constructing a valid Digital Object
  Given I have created a collection
  And I am on the new Digital Object page
  When I select a collection
  And I press the button to continue
  And I select "audio" from the selectbox for object type
  And I press the button to continue
  And I select "upload" from the selectbox for ingest methods
  And I press the button to continue
  And I attach the metadata file "valid_metadata.xml"
  And I press the button to ingest metadata
  Then I should see a success message for ingestion 

Scenario Outline: Constructing a Digital Object with metadata that incorrect or incomplete
  Given I have created a collection
  And I am on the new Digital Object page
  When I select a collection
  And I press the button to continue
  And I select "<object_type>" from the selectbox for object type
  And I press the button to continue
  And I select "upload" from the selectbox for ingest methods
  And I press the button to continue
  And I attach the metadata file "<metadata_file>"
  And I press the button to ingest metadata
  Then I should see a failure message for "<case>"

  Examples:
    | object_type | metadata_file                 | case             | 
    | audio       | metadata_no_rights.xml        | invalid object   |
    | audio       | invalid_schema_metadata.xml   | invalid schema   |
    | audio       | invalid_xml_metadata.xml      | invalid metadata |

Scenario Outline: Constructing a valid Digital Object
  Given I have created a collection
  And I am on the new Digital Object page
  When I select a collection
  And I press the button to continue
  And I select "<object_type>" from the selectbox for object type
  And I press the button to continue
  And I select "upload" from the selectbox for ingest methods
  And I press the button to continue
  And I attach the metadata file "<metadata_file>"
  And I press the button to ingest metadata
  Then I should see a success message for ingestion
  And the object should be <format_type> format

  Examples:
    | object_type | metadata_file                 | format_type |
    | pdfdoc      | dublin_core_pdfdoc_sample.xml | Article     |
    | audio       | SAMPLEA.xml                   | Audio       |

Scenario: Adding a pdf asset to an object
  Given I have created a pdfdoc object 
  Then I should see a link to edit an object
  When I follow the link to edit an object
  And I attach the asset file "sample_pdf.pdf"
  And I press the button to upload a file
  Then I should see a success message for file upload

Scenario: Replacing the metadata file of a Digital Object
  Given I have created a Digital Object
  Then I should see a link to edit an object
  When I follow the link to edit an object
  And I attach the metadata file "valid_metadata.xml"
  And I press the button to upload metadata
  Then I should see a success message for updating metadata

Scenario: Constructing a Digital Object using the web form
  Given I have created a collection
  And I am on the new Digital Object page
  When I select a collection
  And I press the button to continue
  And I select "audio" from the selectbox for object type
  And I press the button to continue
  And I select "input" from the selectbox for ingest methods
  And I press the button to continue
  When I enter valid metadata
  And I press the button to continue
  Then I should see a success message for ingestion
  And I should see the valid metadata

@review
Scenario: Constructing a Digital Object using the web form without setting a collection
  Given I am on the new Digital Object page
  And I press the button to continue
  And I select "audio" from the selectbox for object type
  And I press the button to continue
  And I select "input" from the selectbox for ingest methods
  And I press the button to continue
  When I enter valid metadata
  And I press the button to continue
  Then I should see a success message for ingestion
  And I should see the valid metadata

Scenario: Editing the metadata of a Digital Object using the web form
  Given I have created a Digital Object
  Then I should see a link to edit an object
  When I follow the link to edit an object
  And I enter modified metadata
  And I press the button to save changes
  And I follow the link to view record
  Then I should see the modified metadata

Scenario: Adding and replacing the audio file for a Digital Object
  Given I have created a Digital Object
  Then I should see a link to edit an object
  When I follow the link to edit an object
  And I attach the asset file "sample_audio.mp3"
  And I press the button to upload a file
  Then I should see a success message for file upload
  When I follow the link to edit an object
  And I attach the asset file "sample_audio.mp3"
  And I press the button to replace a file
  Then I should see a success message for file upload

Scenario Outline: Adding an audio file that is not valid
  Given I have created a Digital Object
  Then I should see a link to edit an object
  When I follow the link to edit an object
  And I attach the asset file "<asset_name>"
  And I press the button to upload a file
  Then I should see a failure message for "<case>"

  Examples:
    | asset_name               | case              |
    | sample_audio.txt         | invalid file type |
    | sample_invalid_audio.mp3 | invalid file type |

Scenario: Adding a file that contains a virus
  Given I have created a Digital Object
  Then I should see a link to edit an object
  When I follow the link to edit an object
  And I upload the virus file "sample_virus.mp3"
  Then I should see a failure message for "virus detected"

Scenario Outline: Editing an audio file where the file is invalid
  Given I have created a Digital Object
  And I have added an audio file  
  When I follow the link to edit an object
  And I attach the asset file "<asset_name>"
  And I press the button to replace a file
  Then I should see a failure message for "<case>"

  Examples:
    | asset_name               | case              |
    | sample_audio.txt         | invalid file type |
    | sample_invalid_audio.mp3 | invalid file type |
