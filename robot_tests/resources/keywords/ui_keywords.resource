*** Settings ***
Documentation    UI-specific keywords for Books Database Service
Resource         ../common.resource

*** Keywords ***
Open Books Application
    [Documentation]    Open the books application in browser
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Page    ${BASE_URL}
    Wait For Elements State    h1    visible    timeout=${TIMEOUT}

Navigate To Books Page
    [Documentation]    Navigate to the main books page
    Go To    ${BASE_URL}
    Wait For Elements State    [data-testid="books-container"]    visible    timeout=${TIMEOUT}

Add New Book
    [Documentation]    Add a new book with given details
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Wait For Element And Click    [data-testid="add-book-button"]
    Wait For Element And Type    [data-testid="book-title-input"]    ${title}
    Wait For Element And Type    [data-testid="book-author-input"]    ${author}
    Wait For Element And Type    [data-testid="book-pages-input"]    ${pages}
    Select Options By    [data-testid="book-category-select"]    text    ${category}
    Wait For Element And Click    [data-testid="save-book-button"]

Search For Book
    [Documentation]    Search for a book by title
    [Arguments]    ${search_term}
    Wait For Element And Type    [data-testid="search-input"]    ${search_term}
    Wait For Elements State    [data-testid="book-item"]    visible    timeout=${TIMEOUT}

Filter Books By Category
    [Documentation]    Filter books by category
    [Arguments]    ${category}
    Wait For Element And Click    [data-testid="category-filter"]
    Wait For Element And Click    [data-testid="category-${category}"]

Toggle Book Favorite
    [Documentation]    Toggle favorite status of a book
    [Arguments]    ${book_title}
    ${book_locator}=    Set Variable    [data-testid="book-${book_title}"]
    Wait For Element And Click    ${book_locator} [data-testid="favorite-button"]

Verify Book Is Displayed
    [Documentation]    Verify that a book is displayed in the list
    [Arguments]    ${title}    ${author}
    ${book_locator}=    Set Variable    [data-testid="book-item"]:has-text("${title}")
    Wait For Elements State    ${book_locator}    visible    timeout=${TIMEOUT}
    Verify Element Contains Text    ${book_locator}    ${author}

Verify Book Count
    [Documentation]    Verify the number of books displayed
    [Arguments]    ${expected_count}
    ${count}=    Get Element Count    [data-testid="book-item"]
    Should Be Equal As Numbers    ${count}    ${expected_count}

Delete Book
    [Documentation]    Delete a book from the list
    [Arguments]    ${book_title}
    ${book_locator}=    Set Variable    [data-testid="book-${book_title}"]
    Wait For Element And Click    ${book_locator} [data-testid="delete-button"]
    Wait For Element And Click    [data-testid="confirm-delete-button"]