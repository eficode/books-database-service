*** Settings ***
Documentation    This test suite verifies the book search functionality on the website.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search by Title - successful scenario
    [Documentation]    Verify that searching for a book by its title returns matching results.
    [Tags]    req-GENAI-423    type-ok
    Given I am a customer
    When I search for a book by its title
    Then I should see a list of books matching that title

Search by Title with no matching results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by its title with no matches returns a no results message.
    [Tags]    req-GENAI-423    type-nok
    Given I am a customer
    When I search for a book by its title
    And there are no books matching that title
    Then I should see a message indicating no results found

Search by Author - successful scenario
    [Documentation]    Verify that searching for a book by its author returns books written by that author.
    [Tags]    req-GENAI-423    type-ok
    Given I am a customer
    When I search for a book by its author
    Then I should see a list of books written by that author

Search by Author with no matching results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by its author with no matches returns a no results message.
    [Tags]    req-GENAI-423    type-nok
    Given I am a customer
    When I search for a book by its author
    And there are no books written by that author
    Then I should see a message indicating no results found

Search by Genre - successful scenario
    [Documentation]    Verify that searching for a book by its genre returns books that belong to that genre.
    [Tags]    req-GENAI-423    type-ok
    Given I am a customer
    When I search for a book by its genre
    Then I should see a list of books that belong to that genre

Search by Genre with no matching results - unsuccessful scenario
    [Documentation]    Verify that searching for a book by its genre with no matches returns a no results message.
    [Tags]    req-GENAI-423    type-nok
    Given I am a customer
    When I search for a book by its genre
    And there are no books that belong to that genre
    Then I should see a message indicating no results found

*** Keywords ***
I am a customer
    New Browser    headless=False
    New Page    ${URL}

I search for a book by its title
    Click    id=search-bar
    Fill Text    id=search-bar    Some Book Title
    Click    id=search-button

I should see a list of books matching that title
    Wait For Elements State    css=.book-list    visible
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []

There are no books matching that title
    Wait For Elements State    css=.no-results    visible

I should see a message indicating no results found
    Wait For Elements State    css=.no-results    visible

I search for a book by its author
    Click    id=search-bar
    Fill Text    id=search-bar    Some Author
    Click    id=search-button

I should see a list of books written by that author
    Wait For Elements State    css=.book-list    visible
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []

There are no books written by that author
    Wait For Elements State    css=.no-results    visible

I search for a book by its genre
    Click    id=search-bar
    Fill Text    id=search-bar    Some Genre
    Click    id=search-button

I should see a list of books that belong to that genre
    Wait For Elements State    css=.book-list    visible
    ${books}=    Get Elements    css=.book-item
    Should Be True    ${books} != []

There are no books that belong to that genre
    Wait For Elements State    css=.no-results    visible
