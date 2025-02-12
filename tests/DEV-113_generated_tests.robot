*** Settings ***
Documentation    This test suite verifies the functionality of removing all books from the database.
Library          Browser

*** Variables ***
${URL}           http://example.com
${MANAGER}       manager
${NO_AUTH}       no_auth

*** Test Cases ***
Manager removes all books - successful scenario
    [Documentation]    Verify that a manager can successfully remove all books from the database.
    [Tags]    req-DEV-112    type-ok
    Given I am a manager
    When I choose to remove all books from the database
    Then all books should be removed from the database
    And I should receive a confirmation that all books have been successfully removed

Manager attempts to remove all books without proper authorization - unsuccessful scenario
    [Documentation]    Verify that a manager without proper authorization cannot remove all books from the database.
    [Tags]    req-DEV-112    type-nok
    Given I am a manager
    And I do not have the proper authorization
    When I choose to remove all books from the database
    Then the operation should be denied
    And I should receive an error message indicating lack of authorization

*** Keywords ***
I am a manager
    New Page    ${URL}
    Click    text=Login
    Fill Text    username    ${MANAGER}
    Fill Text    password    password
    Click    text=Submit

I do not have the proper authorization
    New Page    ${URL}
    Click    text=Login
    Fill Text    username    ${NO_AUTH}
    Fill Text    password    password
    Click    text=Submit

I choose to remove all books from the database
    Click    text=Remove All Books

All books should be removed from the database
    Wait For Elements State    text=No books available    visible

I should receive a confirmation that all books have been successfully removed
    Wait For Elements State    text=All books have been successfully removed    visible

The operation should be denied
    Wait For Elements State    text=Operation denied    visible

I should receive an error message indicating lack of authorization
    Wait For Elements State    text=Error: Lack of authorization    visible
