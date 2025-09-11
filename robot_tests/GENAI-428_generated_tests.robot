*** Settings ***
Documentation    This test suite verifies the search functionality of the bookstore application.
Library          Browser

*** Variables ***
${BOOKSTORE_URL}    https://example.com/bookstore

*** Test Cases ***
Search for a book by title - successful scenario
    [Documentation]    Verify that searching for a book by title returns a list of matching books.
    [Tags]    req-GENAI-426    type-ok
    Given I am on the bookstore search page
    When I enter a book title in the search bar
    And I click the search button
    Then I should see a list of books matching the title

Search for a book by title with no results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by title that does not exist returns a no results message.
    [Tags]    req-GENAI-426    type-nok
    Given I am on the bookstore search page
    When I enter a book title in the search bar that is not in found in the store
    And I click the search button
    Then I should see a message indicating no books were found

Search for a book by author - successful scenario
    [Documentation]    Verify that searching for a book by author returns a list of books written by that author.
    [Tags]    req-GENAI-426    type-ok
    Given I am on the bookstore search page
    When I enter an author's name in the search bar
    And I click the search button
    Then I should see a list of books written by that author

Search for a book by author with no results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by author that does not exist returns a no results message.
    [Tags]    req-GENAI-426    type-nok
    Given I am on the bookstore search page
    When I enter an author's name in the search bar
    And I click the search button
    Then I should see a message indicating no books were found

Search for a book by ISBN - successful scenario
    [Documentation]    Verify that searching for a book by ISBN returns the book matching the ISBN.
    [Tags]    req-GENAI-426    type-ok
    Given I am on the bookstore search page
    When I enter a book's ISBN in the search bar
    And I click the search button
    Then I should see the book matching the ISBN

Search for a book by ISBN with no results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by ISBN that does not exist returns a no results message.
    [Tags]    req-GENAI-426    type-nok
    Given I am on the bookstore search page
    When I enter a book's ISBN in the search bar
    And I click the search button
    Then I should see a message indicating no books were found

*** Keywords ***
I am on the bookstore search page
    New Page    ${BOOKSTORE_URL}

I enter a book title in the search bar
    Fill Text    id=search-bar    My Book Title

I enter a book title in the search bar that is not in found in the store
    Fill Text    id=search-bar    Nonexistent Book Title

I enter an author's name in the search bar
    Fill Text    id=search-bar    Author Name

I enter a book's ISBN in the search bar
    Fill Text    id=search-bar    1234567890

I click the search button
    Click    id=search-button

I should see a list of books matching the title
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list
    Should Contain    ${text}    My Book Title

I should see a list of books written by that author
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list
    Should Contain    ${text}    Author Name

I should see the book matching the ISBN
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list
    Should Contain    ${text}    1234567890

I should see a message indicating no books were found
    Wait For Elements State    css=.no-results-message    visible
    Get Text    css=.no-results-message
    Should Contain    ${text}    No books found
