*** Settings ***
Documentation    This test suite verifies the book search functionality by title, author, and ISBN.
Library          Browser

*** Variables ***
${URL}           http://example.com
${SEARCH_BAR}    //input[@id='search-bar']
${SEARCH_BUTTON} //button[@id='search-button']
${RESULT_LIST}   //div[@id='result-list']
${NO_RESULTS}    //div[@id='no-results']

*** Test Cases ***
Search for a book by title - successful scenario
    [Documentation]    Verify that searching for a book by title returns a list of matching books.
    [Tags]    req-GENAI-417    type-ok
    Given I am an end customer
    When I enter a book title in the search bar
    Then I should see a list of books matching the title

Search for a book by title - unsuccessful scenario
    [Documentation]    Verify that searching for a non-existent book title returns a no books found message.
    [Tags]    req-GENAI-417    type-nok
    Given I am an end customer
    When I enter a book title in the search bar
    And the title does not exist in the database
    Then I should see a message indicating no books were found

Search for a book by author - successful scenario
    [Documentation]    Verify that searching for a book by author returns a list of books written by that author.
    [Tags]    req-GENAI-417    type-ok
    Given I am an end customer
    When I enter an author's name in the search bar
    Then I should see a list of books written by that author

Search for a book by author - unsuccessful scenario
    [Documentation]    Verify that searching for a non-existent author returns a no books found message.
    [Tags]    req-GENAI-417    type-nok
    Given I am an end customer
    When I enter an author's name in the search bar
    And the author does not exist in the database
    Then I should see a message indicating no books were found

Search for a book by ISBN - successful scenario
    [Documentation]    Verify that searching for a book by ISBN returns the book matching that ISBN.
    [Tags]    req-GENAI-417    type-ok
    Given I am an end customer
    When I enter a book's ISBN in the search bar
    Then I should see the book matching that ISBN

Search for a book by ISBN - unsuccessful scenario
    [Documentation]    Verify that searching for a non-existent ISBN returns a no books found message.
    [Tags]    req-GENAI-417    type-nok
    Given I am an end customer
    When I enter a book's ISBN in the search bar
    And the ISBN does not exist in the database
    Then I should see a message indicating no books were found

*** Keywords ***
I am an end customer
    New Browser    headless=False
    Go To    ${URL}

I enter a book title in the search bar
    Type Text    ${SEARCH_BAR}    The Great Gatsby
    Click    ${SEARCH_BUTTON}

I enter an author's name in the search bar
    Type Text    ${SEARCH_BAR}    F. Scott Fitzgerald
    Click    ${SEARCH_BUTTON}

I enter a book's ISBN in the search bar
    Type Text    ${SEARCH_BAR}    9780743273565
    Click    ${SEARCH_BUTTON}

I should see a list of books matching the title
    Wait For Elements State    ${RESULT_LIST}    visible
    Get Element Count    ${RESULT_LIST}    >    0

I should see a list of books written by that author
    Wait For Elements State    ${RESULT_LIST}    visible
    Get Element Count    ${RESULT_LIST}    >    0

I should see the book matching that ISBN
    Wait For Elements State    ${RESULT_LIST}    visible
    Get Element Count    ${RESULT_LIST}    ==    1

The title does not exist in the database
    Set Variable    ${SEARCH_BAR}    NonExistentTitle

The author does not exist in the database
    Set Variable    ${SEARCH_BAR}    NonExistentAuthor

The ISBN does not exist in the database
    Set Variable    ${SEARCH_BAR}    0000000000000

I should see a message indicating no books were found
    Wait For Elements State    ${NO_RESULTS}    visible
