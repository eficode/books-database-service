*** Settings ***
Documentation    This test suite verifies the search functionality for blue test books.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search for blue test books - successful scenario
    [Documentation]    Verify that searching for 'blue test books' returns a list of available blue test books.
    [Tags]    req-GENAI-164    type-ok
    Given I am a tester
    When I search for 'blue test books'
    Then I should see a list of all blue test books available in the database

Search for blue test books with no results - unsuccessful scenario
    [Documentation]    Verify that searching for 'blue test books' with no results shows an appropriate message.
    [Tags]    req-GENAI-164    type-nok
    Given I am a tester
    When I search for 'blue test books'
    And no blue test books are available
    Then I should see a message indicating that no blue test books were found

*** Keywords ***
I am a tester
    Browser.New Page    ${URL}

I search for 'blue test books'
    Browser.Fill Text    input[name="search"]    blue test books
    Browser.Click       button[name="searchButton"]

I should see a list of all blue test books available in the database
    ${results}=    Browser.Get Text    css=div.search-results
    Should Not Be Empty    ${results}

no blue test books are available
    Browser.Evaluate JavaScript    document.querySelector('div.search-results').innerHTML = ''

I should see a message indicating that no blue test books were found
    ${message}=    Browser.Get Text    css=div.no-results-message
    Should Be Equal    ${message}    No blue test books were found.
