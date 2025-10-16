*** Settings ***
Documentation    Common resource file containing shared variables, keywords and configurations
Library    Browser
Library    RequestsLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DateTime

*** Variables ***
# Application URLs
${BASE_URL}    http://localhost:8000
${API_BASE_URL}    ${BASE_URL}/books
${UI_URL}    ${BASE_URL}

# Browser Configuration
${BROWSER}    chromium
${HEADLESS}    ${True}
${VIEWPORT_WIDTH}    1920
${VIEWPORT_HEIGHT}    1080

# Test Data
${VALID_BOOK_TITLE}    Test Automation with Robot Framework
${VALID_BOOK_AUTHOR}    Test Author
${VALID_BOOK_PAGES}    250
${VALID_BOOK_CATEGORY}    Science Fiction

${UPDATED_BOOK_TITLE}    Updated Test Book
${UPDATED_BOOK_AUTHOR}    Updated Author
${UPDATED_BOOK_PAGES}    300
${UPDATED_BOOK_CATEGORY}    Fantasy

# UI Selectors
${ADD_BOOK_FORM}    id=book-form
${TITLE_INPUT}    id=title
${AUTHOR_INPUT}    id=author
${PAGES_INPUT}    id=pages
${CATEGORY_SELECT}    id=category
${ADD_BOOK_BUTTON}    css=button:has-text("Add Book")
${BOOKS_LIST}    id=books-list
${SEARCH_INPUT}    id=search-input
${CATEGORY_FILTER}    id=category-filter
${FAVORITE_FILTER}    id=favorite-filter
${ALL_BOOKS_FILTER}    id=all-books-filter
${SORT_BY_SELECT}    id=sort-by
${SORT_DIRECTION_BTN}    id=sort-direction
${LOAD_MORE_BUTTON}    id=load-more

# Modal selectors
${EDIT_MODAL}    id=edit-modal
${EDIT_FORM}    id=edit-form
${EDIT_TITLE_INPUT}    id=edit-title
${EDIT_AUTHOR_INPUT}    id=edit-author
${EDIT_PAGES_INPUT}    id=edit-pages
${EDIT_CATEGORY_SELECT}    id=edit-category
${MODAL_CLOSE_BUTTON}    css=.close

# Timeouts
${DEFAULT_TIMEOUT}    10s
${LONG_TIMEOUT}    30s
${SHORT_TIMEOUT}    5s

*** Keywords ***
Setup Browser Session
    [Documentation]    Initialize browser session with common settings
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Context    viewport={'width': ${VIEWPORT_WIDTH}, 'height': ${VIEWPORT_HEIGHT}}
    New Page    ${UI_URL}

Teardown Browser Session
    [Documentation]    Close browser session and cleanup
    Close Browser

Wait For Application To Load
    [Documentation]    Wait for the main application elements to be visible
    Wait For Elements State    css=h1    visible    timeout=${DEFAULT_TIMEOUT}
    Wait For Elements State    ${ADD_BOOK_FORM}    visible    timeout=${DEFAULT_TIMEOUT}
    Wait For Elements State    ${BOOKS_LIST}    visible    timeout=${DEFAULT_TIMEOUT}

Setup API Session
    [Documentation]    Initialize API session for testing
    Create Session    books_api    ${BASE_URL}    verify=True

Teardown API Session
    [Documentation]    Clean up API session
    Delete All Sessions

Generate Random Book Data
    [Documentation]    Generate random book data for testing
    [Arguments]    ${prefix}=Test
    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${title}=    Set Variable    ${prefix} Book ${random_suffix}
    ${author}=    Set Variable    ${prefix} Author ${random_suffix}
    ${pages}=    Evaluate    random.randint(50, 500)    modules=random
    ${categories}=    Create List    Fiction    Non-Fiction    Fantasy    Science Fiction    Mystery    Thriller    Horror    Romance    Historical Fiction    Biography    Self-Help    Business    Science    History    Poetry    Children's Books    Young Adult    Travel    Cookbooks    Philosophy
    ${category}=    Evaluate    random.choice($categories)    modules=random
    ${book_data}=    Create Dictionary    title=${title}    author=${author}    pages=${pages}    category=${category}    favorite=${False}
    RETURN    ${book_data}

Verify Book Card Elements
    [Documentation]    Verify that a book card contains all expected elements
    [Arguments]    ${book_card}    ${expected_title}    ${expected_author}    ${expected_pages}    ${expected_category}
    ${title_element}=    Get Element    ${book_card} >> css=.book-title
    ${author_element}=    Get Element    ${book_card} >> css=.book-author
    ${pages_element}=    Get Element    ${book_card} >> css=.book-pages
    ${category_element}=    Get Element    ${book_card} >> css=.book-category
    
    Get Text    ${title_element}    ==    ${expected_title}
    Get Text    ${author_element}    contains    ${expected_author}
    Get Text    ${pages_element}    contains    ${expected_pages}
    Get Text    ${category_element}    ==    ${expected_category}

Wait For Books To Load
    [Documentation]    Wait for books to be loaded and displayed
    Wait For Elements State    ${BOOKS_LIST}    visible    timeout=${DEFAULT_TIMEOUT}
    Sleep    1s    # Allow time for dynamic content to load

Clear All Books Via API
    [Documentation]    Clear all books from the database via API (for test cleanup)
    ${response}=    GET On Session    books_api    /books/
    Should Be Equal As Strings    ${response.status_code}    200
    ${books}=    Set Variable    ${response.json()}
    FOR    ${book}    IN    @{books}
        DELETE On Session    books_api    /books/${book}[id]
    END

Verify No Books Message
    [Documentation]    Verify that the "no books" message is displayed
    Wait For Elements State    css=.no-books    visible    timeout=${DEFAULT_TIMEOUT}
    Get Text    css=.no-books    contains    No books found

Take Screenshot On Failure
    [Documentation]    Take a screenshot when a test fails
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Take Screenshot    filename=failure_${timestamp}

Log Browser Console
    [Documentation]    Log browser console messages for debugging
    ${console_logs}=    Get Console Log
    Log    Browser Console Messages: ${console_logs}