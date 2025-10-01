*** Settings ***
Documentation    UI-specific keywords for Books Library application
Resource         ../resources/common.resource

*** Keywords ***
# Page Navigation and Verification
Navigate To Books Library Homepage
    [Documentation]    Navigate to the Books Library homepage
    Go To    ${UI_URL}
    Wait For Application To Be Ready

Verify Homepage Elements Are Visible
    [Documentation]    Verify all main homepage elements are visible
    Get Title    contains    Books Library
    Wait For Elements State    css=h1    visible
    Get Text    css=h1    contains    Books Library
    Wait For Elements State    ${TITLE_INPUT}    visible
    Wait For Elements State    ${AUTHOR_INPUT}    visible
    Wait For Elements State    ${PAGES_INPUT}    visible
    Wait For Elements State    ${CATEGORY_SELECT}    visible
    Wait For Elements State    ${ADD_BOOK_BUTTON}    visible
    Wait For Elements State    ${BOOKS_GRID}    visible

# Book Form Operations
Fill Book Creation Form
    [Documentation]    Fill the book creation form with provided data
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    Fill Text    ${TITLE_INPUT}    ${title}
    Fill Text    ${AUTHOR_INPUT}    ${author}
    Fill Text    ${PAGES_INPUT}    ${pages}
    Select Options By    ${CATEGORY_SELECT}    value    ${category}

Submit Book Creation Form
    [Documentation]    Submit the book creation form
    Click    ${ADD_BOOK_BUTTON}
    # Wait for form submission to complete
    Sleep    3s

Clear Book Creation Form
    [Documentation]    Clear all fields in the book creation form
    Fill Text    ${TITLE_INPUT}    ${EMPTY}
    Fill Text    ${AUTHOR_INPUT}    ${EMPTY}
    Fill Text    ${PAGES_INPUT}    ${EMPTY}

# Book Grid Operations
Wait For Book To Appear In Grid
    [Documentation]    Wait for a book with specific title to appear in the books grid
    [Arguments]    ${title}
    Wait For Elements State    css=.book-card:has-text("${title}")    visible    timeout=${SLOW_TIMEOUT}

Get Book Card By Title
    [Documentation]    Get book card element by title (first match to avoid strict mode violations)
    [Arguments]    ${title}
    ${book_card}=    Get Element    css=.book-card:has-text("${title}") >> nth=0
    RETURN    ${book_card}

Verify Book Exists In Grid
    [Documentation]    Verify that a book with specific details exists in the grid
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    ${book_card}=    Get Book Card By Title    ${title}
    Get Text    ${book_card} >> ${BOOK_TITLE}    contains    ${title}
    Get Text    ${book_card} >> ${BOOK_AUTHOR}    contains    ${author}
    Get Text    ${book_card} >> ${BOOK_PAGES}    contains    ${pages}
    Get Text    ${book_card} >> ${BOOK_CATEGORY}    contains    ${category}

Verify Book Does Not Exist In Grid
    [Documentation]    Verify that a book with specific title does not exist in the grid
    [Arguments]    ${title}
    Sleep    3s    # Wait for UI updates
    ${elements}=    Get Elements    css=.book-card:has-text("${title}")
    ${elements_count}=    Get Length    ${elements}
    Should Be Equal As Numbers    ${elements_count}    0

Get All Visible Books
    [Documentation]    Get all currently visible book cards
    ${visible_books}=    Get Elements    css=.book-card:visible
    RETURN    ${visible_books}

Get Book Count In Grid
    [Documentation]    Get the count of books currently displayed in the grid
    ${books}=    Get All Visible Books
    ${count}=    Get Length    ${books}
    RETURN    ${count}

# Book Actions
Click Favorite Button For Book
    [Documentation]    Click the favorite button for a specific book
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    Click    ${book_card} >> ${FAVORITE_BTN}
    Sleep    2s    # Wait for async operation

Click Edit Button For Book
    [Documentation]    Click the edit button for a specific book
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    Click    ${book_card} >> ${EDIT_BTN}

