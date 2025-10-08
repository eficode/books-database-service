*** Settings ***
Documentation    UI-specific keywords for Books Database Service
Resource         ../common.resource
Library          Browser

*** Keywords ***
Open Books Application
    [Documentation]    Open the books application in browser
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Page    ${BASE_URL}
    Wait For Elements State    h1    visible    timeout=${TIMEOUT}

Navigate To Books Page
    [Documentation]    Navigate to the main books page
    Go To    ${BASE_URL}
    Wait For Elements State    .books-container    visible    timeout=${TIMEOUT}

Add New Book
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Fill Text    #title    ${title}
    Fill Text    #author    ${author}
    Fill Text    #pages    ${pages}
    Select Options By    #category    text    ${category}
    Click    button[type="submit"]

Search For Book
    [Arguments]    ${search_term}
    Fill Text    #search-input    ${search_term}

Filter Books By Category
    [Arguments]    ${category}
    Select Options By    #category-filter    text    ${category}

Toggle Book Favorite
    [Arguments]    ${book_title}
    Click    .book-card:has-text("${book_title}") .favorite-btn

Delete Book
    [Arguments]    ${book_title}
    Handle Future Dialogs    action=accept
    Click    .book-card:has-text("${book_title}") .delete-btn