@req-37 @done
Feature: Export files

  In order to export the Digital Objects metadata and asset
  As an authenticated and authorised user
  I want to be able to download the metadata
  And the asset file to my local drive

  Background:
    Given I am logged in as "user1"
    Given a Digital Object with pid "obj111111", title "Object 1" created by "user1"
    And a collection with pid "coll1"
    When I add the Digital Object "obj111111" to the collection "coll1" as type "governing"
    And I add the asset "sample_audio.mp3" to "obj111111"
    Then the collection "coll1" should contain the Digital Object "obj111111" as type "governing"

  Scenario: Export DigitalObject's metadata when I have edit/manage permissions
    When I go to the "object" "show" page for "obj111111"
    Then I should see a "rights statement"
    #And I should see a "licence"
    And I should see a link to download metadata


  Scenario: View DigitalObject's full metadata when I have edit/manage permissions
    When I go to the "object" "show" page for "obj111111"
    Then I should see a "rights statement"
    #And I should see a "licence"
    And I should see a link to full metadata
    When I follow the link to full metadata
    Then I should see a "obj111111"

  Scenario: Export a DigitalObject's asset when I have edit/manage permissions
    When I go to the "object" "show" page for "obj111111"
    Then I should see a "rights statement"
    #And I should see a "licence"
    And I should see a link to download asset