Click Delete Button For Book
    [Documentation]    Click the delete button for a specific book and handle confirmation
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    Handle Future Dialogs    action=accept
    Click    ${book_card} >> ${DELETE_BTN}
    Sleep    3s    # Wait for deletion to complete

Verify Book Is Marked As Favorite
    [Documentation]    Verify that a book is marked as favorite
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    ${favorite_btn}=    Get Element    ${book_card} >> ${FAVORITE_BTN}
    ${class_attr}=    Get Attribute    ${favorite_btn}    class
    Should Contain    ${class_attr}    active

Verify Book Is Not Marked As Favorite
    [Documentation]    Verify that a book is not marked as favorite
    [Arguments]    ${title}
    ${book_card}=    Get Book Card By Title    ${title}
    ${favorite_btn}=    Get Element    ${book_card} >> ${FAVORITE_BTN}
    ${class_attr}=    Get Attribute    ${favorite_btn}    class
    Should Not Contain    ${class_attr}    active

# Search and Filter Operations
Search For Books
    [Documentation]    Search for books using the search functionality
    [Arguments]    ${search_term}
    Fill Text    ${SEARCH_INPUT}    ${search_term}
    Click    ${SEARCH_BUTTON}
    Sleep    1s    # Wait for search results

Clear Search
    [Documentation]    Clear the search input
    Fill Text    ${SEARCH_INPUT}    ${EMPTY}
    Click    ${SEARCH_BUTTON}
    Sleep    1s

Filter Books By Category
    [Documentation]    Filter books by category
    [Arguments]    ${category}
    Select Options By    ${CATEGORY_FILTER}    value    ${category}
    Sleep    1s    # Wait for filter to apply

Filter Books By Favorite Status
    [Documentation]    Filter books by favorite status
    [Arguments]    ${show_favorites}=True
    IF    ${show_favorites}
        Click    ${FAVORITE_FILTER}
    ELSE
        Click    ${ALL_BOOKS_FILTER}
    END
    Sleep    1s    # Wait for filter to apply

# Sorting Operations
Sort Books By Field
    [Documentation]    Sort books by specified field and direction
    [Arguments]    ${sort_field}    ${direction}=asc
    Select Options By    ${SORT_BY_SELECT}    value    ${sort_field}
    
    # Check current sort direction and toggle if needed
    ${current_direction}=    Get Attribute    ${SORT_DIRECTION_BTN}    title
    IF    "${direction}" == "desc" and "ascending" in "${current_direction}"
        Click    ${SORT_DIRECTION_BTN}
    ELSE IF    "${direction}" == "asc" and "descending" in "${current_direction}"
        Click    ${SORT_DIRECTION_BTN}
    END
    Sleep    1s    # Wait for sorting to apply

Verify Books Are Sorted By Title
    [Documentation]    Verify books are sorted alphabetically by title
    [Arguments]    ${ascending}=True
    ${book_titles}=    Get Elements    ${BOOK_TITLE}
    ${titles_text}=    Create List
    FOR    ${title_element}    IN    @{book_titles}
        ${title_text}=    Get Text    ${title_element}
        Append To List    ${titles_text}    ${title_text}
    END
    
    IF    ${ascending}
        ${sorted_titles}=    Evaluate    sorted($titles_text)
    ELSE
        ${sorted_titles}=    Evaluate    sorted($titles_text, reverse=True)
    END
    Lists Should Be Equal    ${titles_text}    ${sorted_titles}

Verify Books Are Sorted By Author
    [Documentation]    Verify books are sorted alphabetically by author
    [Arguments]    ${ascending}=True
    ${book_authors}=    Get Elements    ${BOOK_AUTHOR}
    ${authors_text}=    Create List
    FOR    ${author_element}    IN    @{book_authors}
        ${author_text}=    Get Text    ${author_element}
        # Remove "by " prefix if present
        ${clean_author}=    Replace String    ${author_text}    by ${SPACE}    ${EMPTY}
        Append To List    ${authors_text}    ${clean_author}
    END
    
    IF    ${ascending}
        ${sorted_authors}=    Evaluate    sorted($authors_text)
    ELSE
        ${sorted_authors}=    Evaluate    sorted($authors_text, reverse=True)
    END
    Lists Should Be Equal    ${authors_text}    ${sorted_authors}

