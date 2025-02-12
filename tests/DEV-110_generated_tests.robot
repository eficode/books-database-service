*** Settings ***
Documentation    This test suite verifies the removal of all books from the database by different user roles and handles both successful and unsuccessful scenarios.
Library          Browser

*** Variables ***
${URL}           http://example.com
${MANAGER_USER}  manager
${NON_MANAGER_USER}  non_manager

*** Test Cases ***
Manager Initiates Removal Of All Books - Successful Scenario
    [Documentation]    Verify that a manager can successfully remove all books from the database.
    [Tags]    req-DEV-109    type-ok
    Given I am a manager
    When I choose to remove all books from the database
    Then all books should be removed from the database
    And I should receive a confirmation that all books have been successfully removed

Manager Initiates Removal Of All Books But Fails Due To A System Error - Unsuccessful Scenario
    [Documentation]    Verify that a manager receives an error message when a system error occurs during the removal of all books.
    [Tags]    req-DEV-109    type-nok
    Given I am a manager
    When I choose to remove all books from the database
    And there is a system error
    Then I should receive an error message indicating that the removal process failed

Non-manager Attempts To Remove All Books - Successful Scenario
    [Documentation]    Verify that a non-manager receives an error message when attempting to remove all books from the database.
    [Tags]    req-DEV-109    type-ok
    Given I am not a manager
    When I attempt to remove all books from the database
    Then I should receive an error message indicating that I do not have the necessary permissions

Non-manager Attempts To Remove All Books But The System Does Not Show An Error - Unsuccessful Scenario
    [Documentation]    Verify that a non-manager cannot remove books and receives confirmation that books were not removed even if the system does not show an error.
    [Tags]    req-DEV-109    type-nok
    Given I am not a manager
    When I attempt to remove all books from the database
    And the system does not show an error
    Then the books should not be removed from the database
    And I should receive a confirmation that the books were not removed

*** Keywords ***
I am a manager
    Browser.Open Browser    ${URL}    chromium
    Login As User    ${MANAGER_USER}

I am not a manager
    Browser.Open Browser    ${URL}    chromium
    Login As User    ${NON_MANAGER_USER}

Choose to remove all books from the database
    Browser.Click    //button[@id='remove-all-books']

All books should be removed from the database
    Browser.Get Element State    //div[@class='book']    hidden

I should receive a confirmation that all books have been successfully removed
    Browser.Get Element State    //div[@id='confirmation-message' and contains(text(), 'successfully removed')]    visible

There is a system error
    Simulate System Error

I should receive an error message indicating that the removal process failed
    Browser.Get Element State    //div[@id='error-message' and contains(text(), 'removal process failed')]    visible

I attempt to remove all books from the database
    Browser.Click    //button[@id='remove-all-books']

I should receive an error message indicating that I do not have the necessary permissions
    Browser.Get Element State    //div[@id='error-message' and contains(text(), 'do not have the necessary permissions')]    visible

The system does not show an error
    Simulate No Error

The books should not be removed from the database
    Browser.Get Element State    //div[@class='book']    visible

I should receive a confirmation that the books were not removed
    Browser.Get Element State    //div[@id='confirmation-message' and contains(text(), 'books were not removed')]    visible

Login As User
    [Arguments]    ${user}
    Browser.Fill Text    //input[@id='username']    ${user}
    Browser.Fill Text    //input[@id='password']    password
    Browser.Click    //button[@id='login']

Simulate System Error
    # Code to simulate a system error

Simulate No Error
    # Code to simulate no error
