*** Settings ***
Documentation    UI Keywords for Browser Library interactions with the Books Library application
Library          Browser
Resource         common.resource


*** Variables ***
# Page Locators - Form Elements
${INPUT_TITLE}              id=title
${INPUT_AUTHOR}             id=author
${INPUT_PAGES}              id=pages
${SELECT_CATEGORY}          id=category
${BTN_ADD_BOOK}             css=#book-form button[type="submit"]

# Page Locators - Search and Filters
${INPUT_SEARCH}             id=search-input
${BTN_SEARCH}               id=search-btn
${SELECT_CATEGORY_FILTER}   id=category-filter
${BTN_ALL_BOOKS}            id=all-books-filter
${BTN_FAVORITES}            id=favorite-filter
${SELECT_SORT_BY}           id=sort-by
${BTN_SORT_DIRECTION}       id=sort-direction

# Page Locators - Books List
${BOOKS_LIST}               id=books-list
${BOOK_CARD}                css=.book-card
${SHOWN_COUNT}              id=shown-count
${TOTAL_COUNT}              id=total-count
${BTN_LOAD_MORE}            id=load-more

# Page Locators - Edit Modal
${EDIT_MODAL}               id=edit-modal
${EDIT_FORM}                id=edit-form
${INPUT_EDIT_ID}            id=edit-id
${INPUT_EDIT_TITLE}         id=edit-title
${INPUT_EDIT_AUTHOR}        id=edit-author
${INPUT_EDIT_PAGES}         id=edit-pages
${SELECT_EDIT_CATEGORY}     id=edit-category
${BTN_CLOSE_MODAL}          css=.modal .close

# Page Locators - Book Card Actions
${BTN_FAVORITE}             css=.favorite-btn
${BTN_EDIT}                 css=.edit-btn
${BTN_DELETE}               css=.delete-btn


*** Keywords ***
Open Books UI
    [Documentation]    Open the Books Library UI in the browser
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page    ${UI_URL}
    Sleep    2s    reason=Wait for page to load
    Get Title    ==    Books Library

Close Books UI
    [Documentation]    Close the browser
    Close Browser

Page Should Contain Header
    [Documentation]    Verify that the page header is present
    [Arguments]    ${expected_header}
    Get Text    css=header h1    contains    ${expected_header}

User Fills Book Form
    [Documentation]    Fill the book form with provided data
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    Fill Text    ${INPUT_TITLE}    ${title}
    Fill Text    ${INPUT_AUTHOR}    ${author}
    Fill Text    ${INPUT_PAGES}    ${pages}
    Select Options By    ${SELECT_CATEGORY}    value    ${category}

User Submits Book Form
    [Documentation]    Submit the book form
    Click    ${BTN_ADD_BOOK}
    Sleep    1s    reason=Wait for book to be added

User Clears Book Form
    [Documentation]    Clear all form fields
    Fill Text    ${INPUT_TITLE}    ${EMPTY}
    Fill Text    ${INPUT_AUTHOR}    ${EMPTY}
    Fill Text    ${INPUT_PAGES}    ${EMPTY}

User Adds New Book
    [Documentation]    Add a new book through the UI
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    User Fills Book Form    ${title}    ${author}    ${pages}    ${category}
    User Submits Book Form

Book Should Be Visible In List
    [Documentation]    Verify that a book with the given title is visible
    [Arguments]    ${title}
    Wait For Elements State    ${BOOKS_LIST}    visible    timeout=5s
    ${book_cards}=    Get Elements    ${BOOK_CARD}
    ${found}=    Set Variable    ${False}
    FOR    ${card}    IN    @{book_cards}
        ${card_text}=    Get Text    ${card}
        ${found}=    Run Keyword And Return Status    Should Contain    ${card_text}    ${title}
        IF    ${found}    BREAK
    END
    Should Be True    ${found}    msg=Book "${title}" not found in the list

Book Should Not Be Visible In List
    [Documentation]    Verify that a book with the given title is not visible
    [Arguments]    ${title}
    Wait For Elements State    ${BOOKS_LIST}    visible    timeout=5s
    ${book_cards}=    Get Elements    ${BOOK_CARD}
    FOR    ${card}    IN    @{book_cards}
        ${card_text}=    Get Text    ${card}
        Should Not Contain    ${card_text}    ${title}
    END

User Searches For Book
    [Documentation]    Search for a book using the search input
    [Arguments]    ${search_term}
    Fill Text    ${INPUT_SEARCH}    ${search_term}
    Click    ${BTN_SEARCH}
    Sleep    0.5s    reason=Wait for search results

User Filters By Category
    [Documentation]    Filter books by category
    [Arguments]    ${category}
    Select Options By    ${SELECT_CATEGORY_FILTER}    value    ${category}
    Sleep    0.5s    reason=Wait for filter to apply