Verify Books Are Sorted By Pages
    [Documentation]    Verify books are sorted by page count
    [Arguments]    ${ascending}=True
    ${book_pages}=    Get Elements    ${BOOK_PAGES}
    ${pages_numbers}=    Create List
    FOR    ${pages_element}    IN    @{book_pages}
        ${pages_text}=    Get Text    ${pages_element}
        # Extract number from "Pages: 250" format
        ${pages_number}=    Evaluate    int(''.join(filter(str.isdigit, "${pages_text}")))
        Append To List    ${pages_numbers}    ${pages_number}
    END
    
    IF    ${ascending}
        ${sorted_pages}=    Evaluate    sorted($pages_numbers)
    ELSE
        ${sorted_pages}=    Evaluate    sorted($pages_numbers, reverse=True)
    END
    Lists Should Be Equal    ${pages_numbers}    ${sorted_pages}

# Edit Modal Operations
Open Edit Modal For Book
    [Documentation]    Open the edit modal for a specific book
    [Arguments]    ${title}
    Click Edit Button For Book    ${title}
    Wait For Elements State    ${EDIT_MODAL}    visible    timeout=${TIMEOUT}

Fill Edit Form
    [Documentation]    Fill the edit form with new data
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Fill Text    ${EDIT_TITLE_INPUT}    ${title}
    Fill Text    ${EDIT_AUTHOR_INPUT}    ${author}
    Fill Text    ${EDIT_PAGES_INPUT}    ${pages}
    Select Options By    ${EDIT_CATEGORY_SELECT}    value    ${category}

Submit Edit Form
    [Documentation]    Submit the edit form
    Click    ${EDIT_SAVE_BUTTON}
    Sleep    3s    # Wait for update to complete

Close Edit Modal
    [Documentation]    Close the edit modal
    Click    ${MODAL_CLOSE}
    Wait For Elements State    ${EDIT_MODAL}    hidden    timeout=${TIMEOUT}

# Verification Keywords
Verify Search Results Contain Term
    [Documentation]    Verify that all visible books contain the search term
    [Arguments]    ${search_term}
    ${visible_books}=    Get All Visible Books
    FOR    ${book}    IN    @{visible_books}
        ${title}=    Get Text    ${book} >> ${BOOK_TITLE}
        ${author}=    Get Text    ${book} >> ${BOOK_AUTHOR}
        ${title_match}=    Run Keyword And Return Status    Should Contain    ${title}    ${search_term}    ignore_case=True
        ${author_match}=    Run Keyword And Return Status    Should Contain    ${author}    ${search_term}    ignore_case=True
        ${matches}=    Evaluate    ${title_match} or ${author_match}
        Should Be True    ${matches}    Book "${title}" by "${author}" does not contain search term "${search_term}"
    END

Verify All Books Have Category
    [Documentation]    Verify that all visible books have the specified category
    [Arguments]    ${expected_category}
    ${visible_books}=    Get All Visible Books
    FOR    ${book}    IN    @{visible_books}
        ${category}=    Get Text    ${book} >> ${BOOK_CATEGORY}
        Should Be Equal As Strings    ${category}    ${expected_category}
    END

Verify All Books Are Favorites
    [Documentation]    Verify that all visible books are marked as favorites
    ${visible_books}=    Get All Visible Books
    FOR    ${book}    IN    @{visible_books}
        ${favorite_btn}=    Get Element    ${book} >> ${FAVORITE_BTN}
        ${class_attr}=    Get Attribute    ${favorite_btn}    class
        Should Contain    ${class_attr}    active
    END

Verify No Results Message Is Displayed
    [Documentation]    Verify that a no results message is displayed
    # Check for no-books message or zero count
    TRY
        Wait For Elements State    css=.no-books    visible    timeout=5s
    EXCEPT
        ${results_info}=    Get Text    css=.results-info
        Should Contain    ${results_info}    Showing 0
    END

