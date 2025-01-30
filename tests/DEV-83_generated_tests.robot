*** Settings ***
Documentation    Test suite for searching books by color
Library          Browser

*** Variables ***
${SEARCH_URL}    http://example.com/search

*** Test Cases ***
Search books by a specific color - successful scenario
    [Documentation]    Search books by a specific color - successful scenario
    [Tags]    req-DEV-83    type-ok
    Given I am a product owner
    When I search for books by color    red
    Then I should see a list of books that have the color    red

Search books by a specific color - unsuccessful scenario
    [Documentation]    Search books by a specific color - unsuccessful scenario
    [Tags]    req-DEV-83    type-nok
    Given I am a product owner
    And I search for books by color    red
    When the search functionality is down
    Then I should see an error message indicating the search service is unavailable

No books found for a specific color - successful scenario
    [Documentation]    No books found for a specific color - successful scenario
    [Tags]    req-DEV-83    type-ok
    Given I am a product owner
    When I search for books by color    purple
    Then I should see a message indicating no books were found with the color    purple

No books found for a specific color - unsuccessful scenario
    [Documentation]    No books found for a specific color - unsuccessful scenario
    [Tags]    req-DEV-83    type-nok
    Given I am a product owner
    And I search for books by color    purple
    When the search functionality is down
    Then I should see an error message indicating the search service is unavailable

*** Keywords ***
I am a product owner
    New Browser    headless=False
    New Context
    New Page
    Go To    ${SEARCH_URL}

I search for books by color
    [Arguments]    ${color}
    Fill Text    input[name="color"]    ${color}
    Click    button[type="submit"]

I should see a list of books that have the color
    [Arguments]    ${color}
    Wait For Elements State    css=div.book-item[data-color="${color}"]    visible
    ${books}=    Get Elements    css=div.book-item[data-color="${color}"]
    Should Not Be Empty    ${books}

The search functionality is down
    # Simulate Network Failure
    # Placeholder for network failure simulation
    Log    Simulating network failure

I should see an error message indicating the search service is unavailable
    Wait For Elements State    css=div.error-message    visible
    Get Text    css=div.error-message    ==    Search service is unavailable

I should see a message indicating no books were found with the color
    [Arguments]    ${color}
    Wait For Elements State    css=div.no-books-message    visible
    Get Text    css=div.no-books-message    ==    No books found with the color ${color}
