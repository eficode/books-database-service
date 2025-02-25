*** Settings ***
Documentation     CRUD operations tests for Books Database Service
Resource          resources/common.resource
Suite Setup       Setup Test Environment
Suite Teardown    Teardown Test Environment
Test Tags         ui    browser    crud

*** Variables ***
${BOOK_TITLE}         War and Peace
${BOOK_AUTHOR}        Leo Tolstoy
${BOOK_PAGES}         1225
${BOOK_CATEGORY}      Historical Fiction

${EDITED_TITLE}       War and Peace (Revised)
${EDITED_AUTHOR}      Leo Tolstoy
${EDITED_PAGES}       1240
${EDITED_CATEGORY}    Fiction

*** Test Cases ***
Create New Book
    [Documentation]    Create a new book and verify it appears in the list
    Add New Book    ${BOOK_TITLE}    ${BOOK_AUTHOR}    ${BOOK_PAGES}    ${BOOK_CATEGORY}
    Book Should Exist    ${BOOK_TITLE}
    
    # Verify book details are displayed correctly
    Wait For Elements State    .book-card:has(.book-title:has-text("${BOOK_TITLE}"))    visible
    Get Text    .book-card:has(.book-title:has-text("${BOOK_TITLE}")) .book-author    contains    ${BOOK_AUTHOR}
    Get Text    .book-card:has(.book-title:has-text("${BOOK_TITLE}")) .book-pages    contains    ${BOOK_PAGES}
    Get Text    .book-card:has(.book-title:has-text("${BOOK_TITLE}")) .book-category    contains    ${BOOK_CATEGORY}

Read Book Details
    [Documentation]    Search for a book and verify its details
    Search For Book    ${BOOK_TITLE}
    Book Should Exist    ${BOOK_TITLE}
    
    # Verify search results
    ${results_count}=    Get Text    #shown-count
    Should Be Equal    ${results_count}    1
    
    # Verify book details shown correctly in search results
    Get Text    .book-card:has(.book-title:has-text("${BOOK_TITLE}")) .book-author    contains    ${BOOK_AUTHOR}
    Get Text    .book-card:has(.book-title:has-text("${BOOK_TITLE}")) .book-pages    contains    ${BOOK_PAGES}
    Get Text    .book-card:has(.book-title:has-text("${BOOK_TITLE}")) .book-category    contains    ${BOOK_CATEGORY}

Update Book
    [Documentation]    Edit a book and verify the changes
    Edit Book    ${BOOK_TITLE}    ${EDITED_TITLE}    ${EDITED_AUTHOR}    ${EDITED_PAGES}    ${EDITED_CATEGORY}
    
    # Verify book with new title exists
    Book Should Exist    ${EDITED_TITLE}
    
    # Verify updated details
    Get Text    .book-card:has(.book-title:has-text("${EDITED_TITLE}")) .book-author    contains    ${EDITED_AUTHOR}
    Get Text    .book-card:has(.book-title:has-text("${EDITED_TITLE}")) .book-pages    contains    ${EDITED_PAGES}
    Get Text    .book-card:has(.book-title:has-text("${EDITED_TITLE}")) .book-category    contains    ${EDITED_CATEGORY}
    
    # Verify old title doesn't exist
    Search For Book    ${BOOK_TITLE}
    Wait For Elements State    text=No books found    visible    timeout=5s

Delete Book
    [Documentation]    Delete a book and verify it is removed
    # First search for the edited book
    Fill Text    id=search-input    ${EMPTY}
    Click    id=search-btn
    Search For Book    ${EDITED_TITLE}
    
    # Delete the book
    Delete Book    ${EDITED_TITLE}
    
    # Verify the book is deleted
    Search For Book    ${EDITED_TITLE}
    Wait For Elements State    text=No books found    visible    timeout=5s