User Filters By Favorites
    [Documentation]    Show only favorite books
    Click    ${BTN_FAVORITES}
    Sleep    0.5s    reason=Wait for filter to apply

User Shows All Books
    [Documentation]    Show all books (remove favorite filter)
    Click    ${BTN_ALL_BOOKS}
    Sleep    0.5s    reason=Wait for filter to apply

User Sorts Books By
    [Documentation]    Sort books by the specified field
    [Arguments]    ${sort_field}
    Select Options By    ${SELECT_SORT_BY}    value    ${sort_field}
    Sleep    0.5s    reason=Wait for sorting

User Toggles Sort Direction
    [Documentation]    Toggle the sort direction (ascending/descending)
    Click    ${BTN_SORT_DIRECTION}
    Sleep    0.5s    reason=Wait for sorting

User Clicks Favorite Button For Book
    [Documentation]    Click the favorite button for a book with the given title
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    ${favorite_btn}=    Get Element    ${book_card} >> ${BTN_FAVORITE}
    Click    ${favorite_btn}
    Sleep    0.5s    reason=Wait for favorite status to update

User Clicks Edit Button For Book
    [Documentation]    Click the edit button for a book with the given title
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    ${edit_btn}=    Get Element    ${book_card} >> ${BTN_EDIT}
    Click    ${edit_btn}
    Wait For Elements State    ${EDIT_MODAL}    visible    timeout=5s

User Clicks Delete Button For Book
    [Documentation]    Click the delete button for a book with the given title
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    ${delete_btn}=    Get Element    ${book_card} >> ${BTN_DELETE}
    Click    ${delete_btn}
    # Handle confirmation dialog if present
    ${alert_present}=    Run Keyword And Return Status    Handle Future Dialogs    action=accept
    Sleep    0.5s    reason=Wait for deletion

User Edits Book In Modal
    [Documentation]    Edit book details in the modal
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Wait For Elements State    ${EDIT_MODAL}    visible    timeout=5s
    Fill Text    ${INPUT_EDIT_TITLE}    ${title}
    Fill Text    ${INPUT_EDIT_AUTHOR}    ${author}
    Fill Text    ${INPUT_EDIT_PAGES}    ${pages}
    Select Options By    ${SELECT_EDIT_CATEGORY}    value    ${category}
    Click    css=#edit-form button[type="submit"]
    Sleep    1s    reason=Wait for update

User Closes Edit Modal
    [Documentation]    Close the edit modal
    Click    ${BTN_CLOSE_MODAL}
    Wait For Elements State    ${EDIT_MODAL}    hidden    timeout=5s

Books Count Should Be
    [Documentation]    Verify the number of books shown
    [Arguments]    ${expected_count}
    ${shown}=    Get Text    ${SHOWN_COUNT}
    Should Be Equal As Numbers    ${shown}    ${expected_count}

Total Books Count Should Be
    [Documentation]    Verify the total number of books
    [Arguments]    ${expected_count}
    ${total}=    Get Text    ${TOTAL_COUNT}
    Should Be Equal As Numbers    ${total}    ${expected_count}

Get Book Card By Title
    [Documentation]    Get the book card element by book title
    [Arguments]    ${title}
    ${book_cards}=    Get Elements    ${BOOK_CARD}
    FOR    ${card}    IN    @{book_cards}
        ${card_text}=    Get Text    ${card}
        ${found}=    Run Keyword And Return Status    Should Contain    ${card_text}    ${title}
        IF    ${found}    RETURN    ${card}
    END
    Fail    Book card with title "${title}" not found

Book Card Should Contain Information
    [Documentation]    Verify that a book card contains specific information
    [Arguments]    ${title}    ${author}    ${pages}
    ${book_card}=    Get Book Card By Title    ${title}
    ${card_text}=    Get Text    ${book_card}
    Should Contain    ${card_text}    ${title}
    Should Contain    ${card_text}    ${author}
    Should Contain    ${card_text}    ${pages}

Book Should Be Marked As Favorite
    [Documentation]    Verify that a book is marked as favorite
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    ${favorite_btn}=    Get Element    ${book_card} >> ${BTN_FAVORITE}
    ${class}=    Get Attribute    ${favorite_btn}    class
    Should Contain    ${class}    active

Book Should Not Be Marked As Favorite
    [Documentation]    Verify that a book is not marked as favorite
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    ${favorite_btn}=    Get Element    ${book_card} >> ${BTN_FAVORITE}
    ${class}=    Get Attribute    ${favorite_btn}    class
    Should Not Contain    ${class}    active

Page Should Show No Results Message
    [Documentation]    Verify that "no results" message is shown
    ${shown}=    Get Text    ${SHOWN_COUNT}
    Should Be Equal    ${shown}    0

Wait For Books To Load
    [Documentation]    Wait until books are loaded in the list
    Wait For Elements State    ${BOOKS_LIST}    visible    timeout=10s
    Sleep    1s    reason=Wait for books to render
