*** Settings ***
Documentation     Common resources for Books Database UI tests
Library           Browser
Library           DateTime
Library           String
Library           Collections
Library           Process

*** Variables ***
${BROWSER}        chromium
${HEADLESS}       True
${BASE_URL}       http://localhost:8000
${TIMEOUT}        20s
${DOCKER_UP_TIMEOUT}    30s

*** Keywords ***
Setup Test Environment
    Run Process    docker compose up -d    shell=True
    Wait Until Keyword Succeeds    ${DOCKER_UP_TIMEOUT}    2s    Check Service Available
    Open Books Application

Check Service Available
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Page       ${BASE_URL}
    Wait For Elements State    h1:has-text("Books Library")    visible    ${TIMEOUT}
    Close Browser

Open Books Application
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Page       ${BASE_URL}
    Wait For Elements State    h1:has-text("Books Library")    visible    ${TIMEOUT}
    
I Open The Books Application
    # This is handled by the suite setup which calls Open Books Application
    No Operation

I Should See The Books Library Title
    Wait For Elements State    h1:has-text("Books Library")    visible

I Should See The Add Book Button
    Wait For Elements State    text=Add a New Book    visible
    
I Should See The Books List Section
    Wait For Elements State    text=Your Books    visible

Close Books Application
    Close Browser

Teardown Test Environment
    Close Books Application
    Run Process    docker compose down    shell=True

Generate Random Book Data
    ${random_number}=    Generate Random String    4    [NUMBERS]
    ${title}=            Set Variable    Test Book ${random_number}
    ${author}=           Set Variable    Test Author ${random_number}
    ${pages}=            Set Variable    ${random_number}
    ${category}=         Set Variable    Fiction
    RETURN    ${title}    ${author}    ${pages}    ${category}

Add New Book
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Fill Text    id=title    ${title}
    Fill Text    id=author    ${author}
    Fill Text    id=pages    ${pages}
    Select Options By    id=category    text    ${category}
    Click    button:has-text("Add Book")
    Wait For Elements State    .notification.success    visible    ${TIMEOUT}

Search For Book
    [Arguments]    ${search_text}
    Fill Text    id=search-input    ${search_text}
    Click    id=search-btn

Filter By Category
    [Arguments]    ${category}
    Select Options By    id=category-filter    text    ${category}

Sort Books By
    [Arguments]    ${sort_by}
    Select Options By    id=sort-by    text    ${sort_by}

Book Should Exist
    [Arguments]    ${title}
    Wait For Elements State    .book-card h3.book-title:has-text("${title}")    visible    ${TIMEOUT}

Edit Book
    [Arguments]    ${original_title}    ${new_title}    ${new_author}    ${new_pages}    ${new_category}
    # Make sure we first wait for the book to be visible
    Wait For Elements State    .book-card h3.book-title:has-text("${original_title}")    visible    ${TIMEOUT}
    # Now click the edit button
    Sleep    1s
    Click    .book-card:has(h3.book-title:has-text("${original_title}")) .edit-btn
    # Wait for the modal to appear
    Wait For Elements State    .modal-content    visible    ${TIMEOUT}
    # Fill in the edit form
    Fill Text    id=edit-title    ${new_title}
    Fill Text    id=edit-author    ${new_author}
    Fill Text    id=edit-pages    ${new_pages}
    Select Options By    id=edit-category    text    ${new_category}
    # Submit the form
    Click    .modal-content button[type="submit"]
    # Wait for success notification
    Wait For Elements State    .notification.success    visible    ${TIMEOUT}

Delete Book
    [Arguments]    ${title}
    # Make sure we first wait for the book to be visible
    Wait For Elements State    .book-card h3.book-title:has-text("${title}")    visible    ${TIMEOUT}
    # Handle the confirmation dialog
    Handle Future Dialogs    action=accept
    # Now click the delete button
    Sleep    1s
    Click    .book-card:has(h3.book-title:has-text("${title}")) .delete-btn
    # Wait for success notification
    Wait For Elements State    .notification.success    visible    ${TIMEOUT}