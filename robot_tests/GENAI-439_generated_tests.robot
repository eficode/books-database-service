*** Settings ***
Documentation    This test suite verifies the search functionality on the book search page.
Library          Browser

*** Variables ***
${BOOK_SEARCH_URL}    http://example.com/book-search

*** Test Cases ***
Search for a book by title - successful scenario
    [Documentation]    Verify that searching for a book by title returns a list of matching books.
    [Tags]    req-GENAI-438    type-ok
    Given I am on the book search page
    When I enter a book title in the search bar
    And I click the search button
    Then I should see a list of books matching the title

Search for a book by title with no results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by title with no results shows an appropriate message.
    [Tags]    req-GENAI-438    type-nok
    Given I am on the book search page
    When I enter a book title in the search bar
    And I click the search button
    Then I should see a message indicating no books were found

Search for a book by author - successful scenario
    [Documentation]    Verify that searching for a book by author returns a list of books written by that author.
    [Tags]    req-GENAI-438    type-ok
    Given I am on the book search page
    When I enter an author's name in the search bar
    And I click the search button
    Then I should see a list of books written by that author

Search for a book by author with no results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by author with no results shows an appropriate message.
    [Tags]    req-GENAI-438    type-nok
    Given I am on the book search page
    When I enter an author's name in the search bar
    And I click the search button
    Then I should see a message indicating no books were found

Search for a book by ISBN - successful scenario
    [Documentation]    Verify that searching for a book by ISBN returns the book matching that ISBN.
    [Tags]    req-GENAI-438    type-ok
    Given I am on the book search page
    When I enter an ISBN in the search bar
    And I click the search button
    Then I should see the book matching that ISBN

Search for a book by invalid ISBN - unsuccessful scenario
    [Documentation]    Verify that searching for a book by invalid ISBN shows an appropriate message.
    [Tags]    req-GENAI-438    type-nok
    Given I am on the book search page
    When I enter an invalid ISBN in the search bar
    And I click the search button
    Then I should see a message indicating no books were found

*** Keywords ***
I am on the book search page
    New Page    ${BOOK_SEARCH_URL}

I enter a book title in the search bar
    Fill Text    id=search-bar    The Great Gatsby

I enter an author's name in the search bar
    Fill Text    id=search-bar    F. Scott Fitzgerald

I enter an ISBN in the search bar
    Fill Text    id=search-bar    9780743273565

I enter an invalid ISBN in the search bar
    Fill Text    id=search-bar    1234567890

I click the search button
    Click    id=search-button

I should see a list of books matching the title
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list .book-title
    Should Be Equal    ${text}    The Great Gatsby

I should see a list of books written by that author
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list .book-author
    Should Be Equal    ${text}    F. Scott Fitzgerald

I should see the book matching that ISBN
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list .book-isbn
    Should Be Equal    ${text}    9780743273565

I should see a message indicating no books were found
    Wait For Elements State    css=.no-results    visible
    Get Text    css=.no-results
    Should Be Equal    ${text}    No books found
