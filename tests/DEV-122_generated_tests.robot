*** Settings ***
Documentation    This test suite verifies the removal of all test books from the system under various conditions.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      test_manager
${PASSWORD}      password123

*** Test Cases ***
Remove All Test Books Successfully
    [Documentation]    Verify that all test books are removed successfully by an authorized user.
    [Tags]    req-DEV-121    type-ok
    Given I am a Test Manager
    When I choose to remove all test books
    Then all test books should be deleted from the system
    And I should receive a confirmation that all test books have been successfully removed

Remove All Test Books Unauthorized User
    [Documentation]    Verify that an unauthorized user cannot remove test books.
    [Tags]    req-DEV-121    type-nok
    Given I am a Test Manager
    And I am not authorized to delete test books
    When I choose to remove all test books
    Then all test books should not be deleted from the system
    And I should receive an error message indicating lack of authorization

Remove All Test Books System Error
    [Documentation]    Verify that test books are not removed when the system is experiencing an error.
    [Tags]    req-DEV-121    type-nok
    Given I am a Test Manager
    And the system is experiencing an error
    When I choose to remove all test books
    Then all test books should not be deleted from the system
    And I should receive an error message indicating the system error

Remove All Test Books Partial Deletion
    [Documentation]    Verify that only some test books are deleted when there is an issue causing partial deletion.
    [Tags]    req-DEV-121    type-nok
    Given I am a Test Manager
    And there is an issue causing partial deletion
    When I choose to remove all test books
    Then only some test books should be deleted from the system
    And I should receive a message indicating partial deletion and potential issues

*** Keywords ***
I am a Test Manager
    Browser.New Context
    Browser.New Page    ${URL}
    Browser.Fill Text    username    ${USERNAME}
    Browser.Fill Text    password    ${PASSWORD}
    Browser.Click    login
    Browser.Wait For Elements State    dashboard    visible

I am not authorized to delete test books
    # Simulate unauthorized user by logging in with different credentials or setting permissions
    # This keyword needs to be implemented

The system is experiencing an error
    # Simulate system error by triggering an error state in the application
    # This keyword needs to be implemented

There is an issue causing partial deletion
    # Simulate partial deletion issue by setting up the environment accordingly
    # This keyword needs to be implemented

I choose to remove all test books
    Browser.Click    remove_all_books
    Browser.Wait For Elements State    confirmation_or_error_message    visible

All test books should be deleted from the system
    Browser.Get Element Count    any_test_book    ==    0

All test books should not be deleted from the system
    Browser.Get Element Count    any_test_book    >    0

Only some test books should be deleted from the system
    Browser.Get Element Count    some_test_books    >    0

I should receive a confirmation that all test books have been successfully removed
    Browser.Wait For Elements State    success_message    visible

I should receive an error message indicating lack of authorization
    Browser.Wait For Elements State    authorization_error_message    visible

I should receive an error message indicating the system error
    Browser.Wait For Elements State    system_error_message    visible

I should receive a message indicating partial deletion and potential issues
    Browser.Wait For Elements State    partial_deletion_message    visible
