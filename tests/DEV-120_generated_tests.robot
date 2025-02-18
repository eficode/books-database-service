*** Settings ***
Documentation    This test suite verifies the removal of all test books from the test environment under various conditions.
Library          Browser

*** Variables ***
${URL}           http://testenvironment.example.com
${USERNAME}      testmanager
${PASSWORD}      password123

*** Test Cases ***
Remove All Test Books Successfully
    [Documentation]    Verify that all test books are removed successfully by an authorized Test Manager.
    [Tags]    req-DEV-118    type-ok
    Given I am a Test Manager
    When I initiate the removal of all test books
    Then all test books should be removed from the test environment
    And I should receive a confirmation that the test books have been successfully removed

Remove All Test Books Unauthorized User
    [Documentation]    Verify that an unauthorized user cannot remove test books and receives an error message.
    [Tags]    req-DEV-118    type-nok
    Given I am a Test Manager
    And I am not authorized to remove test books
    When I initiate the removal of all test books
    Then system should not remove any test books
    And I should receive an error message indicating lack of authorization

Remove All Test Books System Error
    [Documentation]    Verify that no test books are removed when the system is experiencing an error and an error message is received.
    [Tags]    req-DEV-118    type-nok
    Given I am a Test Manager
    And system is experiencing an error
    When I initiate the removal of all test books
    Then system should not remove any test books
    And I should receive an error message indicating the system error

Remove All Test Books Partial Removal
    [Documentation]    Verify that only some test books are removed when there is a system issue causing partial removal and a notification is received.
    [Tags]    req-DEV-118    type-nok
    Given I am a Test Manager
    And there is a system issue causing partial removal
    When I initiate the removal of all test books
    Then only some test books should be removed from the test environment
    And I should receive a notification indicating partial removal and the issue encountered

*** Keywords ***
I am a Test Manager
    New Page    ${URL}
    Fill Text    username    ${USERNAME}
    Fill Text    password    ${PASSWORD}
    Click    loginButton

I initiate the removal of all test books
    Click    removeAllBooksButton

all test books should be removed from the test environment
    Wait For Elements State    removedBooksList    detached

I should receive a confirmation that the test books have been successfully removed
    Wait For Elements State    confirmationMessage    visible
    Get Text    confirmationMessage    ==    All test books have been successfully removed.

I am not authorized to remove test books
    # Assuming the user is logged in but lacks the necessary permissions
    # No additional steps needed here

system should not remove any test books
    Wait For Elements State    removedBooksList    attached

I should receive an error message indicating lack of authorization
    Wait For Elements State    errorMessage    visible
    Get Text    errorMessage    ==    You are not authorized to remove test books.

system is experiencing an error
    # Simulate system error state
    Evaluate    window.simulateSystemError()

I should receive an error message indicating the system error
    Wait For Elements State    errorMessage    visible
    Get Text    errorMessage    ==    System error occurred. Please try again later.

there is a system issue causing partial removal
    # Simulate partial removal state
    Evaluate    window.simulatePartialRemoval()

only some test books should be removed from the test environment
    Wait For Elements State    partiallyRemovedBooksList    attached

I should receive a notification indicating partial removal and the issue encountered
    Wait For Elements State    partialRemovalMessage    visible
    Get Text    partialRemovalMessage    ==    Partial removal occurred due to system issue.
