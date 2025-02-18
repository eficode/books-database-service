*** Settings ***
Documentation    This test suite verifies the functionality of removing all test books under various conditions.
Library           Browser

*** Variables ***
${URL}           http://example.com
${TEST_MANAGER}  test_manager
${UNAUTHORIZED_USER} unauthorized_user

*** Test Cases ***
Remove All Test Books - Successful Scenario
    [Documentation]    Verify that all test books are removed successfully by a Test Manager.
    [Tags]    req-GENAI-106    type-ok
    Given I am a Test Manager
    When I choose to remove all test books
    Then all test books should be deleted from the system
    And I should receive a confirmation that all test books have been removed

Remove All Test Books with Unauthorized User - Unsuccessful Scenario
    [Documentation]    Verify that an unauthorized user cannot remove test books.
    [Tags]    req-GENAI-106    type-nok
    Given I am not a Test Manager
    When I choose to remove all test books
    Then all test books should not be deleted from the system
    And I should receive an error message indicating lack of permissions

Remove All Test Books with System Error - Unsuccessful Scenario
    [Documentation]    Verify that test books are not removed when there is a system error.
    [Tags]    req-GENAI-106    type-nok
    Given I am a Test Manager
    When I choose to remove all test books
    And there is a system error
    Then all test books should not be deleted from the system
    And I should receive an error message indicating the system error

Remove All Test Books with Network Failure - Unsuccessful Scenario
    [Documentation]    Verify that test books are not removed when there is a network failure.
    [Tags]    req-GENAI-106    type-nok
    Given I am a Test Manager
    When I choose to remove all test books
    And there is a network failure
    Then all test books should not be deleted from the system
    And I should receive an error message indicating the network failure

Remove All Test Books without Confirmation - Unsuccessful Scenario
    [Documentation]    Verify that test books are not removed without confirmation.
    [Tags]    req-GENAI-106    type-nok
    Given I am a Test Manager
    When I choose to remove all test books
    And I do not confirm the deletion
    Then all test books should not be deleted from the system
    And I should receive a prompt to confirm the deletion

*** Keywords ***
I am a Test Manager
    New Page    ${URL}
    Click    id=test_manager_login

I am not a Test Manager
    New Page    ${URL}
    Click    id=unauthorized_user_login

I choose to remove all test books
    Click    id=remove_all_books_button

There is a system error
    Evaluate    window.simulateSystemError()

There is a network failure
    Evaluate    window.simulateNetworkFailure()

All test books should be deleted from the system
    Wait For Elements State    id=test_books_list    hidden

All test books should not be deleted from the system
    Wait For Elements State    id=test_books_list    visible

I should receive a confirmation that all test books have been removed
    Wait For Elements State    id=confirmation_message    visible

I should receive an error message indicating lack of permissions
    Wait For Elements State    id=error_message_permissions    visible

I should receive an error message indicating the system error
    Wait For Elements State    id=error_message_system    visible

I should receive an error message indicating the network failure
    Wait For Elements State    id=error_message_network    visible

I do not confirm the deletion
    Click    id=cancel_deletion_button

I should receive a prompt to confirm the deletion
    Wait For Elements State    id=confirm_deletion_prompt    visible
