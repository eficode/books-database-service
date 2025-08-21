*** Settings ***
Documentation    This test suite verifies the functionality of selecting a genre to list books and handles various scenarios including successful and unsuccessful cases.
Library          Browser

*** Variables ***
${URL}           http://example.com
${GENRE}         Fiction
${NO_BOOKS_GENRE}  Unknown

*** Test Cases ***
User selects a genre to list books - successful scenario
    [Documentation]    Verify that selecting a genre lists the books of that genre.
    [Tags]    req-GENAI-405    type-ok
    Given I am a bookworm
    When I select a genre from the available options
    Then I should see a list of books that belong to the selected genre

User selects a genre to list books but no books are displayed - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when there is an issue with the backend API.
    [Tags]    req-GENAI-405    type-nok
    Given I am a bookworm
    When I select a genre from the available options
    And there is an issue with the backend API
    Then I should not see a list of books that belong to the selected genre
    And I should see an error message indicating a problem fetching books

No books available for the selected genre - successful scenario
    [Documentation]    Verify that a message is shown when no books are available for the selected genre.
    [Tags]    req-GENAI-405    type-ok
    Given I am a bookworm
    When I select a genre with no available books
    Then I should see a message indicating that no books are available for the selected genre

No books available for the selected genre but no message is displayed - unsuccessful scenario
    [Documentation]    Verify that a generic error message is shown when there is an issue with the frontend UI.
    [Tags]    req-GENAI-405    type-nok
    Given I am a bookworm
    When I select a genre with no available books
    And there is an issue with the frontend UI
    Then I should not see a message indicating that no books are available for the selected genre
    And I should see a generic error message

*** Keywords ***
I am a bookworm
    New Browser    headless=False
    New Page    ${URL}
    Wait For Elements State    //select[@id='genre']    visible

I select a genre from the available options
    Click    //select[@id='genre']
    Click    //option[text()='${GENRE}']
    Click    //button[@id='submit']

I should see a list of books that belong to the selected genre
    Wait For Elements State    //div[@id='book-list']    visible
    Get Text    //div[@id='book-list']/h2    ==    Books in ${GENRE}

There is an issue with the backend API
    # Simulate backend API issue
    Evaluate    window.simulateBackendIssue()    window

I should not see a list of books that belong to the selected genre
    Wait For Elements State    //div[@id='book-list']    hidden

I should see an error message indicating a problem fetching books
    Wait For Elements State    //div[@id='error-message']    visible
    Get Text    //div[@id='error-message']    ==    Error fetching books

I select a genre with no available books
    Click    //select[@id='genre']
    Click    //option[text()='${NO_BOOKS_GENRE}']
    Click    //button[@id='submit']

I should see a message indicating that no books are available for the selected genre
    Wait For Elements State    //div[@id='no-books-message']    visible
    Get Text    //div[@id='no-books-message']    ==    No books available for ${NO_BOOKS_GENRE}

There is an issue with the frontend UI
    # Simulate frontend UI issue
    Evaluate    window.simulateFrontendIssue()    window

I should not see a message indicating that no books are available for the selected genre
    Wait For Elements State    //div[@id='no-books-message']    hidden

I should see a generic error message
    Wait For Elements State    //div[@id='generic-error-message']    visible
    Get Text    //div[@id='generic-error-message']    ==    An error occurred