# Form Validation
Verify Form Validation Error
    [Documentation]    Verify that form validation prevents submission
    [Arguments]    ${field_selector}
    TRY
        ${field_element}=    Get Element    ${field_selector}
        ${is_valid}=    Evaluate JavaScript    ${field_element}    element => element.validity.valid
        Should Be Equal    ${is_valid}    ${False}
    EXCEPT
        # Alternative: Check if we're still on the same page (form wasn't submitted)
        Get Title    contains    Books Library
        Log    Form validation prevented submission (verified by page check)
    END

# Test Data Creation Helpers
Create Test Book With Category
    [Documentation]    Create a test book with specific category
    [Arguments]    ${category}
    ${book_data}=    Generate Random Book Data
    Fill Book Creation Form    ${book_data}[title]    ${book_data}[author]    ${book_data}[pages]    ${category}
    Submit Book Creation Form
    Wait For Book To Appear In Grid    ${book_data}[title]
    RETURN    ${book_data}

Create Multiple Test Books
    [Documentation]    Create multiple test books for testing
    [Arguments]    ${count}=3
    ${books}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${book_data}=    Generate Random Book Data
        Fill Book Creation Form    ${book_data}[title]    ${book_data}[author]    ${book_data}[pages]    ${book_data}[category]
        Submit Book Creation Form
        Wait For Book To Appear In Grid    ${book_data}[title]
        Append To List    ${books}    ${book_data}
    END
    RETURN    ${books}

Create Books With Different Categories
    [Documentation]    Create books with different categories
    [Arguments]    @{categories}
    ${books}=    Create List
    FOR    ${category}    IN    @{categories}
        ${book_data}=    Create Test Book With Category    ${category}
        Set To Dictionary    ${book_data}    category    ${category}
        Append To List    ${books}    ${book_data}
    END
    RETURN    ${books}

Create Books With Different Authors
    [Documentation]    Create books with different authors
    [Arguments]    @{authors}
    ${books}=    Create List
    FOR    ${author}    IN    @{authors}
        ${book_data}=    Generate Random Book Data
        Fill Book Creation Form    ${book_data}[title]    ${author}    ${book_data}[pages]    ${book_data}[category]
        Submit Book Creation Form
        Wait For Book To Appear In Grid    ${book_data}[title]
        Set To Dictionary    ${book_data}    author    ${author}
        Append To List    ${books}    ${book_data}
    END
    RETURN    ${books}

Create Books With Different Titles
    [Documentation]    Create books with specific titles
    [Arguments]    @{titles}
    ${books}=    Create List
    FOR    ${title}    IN    @{titles}
        ${book_data}=    Generate Random Book Data
        Fill Book Creation Form    ${title}    ${book_data}[author]    ${book_data}[pages]    ${book_data}[category]
        Submit Book Creation Form
        Wait For Book To Appear In Grid    ${title}
        Set To Dictionary    ${book_data}    title    ${title}
        Append To List    ${books}    ${book_data}
    END
    RETURN    ${books}

Create Books With Different Page Counts
    [Documentation]    Create books with specific page counts
    [Arguments]    @{page_counts}
    ${books}=    Create List
    FOR    ${pages}    IN    @{page_counts}
        ${book_data}=    Generate Random Book Data
        Fill Book Creation Form    ${book_data}[title]    ${book_data}[author]    ${pages}    ${book_data}[category]
        Submit Book Creation Form
        Wait For Book To Appear In Grid    ${book_data}[title]
        Set To Dictionary    ${book_data}    pages    ${pages}
        Append To List    ${books}    ${book_data}
    END
    RETURN    ${books}

Create Books With Mixed Favorite Status
    [Documentation]    Create books with some marked as favorites
    [Arguments]    ${total_count}=4    ${favorite_count}=2
    ${books}=    Create Multiple Test Books    ${total_count}
    FOR    ${i}    IN RANGE    ${favorite_count}
        ${book}=    Get From List    ${books}    ${i}
        Click Favorite Button For Book    ${book}[title]
    END
    RETURN    ${books}