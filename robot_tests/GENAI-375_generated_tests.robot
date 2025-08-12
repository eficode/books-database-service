*** Settings ***
Documentation    This test suite verifies the search functionality for books by a specific author.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search for books by a specific author
    [Documentation]    Verify that searching for books by a specific author returns a list of books.
    [Tags]    req-GENAI-373    type-ok
    Given I am a book-loving customer
    When I enter the author's name in the search bar
    Then I should see a list of books written by that author

Search for books by a specific author with no results
    [Documentation]    Verify that searching for books by a non-existent author returns no results.
    [Tags]    req-GENAI-373    type-nok
    Given I am a book-loving customer
    When I enter the author's name in the search bar
    And the author's name does not exist in the database
    Then I should see a message indicating that no books were found

No books found for the author's name
    [Documentation]    Verify that searching for a non-existent author returns a no books found message.
    [Tags]    req-GENAI-373    type-ok
    Given I am a book-loving customer
    When I enter an author's name that does not exist in the database
    Then I should see a message indicating that no books were found

No books found for the author's name with results
    [Documentation]    Verify that searching for a non-existent author but with existing books returns a list of books.
    [Tags]    req-GENAI-373    type-nok
    Given I am a book-loving customer
    When I enter an author's name that does not exist in the database
    And the author's name exists in the database
    Then I should see a list of books written by that author

*** Keywords ***
I am a book-loving customer
    New Browser    headless=False
    New Context
    New Page    ${URL}

I enter the author's name in the search bar
    Click    id=search-bar
    Type Text    id=search-bar    ${author_name}
    Click    id=search-button

I should see a list of books written by that author
    Wait For Elements State    css=.book-list    visible
    ${books}=    Get Elements    css=.book-list .book-item
    Should Be True    ${books} != []

The author's name does not exist in the database
    Set Variable    ${author_name}    NonExistentAuthor

I should see a message indicating that no books were found
    Wait For Elements State    css=.no-results-message    visible
    Get Text    css=.no-results-message    ==    No books found

An author's name that does not exist in the database
    Set Variable    ${author_name}    NonExistentAuthor

The author's name exists in the database
    Set Variable    ${author_name}    ExistingAuthor
