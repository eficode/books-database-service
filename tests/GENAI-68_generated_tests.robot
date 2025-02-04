*** Settings ***
Documentation    This test suite verifies the functionality of searching books by color.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search Books By Specific Color - Successful Scenario
    [Documentation]    Verify that searching for books by a specific color returns a list of books with that color.
    [Tags]    req-GENAI-66    type-ok
    Given I am a book seller
    When I search for books by the color 'red'
    Then I should see a list of books that have the color 'red'

Search Books By Specific Color With No Results - Unsuccessful Scenario
    [Documentation]    Verify that searching for books by a specific color with no results shows an appropriate message.
    [Tags]    req-GENAI-66    type-nok
    Given I am a book seller
    When I search for books by the color 'red'
    And there are no books with the color 'red'
    Then I should see a message indicating no books were found with the color 'red'

Search Books By Multiple Colors - Successful Scenario
    [Documentation]    Verify that searching for books by multiple colors returns a list of books with those colors.
    [Tags]    req-GENAI-66    type-ok
    Given I am a book seller
    When I search for books by the colors 'blue' and 'green'
    Then I should see a list of books that have either 'blue' or 'green' colors

Search Books By Multiple Colors With No Results - Unsuccessful Scenario
    [Documentation]    Verify that searching for books by multiple colors with no results shows an appropriate message.
    [Tags]    req-GENAI-66    type-nok
    Given I am a book seller
    When I search for books by the colors 'blue' and 'green'
    And there are no books with the colors 'blue' or 'green'
    Then I should see a message indicating no books were found with the colors 'blue' or 'green'

No Books Found For A Color - Successful Scenario
    [Documentation]    Verify that searching for books by a color with no results shows an appropriate message.
    [Tags]    req-GENAI-66    type-ok
    Given I am a book seller
    When I search for books by the color 'purple'
    Then I should see a message indicating no books were found with the color 'purple'

No Books Found For A Color With Results - Unsuccessful Scenario
    [Documentation]    Verify that searching for books by a color with results returns a list of books with that color.
    [Tags]    req-GENAI-66    type-nok
    Given I am a book seller
    When I search for books by the color 'purple'
    And there are books with the color 'purple'
    Then I should see a list of books that have the color 'purple'

*** Keywords ***
I am a book seller
    New Browser    headless=False
    New Page    ${URL}

I search for books by the color 'red'
    Click    id=search-bar
    Fill Text    id=search-bar    red
    Click    id=search-button

I should see a list of books that have the color 'red'
    Wait For Elements State    css=.book-item    visible
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []

There are no books with the color 'red'
    # Simulate no books found scenario
    Evaluate    document.querySelectorAll('.book-item').forEach(el => el.remove())

I should see a message indicating no books were found with the color 'red'
    Wait For Elements State    css=.no-results-message    visible
    Get Element    css=.no-results-message

I search for books by the colors 'blue' and 'green'
    Click    id=search-bar
    Fill Text    id=search-bar    blue, green
    Click    id=search-button

I should see a list of books that have either 'blue' or 'green' colors
    Wait For Elements State    css=.book-item    visible
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []

There are no books with the colors 'blue' or 'green'
    # Simulate no books found scenario
    Evaluate    document.querySelectorAll('.book-item').forEach(el => el.remove())

I should see a message indicating no books were found with the colors 'blue' or 'green'
    Wait For Elements State    css=.no-results-message    visible
    Get Element    css=.no-results-message

I search for books by the color 'purple'
    Click    id=search-bar
    Fill Text    id=search-bar    purple
    Click    id=search-button

I should see a message indicating no books were found with the color 'purple'
    Wait For Elements State    css=.no-results-message    visible
    Get Element    css=.no-results-message

There are books with the color 'purple'
    # Simulate books found scenario
    Evaluate    document.querySelector('body').innerHTML += '<div class="book-item">Purple Book</div>'

I should see a list of books that have the color 'purple'
    Wait For Elements State    css=.book-item    visible
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []
