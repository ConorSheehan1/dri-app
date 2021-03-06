@req-17 @historical
Feature: Ingestion

In order to add a digital object into the repository
As an authenticated and authorised depositor
I want to ingest an asset with metadata

Background:
  Given I am logged in as "user1"

@wip
Scenario: Ingesting a Digital Object of 1 file
  Given the asset SAMPLEA
  Given that the asset is only 1 file
  #Given a known collection
  And a metadata file SAMPLEA.xml
  When I ingest the files SAMPLEA and SAMPLEA.xml
  Then I validate the metadata file
  Then I attempt to validate the data file against a mime type database
  #Then I perform an Anti Viral check on the data file
  #Then I check my collections for duplicates
  #But if there are duplicates warn the user and give the user a choice of using the existing object or create a new one
  #Then I inspect the asset for the file metadata and record this information
  #Then I ingest the asset with the metadata
  Then I should have a PID for the object in the digital repository

#Scenario: Ingesting a Digital Object with an invalid asset
#  Given the asset SAMPLEA
#  Given a known collection
#  And a metadata file SAMPLEA.xml
#  When I ingest the files SAMPLEA and SAMPLEA.xml
#  Then I check my digital repository for duplicates
#  Then I check my collections for duplicates
#  But there must be no duplicates
#  Then I inspect the asset for the file metadata and record this information
#  But the asset is invalid
#  Then I should raise an exception
#
#Scenario: Ingesting a Digital Object with invalid metadata
#  Given the asset SAMPLEA
#  Given a known collection
#  And a metadata file SAMPLEA.xml
#  When I ingest the files SAMPLEA and SAMPLEA.xml
#  Then I check my digital repository for duplicates
#  Then I check my collections for duplicates
#  But there must be no duplicates
#  Then I inspect the asset for the file metadata and record this information
#  Then I validate the metadata file
#  But the metadata is invalid
#  Then I should raise an exception
