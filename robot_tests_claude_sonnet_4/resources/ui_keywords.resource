*** Settings ***
Documentation    UI keywords for Books Database Service
Resource         common.resource

*** Keywords ***
Open Books Application
    [Documentation]    Open the books application in browser
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS}
    New Page    ${BASE_URL}
    Wait For Element To Be Visible    h1

Close Books Application
    [Documentation]    Close the browser
    Close Browser

Fill Book Form
    [Documentation]    Fill the book creation form
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Fill Text    id=title    ${title}
    Fill Text    id=author    ${author}
    Fill Text    id=pages    ${pages}
    Select Options By    id=category    text    ${category}

Submit Book Form
    [Documentation]    Submit the book creation form
    Click    button[type="submit"]

Search For Books
    [Documentation]    Search for books using search input
    [Arguments]    ${search_term}
    Fill Text    id=search-input    ${search_term}
    Sleep    1s    # Wait for debounce

Filter Books By Category
    [Documentation]    Filter books by category
    [Arguments]    ${category}
    Select Options By    id=category-filter    text    ${category}

Sort Books By Field
    [Documentation]    Sort books by specified field
    [Arguments]    ${field}
    Select Options By    id=sort-by    text    ${field}

Toggle Sort Direction
    [Documentation]    Toggle sort direction
    Click    id=sort-direction

Click Favorite Filter
    [Documentation]    Click favorite filter button
    Click    id=favorite-filter

Click All Books Filter
    [Documentation]    Click all books filter button
    Click    id=all-books-filter

Verify Book Card Exists
    [Documentation]    Verify that a book card exists with given title
    [Arguments]    ${title}
    ${locator}=    Set Variable    .book-card:has-text("${title}")
    Wait For Element To Be Visible    ${locator}

Verify Book Card Does Not Exist
    [Documentation]    Verify that a book card does not exist with given title
    [Arguments]    ${title}
    ${locator}=    Set Variable    .book-card:has-text("${title}")
    Get Element Count    ${locator}    ==    0

Click Edit Book Button
    [Documentation]    Click edit button for a specific book
    [Arguments]    ${title}
    ${locator}=    Set Variable    .book-card:has-text("${title}") .edit-btn
    Click    ${locator}

Click Delete Book Button
    [Documentation]    Click delete button for a specific book
    [Arguments]    ${title}
    ${locator}=    Set Variable    .book-card:has-text("${title}") .delete-btn
    Click    ${locator}

Click Favorite Button For Book
    [Documentation]    Click favorite button for a specific book
    [Arguments]    ${title}
    ${locator}=    Set Variable    .book-card:has-text("${title}") .favorite-btn
    Click    ${locator}

Verify Page Title
    [Documentation]    Verify the page title
    [Arguments]    ${expected_title}
    Get Title    ==    ${expected_title}

Verify Books Count Display
    [Documentation]    Verify the books count display
    [Arguments]    ${expected_shown}    ${expected_total}
    ${shown_text}=    Get Text    id=shown-count
    ${total_text}=    Get Text    id=total-count
    Should Be Equal    ${shown_text}    ${expected_shown}
    Should Be Equal    ${total_text}    ${expected_total}

Verify Form Field Value
    [Documentation]    Verify form field has expected value
    [Arguments]    ${field_id}    ${expected_value}
    ${actual_value}=    Get Property    id=${field_id}    value
    Should Be Equal    ${actual_value}    ${expected_value}

Wait For Books To Load
    [Documentation]    Wait for books to load in the UI
    Wait For Element To Be Visible    id=books-list
    Sleep    2s    # Wait for API call to complete

Verify Notification Message
    [Documentation]    Verify notification message appears
    [Arguments]    ${expected_message}
    Wait For Element To Be Visible    .notification
    ${notification_text}=    Get Text    .notification
    Should Contain    ${notification_text}    ${expected_message}