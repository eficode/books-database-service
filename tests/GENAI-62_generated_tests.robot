*** Settings ***
Documentation    This test suite verifies the functionality of searching and removing books with black covers in the store.
Library          Browser

*** Variables ***
${URL}           http://bookstore.example.com

*** Test Cases ***
Search for books with black covers - successful scenario
    [Documentation]    Verify that searching for books with black covers returns a list of books with black covers
    [Tags]    req-GENAI-60    type-ok
    Given I am a book seller
    When I search for books with black covers
    Then I should see a list of all books with black covers in the store

Search for books with black covers - unsuccessful scenario
    [Documentation]    Verify that searching for books with black covers returns no books when there are none
    [Tags]    req-GENAI-60    type-nok
    Given I am a book seller
    When I search for books with black covers
    Then I should not see any books with black covers in the store

Remove books with black covers - successful scenario
    [Documentation]    Verify that selected books with black covers are removed from the store inventory and future orders are prevented
    [Tags]    req-GENAI-60    type-ok
    Given I have a list of books with black covers
    When I select books to remove
    Then the selected books should be removed from the store inventory
    And future orders of these books should be prevented

Remove books with black covers - unsuccessful scenario
    [Documentation]    Verify that selected books with black covers are not removed from the store inventory and future orders are not prevented
    [Tags]    req-GENAI-60    type-nok
    Given I have a list of books with black covers
    When I select books to remove
    Then the selected books should not be removed from the store inventory
    And future orders of these books should not be prevented

*** Keywords ***
I am a book seller
    New Browser    headless=False
    New Context
    New Page    ${URL}

I search for books with black covers
    Click    text=Search
    Fill Text    input[name="search"]    black covers
    Click    text=Submit

I should see a list of all books with black covers in the store
    Wait For Elements State    text=Black Cover Book    visible
    ${books}=    Get Elements    text=Black Cover Book
    Should Be True    ${books} != []

I should not see any books with black covers in the store
    Wait For Elements State    text=Black Cover Book    hidden
    ${books}=    Get Elements    text=Black Cover Book
    Should Be True    ${books} == []

I have a list of books with black covers
    ${books}=    Get Elements    text=Black Cover Book
    Should Be True    ${books} != []

I select books to remove
    FOR    ${book}    IN    @{books}
        Click    ${book}
        Click    text=Remove
    END

The selected books should be removed from the store inventory
    Wait For Elements State    text=Black Cover Book    hidden
    ${books}=    Get Elements    text=Black Cover Book
    Should Be True    ${books} == []

Future orders of these books should be prevented
    Click    text=Order
    Fill Text    input[name="order"]    Black Cover Book
    Click    text=Submit
    Wait For Elements State    text=Out of Stock    visible

The selected books should not be removed from the store inventory
    Wait For Elements State    text=Black Cover Book    visible
    ${books}=    Get Elements    text=Black Cover Book
    Should Be True    ${books} != []

Future orders of these books should not be prevented
    Click    text=Order
    Fill Text    input[name="order"]    Black Cover Book
    Click    text=Submit
    Wait For Elements State    text=Order Confirmed    visible
