@req-20
Feature: Search criteria

DELETEME: REQ-20
DELETEME: 
DELETEME: The system shall allow users to refine search criteria through facet search
DELETEME: 
DELETEME: 1.1 It shall allow users to refine search criteria by date
DELETEME: 1.2 It shall allow users to refine search criteria by data type (e.g. images, audio)
DELETEME: 1.3 It shall allow users to refine search criteria by subject 
DELETEME: 1.4 It shall allow users to refine search criteria by location
DELETEME: 1.5 It shall allow users to refine search criteria by free text keyword
DELETEME: 1.6 It shall allow users to refine search criteria by digital object owner
DELETEME: 1.7 It shall allow users to carry out basic and advanced facet searching including Boolean logic.
DELETEME: 1.8 It shall support fuzzy string matching.

In order to search for objects in the repository
As an authenticated and authorised
I want to be able to use the faceted search interface

Background:
  Given I am logged in as "user1"

# sorting of results => see req-26
# Need to ask sharon
# Does not specify if the date is creation, published, upload or broadcast
Scenario Outline: Faceted Search
  Given the search <facet>
  When I search for <search> with <facet>
  Then I should see a <result>

  Examples:
    | facet     | search     | result         |
    | date      | 1916-04-01 | An Audio Title |
    | data_type | audio      | An Audio Title |
    | subject   | 1916       | An Audio Title |
    | location  | ireland    | An Audio Title |
    | keyword   | ireland    | A Title        |
    | digitial_object_owner | Bob | Another Title |

# The following two features could be tested via the all fields / search box
#
# Boolean Logic seeems to be "and" right now in gui, the search box may allow for more/less
# need to be broken up into two scenarios
Scenario: Search using basic and advanced facet searching including Boolean logic

# This is a configuration option in SOLR? May impact Irish searches
# fuzziness isn't well defined in this case
# where and does it need to be in irish
Scenario: Search shall support fuzzy string matching
