*** Settings ***
Documentation    This test suite verifies the functionality of searching and removing red books from the store inventory.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search for red books - successful scenario
    [Documentation]    Verify that a book maintainer can search for red books successfully.
    [Tags]    req-DEV-186    type-ok
    Given I am a book maintainer
    When I search for books with the color red
    Then I should see a list of all red books in the store

Search for red books with no red books available - unsuccessful scenario
    [Documentation]    Verify that a book maintainer sees a message when no red books are available.
    [Tags]    req-DEV-186    type-nok
    Given I am a book maintainer
    When I search for books with the color red
    Then I should see a message indicating no red books are available

Remove red books from inventory - successful scenario
    [Documentation]    Verify that a book maintainer can remove red books from the inventory successfully.
    [Tags]    req-DEV-186    type-ok
    Given I have a list of red books
    When I select all red books
    And I confirm the removal
    Then the red books should be removed from the store inventory
    And I should receive a confirmation of the removal

Attempt to remove red books without confirmation - unsuccessful scenario
    [Documentation]    Verify that red books are not removed if the removal is not confirmed.
    [Tags]    req-DEV-186    type-nok
    Given I have a list of red books
    When I select all red books
    And I do not confirm the removal
    Then the red books should not be removed from the store inventory
    And I should receive a message indicating the removal was not confirmed

*** Keywords ***
I am a book maintainer
    New Browser    chromium
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    book_maintainer
    Fill Text    id=password    password123
    Click    id=loginButton
    Wait For Elements State    id=searchBox    visible

I search for books with the color red
    Fill Text    id=searchBox    red
    Click    id=searchButton
    Wait For Elements State    css=.book-item    visible

I should see a list of all red books in the store
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []

I should see a message indicating no red books are available
    Wait For Elements State    id=noBooksMessage    visible
    ${message}=    Get Text    id=noBooksMessage
    Should Be Equal    ${message}    No red books are available

I have a list of red books
    I am a book maintainer
    I search for books with the color red

I select all red books
    ${books}=    Get Elements    css=.book-item
    FOR    ${book}    IN    @{books}
        Click    ${book}
    END

I confirm the removal
    Click    id=confirmRemovalButton
    Wait For Elements State    id=removalConfirmation    visible

I do not confirm the removal
    Click    id=cancelRemovalButton
    Wait For Elements State    id=removalCancelledMessage    visible

The red books should be removed from the store inventory
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} == []

I should receive a confirmation of the removal
    ${message}=    Get Text    id=removalConfirmation
    Should Be Equal    ${message}    Red books have been removed successfully

The red books should not be removed from the store inventory
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []

I should receive a message indicating the removal was not confirmed
    ${message}=    Get Text    id=removalCancelledMessage
    Should Be Equal    ${message}    Removal was not confirmed
