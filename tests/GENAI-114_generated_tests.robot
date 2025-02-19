*** Settings ***
Documentation    Test suite for verifying the removal of all test books from the system
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Remove All Test Books Successfully
    [Documentation]    Verify that all test books can be removed successfully
    [Tags]    req-GENAI-112    type-ok
    Given I am a Test Manager
    When I choose to remove all test books
    Then all test books should be deleted from the database
    And I should receive a confirmation that all test books have been removed

Remove All Test Books With Database Error
    [Documentation]    Verify that test books are not removed when there is a database error
    [Tags]    req-GENAI-112    type-nok
    Given I am a Test Manager
    When I choose to remove all test books
    And there is a database error
    Then all test books should not be deleted from the database
    And I should receive an error message indicating the failure

Remove All Test Books With Insufficient Permissions
    [Documentation]    Verify that test books are not removed when there are insufficient permissions
    [Tags]    req-GENAI-112    type-nok
    Given I am a Test Manager
    When I choose to remove all test books
    And I do not have sufficient permissions
    Then all test books should not be deleted from the database
    And I should receive an error message indicating insufficient permissions

*** Keywords ***
I am a Test Manager
    New Browser    chromium
    New Page    ${URL}
    Login As Test Manager

Login As Test Manager
    # Implement the login steps here
    Log    Logging in as Test Manager

choose to remove all test books
    Click    //button[@id='remove-all-books']

all test books should be deleted from the database
    Wait For Elements State    //table[@id='books-table']    hidden

I should receive a confirmation that all test books have been removed
    ${text}=    Get Text    //div[@id='confirmation-message']
    Should Be Equal    ${text}    All test books have been removed

there is a database error
    Simulate Database Error

Simulate Database Error
    # Implement the simulation of a database error here
    Log    Simulating database error

all test books should not be deleted from the database
    ${state}=    Get Element States    //table[@id='books-table']
    Should Be Equal    ${state}    visible

I should receive an error message indicating the failure
    ${text}=    Get Text    //div[@id='error-message']
    Should Be Equal    ${text}    Database error occurred

I do not have sufficient permissions
    Simulate Insufficient Permissions

Simulate Insufficient Permissions
    # Implement the simulation of insufficient permissions here
    Log    Simulating insufficient permissions

I should receive an error message indicating insufficient permissions
    ${text}=    Get Text    //div[@id='permission-error-message']
    Should Be Equal    ${text}    Insufficient permissions
