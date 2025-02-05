*** Settings ***
Documentation    This test suite verifies the search, filter, and sort functionalities for best-selling books.
Library          Browser

*** Variables ***
${URL}           https://example.com

*** Test Cases ***
Search for best-selling books - successful scenario
    [Documentation]    Verify that a product owner can search for best-selling books and see relevant details.
    [Tags]    req-GENAI-73    type-ok
    Given I am a product owner
    When I search for best-selling books
    Then I should see a list of best-selling books with relevant details

Search for best-selling books with no results - unsuccessful scenario
    [Documentation]    Verify that a product owner sees a no results message when no best-selling books are available.
    [Tags]    req-GENAI-73    type-nok
    Given I am a product owner
    When I search for best-selling books
    And there are no best-selling books available
    Then I should see a message indicating no results found

Filter search results - successful scenario
    [Documentation]    Verify that search results can be filtered by genre, publication date, and author.
    [Tags]    req-GENAI-73    type-ok
    Given I have searched for best-selling books
    When I apply filters (e.g., genre, publication date, author)
    Then the search results should be updated accordingly

Filter search results with no matching criteria - unsuccessful scenario
    [Documentation]    Verify that a no results message is shown when no books match the filter criteria.
    [Tags]    req-GENAI-73    type-nok
    Given I have searched for best-selling books
    When I apply filters (e.g., genre, publication date, author)
    And no books match the filter criteria
    Then I should see a message indicating no results found

Sort search results - successful scenario
    [Documentation]    Verify that search results can be sorted by sales and ratings.
    [Tags]    req-GENAI-73    type-ok
    Given I have searched for best-selling books
    When I sort the results by criteria (e.g., sales, ratings)
    Then I should see the search results sorted accordingly

Sort search results with invalid criteria - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when sorting by an invalid criteria.
    [Tags]    req-GENAI-73    type-nok
    Given I have searched for best-selling books
    When I sort the results by an invalid criteria
    Then I should see an error message indicating invalid sort criteria

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
    Get Element    css=.book-item

There are no best-selling books available
    Evaluate    document.querySelector('.book-list').innerHTML = ''

I should see a message indicating no results found
    Wait For Elements State    text=No results found    visible
    Get Element    text=No results found

I have searched for best-selling books
    I am a product owner
    I search for best-selling books

I apply filters (e.g., genre, publication date, author)
    Click    text=Filters
    Click    text=Genre
    Click    text=Apply
    Wait For Elements State    css=.filtered-book-list    visible

The search results should be updated accordingly
    Wait For Elements State    css=.filtered-book-list    visible
    Get Element    css=.filtered-book-item

No books match the filter criteria
    Evaluate    document.querySelector('.filtered-book-list').innerHTML = ''

I should see a message indicating no results found
    Wait For Elements State    text=No results found    visible
    Get Element    text=No results found

I sort the results by criteria (e.g., sales, ratings)
    Click    text=Sort By
    Click    text=Sales
    Wait For Elements State    css=.sorted-book-list    visible

The search results should be sorted accordingly
    Wait For Elements State    css=.sorted-book-list    visible
    Get Element    css=.sorted-book-item

I sort the results by an invalid criteria
    Click    text=Sort By
    Click    text=Invalid

I should see an error message indicating invalid sort criteria
    Wait For Elements State    text=Invalid sort criteria    visible
    Get Element    text=Invalid sort criteria
