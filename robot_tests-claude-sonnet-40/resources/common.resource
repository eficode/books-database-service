*** Settings ***
Documentation    Common variables and settings for Books Library tests
Library          Browser
Library          RequestsLibrary
Library          Collections
Library          String
Library          OperatingSystem

*** Variables ***
# Application URLs - configurable via environment or command line
${BASE_URL}              http://localhost:8000
${API_BASE_URL}          ${BASE_URL}/books
${UI_URL}                ${BASE_URL}

# Browser settings
${BROWSER}               chromium
${HEADLESS}              True
${TIMEOUT}               10s
${SLOW_TIMEOUT}          30s

# Test data
${TEST_BOOK_TITLE}       Test Book Title
${TEST_BOOK_AUTHOR}      Test Author
${TEST_BOOK_PAGES}       250
${TEST_BOOK_CATEGORY}    Fiction

# UI Selectors based on actual HTML structure
${TITLE_INPUT}           id=title
${AUTHOR_INPUT}          id=author
${PAGES_INPUT}           id=pages
${CATEGORY_SELECT}       id=category
${ADD_BOOK_BUTTON}       css=#book-form button[type="submit"]
${BOOKS_GRID}            id=books-list
${SEARCH_INPUT}          id=search-input
${SEARCH_BUTTON}         id=search-btn
${CATEGORY_FILTER}       id=category-filter
${FAVORITE_FILTER}       id=favorite-filter
${ALL_BOOKS_FILTER}      id=all-books-filter
${SORT_BY_SELECT}        id=sort-by
${SORT_DIRECTION_BTN}    id=sort-direction
${EDIT_MODAL}            id=edit-modal
${EDIT_TITLE_INPUT}      id=edit-title
${EDIT_AUTHOR_INPUT}     id=edit-author
${EDIT_PAGES_INPUT}      id=edit-pages
${EDIT_CATEGORY_SELECT}  id=edit-category
${EDIT_SAVE_BUTTON}      css=#edit-form button[type="submit"]
${MODAL_CLOSE}           css=.close

# Book card selectors
${BOOK_CARD}             css=.book-card
${BOOK_TITLE}            css=.book-title
${BOOK_AUTHOR}           css=.book-author
${BOOK_PAGES}            css=.book-pages
${BOOK_CATEGORY}         css=.book-category
${FAVORITE_BTN}          css=.favorite-btn
${EDIT_BTN}              css=.edit-btn
${DELETE_BTN}            css=.delete-btn

*** Keywords ***
Setup Test Environment
    [Documentation]    Setup both browser and API sessions for comprehensive testing
    Setup Browser Session
    Setup API Session

Teardown Test Environment
    [Documentation]    Cleanup both browser and API sessions
    Teardown Browser Session
    Teardown API Session

Setup Browser Session
    [Documentation]    Initialize browser session for UI tests
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page       ${UI_URL}
    Set Browser Timeout    ${TIMEOUT}

Teardown Browser Session
    [Documentation]    Close browser session
    Close Browser

Setup API Session
    [Documentation]    Initialize API session for API tests
    Create Session    books_api    ${BASE_URL}    timeout=30
    Set Suite Variable    ${API_SESSION}    books_api

Teardown API Session
    [Documentation]    Clean up API session
    Delete All Sessions

Generate Random Book Data
    [Documentation]    Generate random book data for testing
    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${title}=    Set Variable    Test Book ${random_suffix}
    ${author}=    Set Variable    Test Author ${random_suffix}
    ${pages}=    Evaluate    random.randint(100, 500)    random
    ${categories}=    Create List    Fiction    Non-Fiction    Fantasy    Science Fiction    Mystery    Thriller    Horror    Romance
    ${category}=    Evaluate    random.choice($categories)    random
    
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    
    RETURN    ${book_data}

Clean Up Test Data
    [Documentation]    Clean up test data by deleting all books via API
    TRY
        # Ensure API session exists
        ${session_exists}=    Run Keyword And Return Status    GET On Session    books_api    /books
        IF    not ${session_exists}
            Create Session    books_api    ${BASE_URL}    timeout=30
        END
        
        # Use fully qualified keyword names to avoid conflicts
        ${response}=    GET On Session    books_api    /books
        Should Be Equal As Strings    ${response.status_code}    200
        ${books}=    Set Variable    ${response.json()}
        
        FOR    ${book}    IN    @{books}
            ${delete_response}=    DELETE On Session    books_api    /books/${book}[id]
            Should Be Equal As Strings    ${delete_response.status_code}    200
        END
        
        # Wait for UI to update if browser is active
        ${browser_active}=    Run Keyword And Return Status    Get Title
        IF    ${browser_active}
            Sleep    3s
            Reload
            Sleep    2s
        END
    EXCEPT
        Log    No books to clean up or API not available
    END

Wait For Application To Be Ready
    [Documentation]    Wait for the application to be fully loaded and ready
    Wait For Elements State    css=h1    visible    timeout=${SLOW_TIMEOUT}
    Wait For Elements State    ${BOOKS_GRID}    visible    timeout=${TIMEOUT}
    # Wait for any initial data loading
    Sleep    2s