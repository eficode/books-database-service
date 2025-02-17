*** Settings ***
Documentation    Test suite for verifying the removal of test books from the database
Library          Browser

*** Variables ***
${URL}           http://example.com
${MANAGER_USER}  manager
${NO_PERMISSION_USER}  no_permission_user
${PASSWORD}      password

*** Test Cases ***
Remove All Test Books Successfully
    [Documentation]    Verify that a Test Manager can successfully remove all test books from the database
    [Tags]    req-GENAI-103    type-ok
    Given I am a Test Manager
    When I choose to remove all test books
    Then all test books should be removed from the database
    And I should receive a confirmation message that all test books have been successfully removed

Remove All Test Books Without Proper Authorization
    [Documentation]    Verify that a Test Manager without proper permissions cannot remove test books from the database
    [Tags]    req-GENAI-103    type-nok
    Given I am a Test Manager
    And I do not have the necessary permissions
    When I choose to remove all test books
    Then the system should not allow the removal of test books
    And I should receive an error message indicating lack of permissions

*** Keywords ***
I am a Test Manager
    New Page    ${URL}
    Login As Test Manager

I do not have the necessary permissions
    New Page    ${URL}
    Login As No Permission User

I choose to remove all test books
    Click    id=remove-all-books-button

All test books should be removed from the database
    Wait For Elements State    id=book-list    hidden

I should receive a confirmation message that all test books have been successfully removed
    Wait For Elements State    id=confirmation-message    visible
    Get Text    id=confirmation-message    ==    All test books have been successfully removed

The system should not allow the removal of test books
    Wait For Elements State    id=error-message    visible

I should receive an error message indicating lack of permissions
    Get Text    id=error-message    ==    You do not have the necessary permissions to remove test books

Login As Test Manager
    Fill Text    id=username    ${MANAGER_USER}
    Fill Text    id=password    ${PASSWORD}
    Click    id=login-button

Login As No Permission User
    Fill Text    id=username    ${NO_PERMISSION_USER}
    Fill Text    id=password    ${PASSWORD}
    Click    id=login-button
