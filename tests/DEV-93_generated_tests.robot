*** Settings ***
Documentation    This test suite verifies the search functionality for books by color for a logged-in book seller.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
Search for books by a specific color - successful scenario
    [Documentation]    Verify that books can be searched by color 'red' successfully.
    [Tags]    req-DEV-91    type-ok
    Given I am a logged-in book seller
    When I search for books by the color 'red'
    Then I should see a list of books that have the color 'red' in their attributes

Search for books by a specific color with no results - unsuccessful scenario
    [Documentation]    Verify that searching for books by color 'red' with no results shows appropriate message.
    [Tags]    req-DEV-91    type-nok
    Given I am a logged-in book seller
    When I search for books by the color 'red'
    And there are no books with the color 'red' in their attributes
    Then I should see a message indicating that no books were found with the color 'red'

No books found for a specific color - successful scenario
    [Documentation]    Verify that searching for books by color 'purple' with no results shows appropriate message.
    [Tags]    req-DEV-91    type-ok
    Given I am a logged-in book seller
    When I search for books by the color 'purple'
    Then I should see a message indicating that no books were found with the color 'purple'

No books found for a specific color with results - unsuccessful scenario
    [Documentation]    Verify that books can be searched by color 'purple' successfully.
    [Tags]    req-DEV-91    type-nok
    Given I am a logged-in book seller
    When I search for books by the color 'purple'
    And there are books with the color 'purple' in their attributes
    Then I should see a list of books that have the color 'purple' in their attributes

*** Keywords ***
I am a logged-in book seller
    New Browser    headless=False
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I search for books by the color 'red'
    Fill Text    id=color-search    red
    Click    text=Search
    Wait For Elements State    css=.book-item    visible

I search for books by the color 'purple'
    Fill Text    id=color-search    purple
    Click    text=Search
    Wait For Elements State    css=.book-item    visible

I should see a list of books that have the color 'red' in their attributes
    Get Elements    css=.book-item
    Should Be True    ${len(elements)} > 0

I should see a list of books that have the color 'purple' in their attributes
    Get Elements    css=.book-item
    Should Be True    ${len(elements)} > 0

There are no books with the color 'red' in their attributes
    Wait For Elements State    css=.no-results    visible

There are books with the color 'purple' in their attributes
    Wait For Elements State    css=.book-item    visible

I should see a message indicating that no books were found with the color 'red'
    Get Text    css=.no-results
    Should Be Equal    ${text}    No books found with the color 'red'

I should see a message indicating that no books were found with the color 'purple'
    Get Text    css=.no-results
    Should Be Equal    ${text}    No books found with the color 'purple'
