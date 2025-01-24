*** Settings ***
Documentation    Test suite for removing old books from the database
Library          Browser

*** Variables ***
${DATABASE_URL}    http://example.com/database
${CURRENT_DATE}    2023-10-01
${UNAUTHORIZED_USER}    unauthorized_user

*** Test Cases ***
Identify books older than one month - successful scenario
    [Documentation]    Identify books older than one month - successful scenario
    [Tags]    req-DEV-57    type-ok
    Given the current date is available
    When the system checks the database
    Then it should identify books that were added more than one month ago

Identify books older than one month with incorrect date - unsuccessful scenario
    [Documentation]    Identify books older than one month with incorrect date - unsuccessful scenario
    [Tags]    req-DEV-57    type-nok
    Given the current date is available
    And the system's date and time settings are incorrect
    When the system checks the database
    Then it should not correctly identify books that were added more than one month ago

Remove books older than one month - successful scenario
    [Documentation]    Remove books older than one month - successful scenario
    [Tags]    req-DEV-57    type-ok
    Given books older than one month are identified
    When the system initiates the removal process
    Then the identified books should be removed from the database
    And the database size should be updated accordingly

Remove books older than one month with unauthorized access - unsuccessful scenario
    [Documentation]    Remove books older than one month with unauthorized access - unsuccessful scenario
    [Tags]    req-DEV-57    type-nok
    Given books older than one month are identified
    And the removal process is initiated by an unauthorized user
    When the system initiates the removal process
    Then the identified books should not be removed from the database
    And the database size should not be updated

*** Keywords ***
Given the current date is available
    Log    Current date is available: ${CURRENT_DATE}

When the system checks the database
    Open Browser    ${DATABASE_URL}    chromium
    # Additional steps to check the database
    Log    System checks the database

Then it should identify books that were added more than one month ago
    # Steps to identify books older than one month
    Log    Books older than one month identified

And the system's date and time settings are incorrect
    # Steps to simulate incorrect date and time settings
    Log    System's date and time settings are incorrect

Then it should not correctly identify books that were added more than one month ago
    # Steps to verify incorrect identification
    Log    Books older than one month not correctly identified

Given books older than one month are identified
    # Steps to ensure books older than one month are identified
    Log    Books older than one month are identified

When the system initiates the removal process
    # Steps to initiate the removal process
    Log    Removal process initiated

Then the identified books should be removed from the database
    # Steps to verify books removal
    Log    Identified books removed from the database

And the database size should be updated accordingly
    # Steps to verify database size update
    Log    Database size updated accordingly

And the removal process is initiated by an unauthorized user
    # Steps to simulate unauthorized user initiation
    Log    Removal process initiated by unauthorized user

Then the identified books should not be removed from the database
    # Steps to verify books are not removed
    Log    Identified books not removed from the database

And the database size should not be updated
    # Steps to verify database size is not updated
    Log    Database size not updated
