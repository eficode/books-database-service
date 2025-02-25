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
    
I Have Book Details To Add
    No Operation
    
I Fill The Add Book Form
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Fill Text    id=title    ${title}
    Fill Text    id=author    ${author}
    Fill Text    id=pages    ${pages}
    Select Options By    id=category    text    ${category}
    
I Submit The Add Book Form
    Click    button:has-text("Add Book")
    
I Should See A Success Notification
    Wait For Elements State    .notification.success    visible    ${TIMEOUT}
    
I Search For Book By Title
    [Arguments]    ${title}
    Search For Book    ${title}
    
I Should See Book Details
    [Arguments]    ${title}    ${author}
    Wait For Elements State    .book-card h3:has-text("${title}")    visible    ${TIMEOUT}
    Wait For Elements State    .book-card:has(.book-title:has-text("${title}")) p:has-text("by ${author}")    visible    ${TIMEOUT}
    
I Have Created A Book
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Add New Book    ${title}    ${author}    ${pages}    ${category}
    
I Should See Book With Title
    [Arguments]    ${title}
    Book Should Exist    ${title}
    
I Search For Nonexistent Book
    Search For Book    NonExistentBookXYZ123
    
I Should See No Books Found Message
    Wait For Elements State    text=No books found    visible    timeout=5s
    
I Clear The Search
    Fill Text    id=search-input    ${EMPTY}
    Click    id=search-btn
    
I Should See All Books
    Wait For Elements State    css=.book-card >> nth=0    visible    ${TIMEOUT}
    
I Can See The Category Filter
    Wait For Elements State    id=category-filter    visible    ${TIMEOUT}
    
I Select Fiction Category Filter
    Select Options By    id=category-filter    text    Fiction
    Sleep    1s
    
I Add A Fiction Book
    [Arguments]    ${title}
    Add New Book    ${title}    Fiction Author    100    Fiction
    
I Reset The Category Filter
    Filter By Category    All Categories
    
I Should See All Categories Option
    Wait For Elements State    id=category-filter    visible    ${TIMEOUT}
    
I Create A Book For Editing
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Add New Book    ${title}    ${author}    ${pages}    ${category}
    
I Clear Filters And Search
    [Arguments]    ${search_text}
    Fill Text    id=search-input    ${EMPTY}
    Click    id=search-btn
    Filter By Category    All Categories
    Search For Book    ${search_text}
    
I Edit The Book
    [Arguments]    ${original_title}    ${new_title}    ${new_author}    ${new_pages}    ${new_category}
    Edit Book    ${original_title}    ${new_title}    ${new_author}    ${new_pages}    ${new_category}
    
I Create A Book For Deletion
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Add New Book    ${title}    ${author}    ${pages}    ${category}
    
I Delete Book With Title
    [Arguments]    ${title}
    Delete Book    ${title}
    
I Create Multiple Books For Sorting
    [Arguments]    ${title_a}    ${title_b}    ${title_c}
    Add New Book    ${title_a}    Author 1    100    Fiction
    Add New Book    ${title_b}    Author 2    200    Science Fiction
    Add New Book    ${title_c}    Author 3    300    Mystery
    
I Filter And Search For Books
    [Arguments]    ${search_text}
    Fill Text    id=search-input    ${EMPTY}
    Click    id=search-btn
    Filter By Category    All Categories
    Search For Book    ${search_text}
    
I Sort By Title Ascending
    Sort Books By    Title
    Sleep    1s
    
I Should See First Book With Title
    [Arguments]    ${title}
    Wait For Elements State    .book-card h3.book-title:has-text("${title}")    visible    ${TIMEOUT}

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