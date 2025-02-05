*** Settings ***
Documentation    This test suite verifies the search and filter functionalities for best-selling books.
Library          Browser

*** Variables ***
${URL}           https://example.com

*** Test Cases ***
Search for best-selling books - successful scenario
    [Documentation]    Verify that a product owner can search for best-selling books and see relevant details.
    [Tags]    req-DEV-97    type-ok
    Given I am a product owner
    When I search for best-selling books
    Then I should see a list of best-selling books with relevant details

Search for best-selling books with no results - unsuccessful scenario
    [Documentation]    Verify that a product owner sees a message when no best-selling books are found.
    [Tags]    req-DEV-97    type-nok
    Given I am a product owner
    When I search for best-selling books
    And there are no best-selling books available
    Then I should see a message indicating that no best-selling books were found

Filter search results - successful scenario
    [Documentation]    Verify that a product owner can apply filters to refine the list of best-selling books.
    [Tags]    req-DEV-97    type-ok
    Given I have searched for best-selling books
    When I apply filters    genre=fiction    publication_date=2022
    Then I should see a refined list of best-selling books based on the applied filters

Filter search results with no matching filters - unsuccessful scenario
    [Documentation]    Verify that a product owner sees a message when no books match the applied filters.
    [Tags]    req-DEV-97    type-nok
    Given I have searched for best-selling books
    When I apply filters    genre=unknown    publication_date=1900
    And no books match the applied filters
    Then I should see a message indicating that no books match the applied filters

*** Keywords ***
I am a product owner
    New Browser    headless=False
    New Context
    New Page    ${URL}

I search for best-selling books
    Click    text=Best-Selling Books
    Wait For Elements State    text=Best-Selling Books    visible

I should see a list of best-selling books with relevant details
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list

There are no best-selling books available
    # Simulate no results by navigating to a specific URL or using a mock
    Go To    ${URL}/no-best-selling-books

I should see a message indicating that no best-selling books were found
    Wait For Elements State    text=No best-selling books found    visible
    Get Text    text=No best-selling books found

I have searched for best-selling books
    I am a product owner
    I search for best-selling books

I apply filters
    [Arguments]    ${genre}=${EMPTY}    ${publication_date}=${EMPTY}
    # Apply genre filter if provided
    Run Keyword If    '${genre}' != '${EMPTY}'    Click    text=${genre}
    # Apply publication date filter if provided
    Run Keyword If    '${publication_date}' != '${EMPTY}'    Click    text=${publication_date}
    Click    text=Apply Filters
    Wait For Elements State    css=.filtered-book-list    visible

No books match the applied filters
    # Simulate no matching results by navigating to a specific URL or using a mock
    Go To    ${URL}/no-matching-filters

I should see a message indicating that no books match the applied filters
    Wait For Elements State    text=No books match the applied filters    visible
    Get Text    text=No books match the applied filters

I should see a refined list of best-selling books based on the applied filters
    Wait For Elements State    css=.filtered-book-list    visible
    Get Text    css=.filtered-book-list
