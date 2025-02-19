*** Settings ***
Documentation    This test suite verifies the functionality of removing all test books under various conditions.
Library          Browser

*** Variables ***
${URL}           http://testmanagementsystem.com

*** Test Cases ***
Remove All Test Books - Successful Scenario
    [Documentation]    Verify that all test books can be successfully removed by an authorized Test Manager.
    [Tags]    req-DEV-124    type-ok
    Given I am a Test Manager
    When I choose to remove all test books
    Then all test books should be deleted from the system
    And test environment should be clean and up-to-date

Remove All Test Books with Unauthorized User - Unsuccessful Scenario
    [Documentation]    Verify that an unauthorized user cannot remove test books and receives an appropriate error message.
    [Tags]    req-DEV-124    type-nok
    Given I am a Test Manager
    And I am not authorized to remove test books
    When I choose to remove all test books
    Then all test books should not be deleted from the system
    And an error message should be displayed indicating lack of permissions

Remove All Test Books with System Error - Unsuccessful Scenario
    [Documentation]    Verify that test books cannot be removed when the system is experiencing an error and an appropriate error message is displayed.
    [Tags]    req-DEV-124    type-nok
    Given I am a Test Manager
    And system is experiencing an error
    When I choose to remove all test books
    Then all test books should not be deleted from the system
    And an error message should be displayed indicating a system error

Remove All Test Books with Network Failure - Unsuccessful Scenario
    [Documentation]    Verify that test books cannot be removed during a network failure and an appropriate error message is displayed.
    [Tags]    req-DEV-124    type-nok
    Given I am a Test Manager
    And there is a network failure
    When I choose to remove all test books
    Then all test books should not be deleted from the system
    And an error message should be displayed indicating a network issue

*** Keywords ***
I am a Test Manager
    New Browser    headless=false
    Go To    ${URL}
    Click    id=login
    Fill Text    id=username    testmanager
    Fill Text    id=password    password123
    Click    id=submit

I choose to remove all test books
    Click    id=remove-all-books

all test books should be deleted from the system
    Wait For Elements State    id=book-list    hidden

test environment should be clean and up-to-date
    # Add steps to verify the environment is clean and up-to-date

all test books should not be deleted from the system
    Wait For Elements State    id=book-list    visible

an error message should be displayed indicating lack of permissions
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    You do not have permission to perform this action.

an error message should be displayed indicating a system error
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    System error occurred. Please try again later.

an error message should be displayed indicating a network issue
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    Network issue detected. Please check your connection and try again.

I am not authorized to remove test books
    Click    id=logout
    Click    id=login
    Fill Text    id=username    unauthorizeduser
    Fill Text    id=password    wrongpassword
    Click    id=submit

system is experiencing an error
    # Simulate system error
    Execute JavaScript    window.simulateSystemError()

there is a network failure
    # Simulate network failure
    Execute JavaScript    window.simulateNetworkFailure()
