Feature: Access controls
  In order to control write access to collections, digital objects and assets
  I should be able to set manage and edit permissions

  Background:
    Given a collection with pid "dri:c11111" and title "Access Controls Test Collection" created by "user1"
    And a Digital Object with pid "dri:o11111" and title "Access Controls Test Object" created by "user1"
    And the object with pid "dri:o11111" is governed by the collection with pid "dri:c11111"
    When I am logged in as "user1" in the group "admin"
    And I add the asset "sample_audio.mp3" to "dri:o11111"
    And I am not logged in

  Scenario Outline: I should only see a button to Edit Collection if I have manage or higher permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:c11111"
    Then I should see a link to edit a collection

    Examples:
      | permission |
      | admin      |
      | manage     |


  Scenario Outline: I should not see a button to Edit Collection if I have edit or lower permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:c11111"
    Then I should not see a link to edit a collection

    Examples:
      | permission |
      | edit       |
      | read       |
      | none       |

  Scenario Outline: I should see a button to Generate Surrogates for the collection if I have manage or higher permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:c11111"
    Then I should see a link to generate surrogates

    Examples:
      | permission |
      | admin      |
      | manage     |


  Scenario Outline: I should not see a button to Generate Surrogates for collection if I have edit or lower permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:c11111"
    Then I should not see a link to generate surrogates

    Examples:
      | permission |
      | edit       |
      | read       |
      | none       |


  @javascript
  Scenario Outline: I should see a button to Publish if I have manage or higher permissions on the collection
    Given I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:c11111"
    Then I should see a link to publish collection
    When I follow the link to publish collection
    Then I should see a link to publish objects in the collection

    Examples:
      | permission |
      | admin      |
      | manage     |


  Scenario Outline: I should not see a button to Publish if I have edit or lower permissions on the collection
    Given I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:c11111"
    Then I should not see a link to publish collection

    Examples:
      | permission |
      | edit       |
      | read       |
      | none       |



  Scenario Outline: I should only see a button to Edit Collection if I have edit or higher permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:o11111"
    Then I should see a link to edit an object

    Examples:
      | permission |
      | admin      |
      | manage     |
      | edit       |


  Scenario Outline: I should not see a button to Edit Collection if I have lower than edit permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:o11111"
    Then I should not see a link to edit an object

    Examples:
      | permission |
      | read       |
      | none       |


  Scenario Outline: I should only see a button to Generate Surrogates for an object if I have edit or higher permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:o11111"
    Then I should see a link to generate surrogates

    Examples:
      | permission |
      | admin      |
      | manage     |
      | edit       |


  Scenario Outline: I should not see a button to Generate Surrogates for an object if I lower than edit permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:o11111"
    Then I should not see a link to generate surrogates

    Examples:
      | permission |
      | read       |
      | none       |


  Scenario Outline: I should only see a button to Update Status for an object if I have edit or higher permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:o11111"
    Then I should see a link to update status

    Examples:
      | permission |
      | admin      |
      | manage     |
      | edit       |


  Scenario Outline: I should not see a button to Update Status for an object if I lower than edit permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And I go to "show Digital Object page for id dri:o11111"
    Then I should not see a link to update status

    Examples:
      | permission |
      | read       |
      | none       |

  Scenario Outline: I should see a button to delete collection if I am an admin user
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "admin" permissions on "dri:c11111"
    And the collection with pid "dri:c11111" has status <status>
    When I go to "edit collection page for id dri:c11111"
    Then I should see a button to delete collection with id dri:c11111

    Examples:
      | status    |
      | draft     |
      | published |

  Scenario: I should see a button to delete collection if I have manage permissions and collection is draft
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "manage" permissions on "dri:c11111"
    And the collection with pid "dri:c11111" has status draft
    When I go to "edit collection page for id dri:c11111"
    Then I should see a button to delete collection with id dri:c11111

  Scenario: I should not see a button to delete collection if I have manage permissions and collection is published
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "manage" permissions on "dri:c11111"
    And the collection with pid "dri:c11111" has status published
    When I go to "edit collection page for id dri:c11111"
    Then I should not see a button to delete collection with id dri:c11111

  Scenario Outline: I should not see a button to delete collection if I have edit or lower permissions
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "<permission>" permissions on "dri:c11111"
    And the collection with pid "dri:c11111" has status <status>
    When I go to "edit collection page for id dri:c11111"
    Then I should not see a button to delete collection with id dri:c11111

    Examples:
      | permission | status    |
      | edit       | draft     |
      | edit       | published |
      | read       | draft     |
      | read       | published |
      | none       | draft     |
      | none       | published |

  Scenario: I should be able to delete a collection if I am an admin user
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "admin" permissions on "dri:c11111"
    And the collection with pid "dri:c11111" has status published
    When I go to "edit collection page for id dri:c11111"
    Then I should see a button to delete collection with id dri:c11111
    When I press the button to delete collection with id dri:c11111
    Then I should see a message for deleting a collection

  Scenario: I should be able to delete a collection if I have manage permissions and collection is draft
    When I am logged in as "foo"
    And "foo@foo.com" has been granted "manage" permissions on "dri:c11111"
    And the collection with pid "dri:c11111" has status draft
    When I go to "edit collection page for id dri:c11111"
    Then I should see a button to delete collection with id dri:c11111
    When I press the button to delete collection with id dri:c11111
    Then I should see a message for deleting a collection
