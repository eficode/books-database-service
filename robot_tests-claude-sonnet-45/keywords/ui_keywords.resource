*** Settings ***
Documentation    UI-specific keywords for Books Library application
Resource    ../resources/common.resource

*** Keywords ***
Given I Am On The Books Library Homepage
    [Documentation]    Navigate to the Books Library homepage and verify it loads
    Go To    ${UI_URL}
    Wait For Application To Load
    Get Title    ==    Books Library

When I Am On The Books Library Homepage
    [Documentation]    Navigate to the Books Library homepage (alias for Given)
    Given I Am On The Books Library Homepage

When I Fill In The Book Form
    [Documentation]    Fill in the add book form with provided data
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    Fill Text    ${TITLE_INPUT}    ${title}
    Fill Text    ${AUTHOR_INPUT}    ${author}
    Fill Text    ${PAGES_INPUT}    ${pages}
    Select Options By    ${CATEGORY_SELECT}    text    ${category}

When I Submit The Book Form
    [Documentation]    Submit the add book form
    Click    ${ADD_BOOK_BUTTON}

And I Submit The Book Form
    [Documentation]    Submit the add book form (alias for When)
    When I Submit The Book Form

When I Add A New Book
    [Documentation]    Complete workflow to add a new book
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    When I Fill In The Book Form    ${title}    ${author}    ${pages}    ${category}
    When I Submit The Book Form

And I Add A New Book
    [Documentation]    Complete workflow to add a new book (alias for When)
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    When I Add A New Book    ${title}    ${author}    ${pages}    ${category}

Then I Should See The Book In The List
    [Documentation]    Verify that a book appears in the books list
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Wait For Books To Load
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    ${book_found}=    Set Variable    ${False}
    FOR    ${card}    IN    @{book_cards}
        ${card_title}=    Get Text    ${card} >> css=.book-title
        IF    '${card_title}' == '${title}'
            ${book_found}=    Set Variable    ${True}
            Verify Book Card Elements    ${card}    ${title}    ${author}    ${pages}    ${category}
            BREAK
        END
    END
    Should Be True    ${book_found}    Book with title '${title}' not found in the list

And I Should See The Book In The List
    [Documentation]    Verify that a book appears in the books list (alias for Then)
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Then I Should See The Book In The List    ${title}    ${author}    ${pages}    ${category}

When I Search For Books
    [Documentation]    Search for books using the search input
    [Arguments]    ${search_term}
    Fill Text    ${SEARCH_INPUT}    ${search_term}
    # Trigger search (assuming it's automatic or on enter)
    Press Keys    ${SEARCH_INPUT}    Enter

And I Search For Books
    [Documentation]    Search for books using the search input (alias for When)
    [Arguments]    ${search_term}
    When I Search For Books    ${search_term}

When I Filter Books By Category
    [Documentation]    Filter books by selecting a category
    [Arguments]    ${category}
    Select Options By    ${CATEGORY_FILTER}    text    ${category}

When I Filter Books By Favorites
    [Documentation]    Filter books to show only favorites
    Click    ${FAVORITE_FILTER}

And I Filter Books By Favorites
    [Documentation]    Filter books to show only favorites (alias for When)
    When I Filter Books By Favorites

When I Show All Books
    [Documentation]    Remove favorite filter to show all books
    Click    ${ALL_BOOKS_FILTER}

When I Sort Books By
    [Documentation]    Sort books by the specified field
    [Arguments]    ${sort_field}
    Select Options By    ${SORT_BY_SELECT}    text    ${sort_field}

When I Sort Books By Title
    [Documentation]    Sort books by title
    When I Sort Books By    Title

When I Sort Books By Author
    [Documentation]    Sort books by author
    When I Sort Books By    Author

When I Sort Books By Pages
    [Documentation]    Sort books by pages
    When I Sort Books By    Pages

When I Toggle Sort Direction
    [Documentation]    Toggle the sort direction (ascending/descending)
    Click    ${SORT_DIRECTION_BTN}

And I Toggle Sort Direction
    [Documentation]    Toggle the sort direction (ascending/descending) (alias for When)
    When I Toggle Sort Direction

When I Click Edit On Book
    [Documentation]    Click the edit button on a specific book
    [Arguments]    ${book_title}
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    FOR    ${card}    IN    @{book_cards}
        ${card_title}=    Get Text    ${card} >> css=.book-title
        IF    '${card_title}' == '${book_title}'
            Click    ${card} >> css=.edit-btn
            BREAK
        END
    END

When I Edit The Book Details
    [Documentation]    Edit book details in the modal form
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Wait For Elements State    ${EDIT_MODAL}    visible    timeout=${DEFAULT_TIMEOUT}
    Fill Text    ${EDIT_TITLE_INPUT}    ${title}
    Fill Text    ${EDIT_AUTHOR_INPUT}    ${author}
    Fill Text    ${EDIT_PAGES_INPUT}    ${pages}
    Select Options By    ${EDIT_CATEGORY_SELECT}    text    ${category}

When I Save The Book Changes
    [Documentation]    Save changes in the edit modal
    Click    ${EDIT_FORM} >> css=button[type="submit"]

And I Save The Book Changes
    [Documentation]    Save changes in the edit modal (alias for When)
    When I Save The Book Changes

When I Close The Edit Modal
    [Documentation]    Close the edit modal without saving
    Click    ${MODAL_CLOSE_BUTTON}

And I Close The Edit Modal
    [Documentation]    Close the edit modal without saving (alias for When)
    When I Close The Edit Modal

When I Click Delete On Book
    [Documentation]    Click the delete button on a specific book
    [Arguments]    ${book_title}
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    FOR    ${card}    IN    @{book_cards}
        ${card_title}=    Get Text    ${card} >> css=.book-title
        IF    '${card_title}' == '${book_title}'
            Click    ${card} >> css=.delete-btn
            BREAK
        END
    END

And I Click Delete On Book
    [Documentation]    Click the delete button on a specific book (alias for When)
    [Arguments]    ${book_title}
    When I Click Delete On Book    ${book_title}

When I Confirm The Deletion
    [Documentation]    Confirm deletion in the confirmation dialog
    # Handle browser confirmation dialog
    Handle Future Dialogs    action=accept

And I Confirm The Deletion
    [Documentation]    Confirm deletion in the confirmation dialog (alias for When)
    When I Confirm The Deletion

When I Toggle Favorite On Book
    [Documentation]    Toggle the favorite status of a specific book
    [Arguments]    ${book_title}
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    FOR    ${card}    IN    @{book_cards}
        ${card_title}=    Get Text    ${card} >> css=.book-title
        IF    '${card_title}' == '${book_title}'
            Click    ${card} >> css=.favorite-btn
            BREAK
        END
    END

And I Toggle Favorite On Book
    [Documentation]    Toggle the favorite status of a specific book (alias for When)
    [Arguments]    ${book_title}
    When I Toggle Favorite On Book    ${book_title}

Then I Should See Books Filtered By
    [Documentation]    Verify that books are filtered correctly
    [Arguments]    ${filter_type}    ${filter_value}
    Wait For Books To Load
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    FOR    ${card}    IN    @{book_cards}
        IF    '${filter_type}' == 'category'
            ${card_category}=    Get Text    ${card} >> css=.book-category
            Should Be Equal    ${card_category}    ${filter_value}
        ELSE IF    '${filter_type}' == 'favorite'
            ${favorite_icon}=    Get Element    ${card} >> css=.favorite-btn.active
            Should Not Be Empty    ${favorite_icon}
        END
    END

Then I Should See Books Sorted By
    [Documentation]    Verify that books are sorted correctly
    [Arguments]    ${sort_field}    ${direction}=ascending
    Wait For Books To Load
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    ${values}=    Create List
    FOR    ${card}    IN    @{book_cards}
        IF    '${sort_field}' == 'title'
            ${value}=    Get Text    ${card} >> css=.book-title
        ELSE IF    '${sort_field}' == 'author'
            ${value}=    Get Text    ${card} >> css=.book-author
        ELSE IF    '${sort_field}' == 'pages'
            ${value_text}=    Get Text    ${card} >> css=.book-pages
            ${value}=    Convert To Integer    ${value_text.split(':')[1].strip()}
        ELSE IF    '${sort_field}' == 'category'
            ${value}=    Get Text    ${card} >> css=.book-category
        END
        Append To List    ${values}    ${value}
    END
    ${sorted_values}=    Copy List    ${values}
    IF    '${direction}' == 'ascending'
        Sort List    ${sorted_values}
    ELSE
        Sort List    ${sorted_values}
        Reverse List    ${sorted_values}
    END
    Lists Should Be Equal    ${values}    ${sorted_values}

Then I Should Not See The Book In The List
    [Documentation]    Verify that a book is not present in the books list
    [Arguments]    ${title}
    Wait For Books To Load
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    FOR    ${card}    IN    @{book_cards}
        ${card_title}=    Get Text    ${card} >> css=.book-title
        Should Not Be Equal    ${card_title}    ${title}
    END

And I Should Not See The Book In The List
    [Documentation]    Verify that a book is not present in the books list (alias for Then)
    [Arguments]    ${title}
    Then I Should Not See The Book In The List    ${title}

Then I Should See The Edit Modal
    [Documentation]    Verify that the edit modal is displayed
    Wait For Elements State    ${EDIT_MODAL}    visible    timeout=${DEFAULT_TIMEOUT}

Then I Should Not See The Edit Modal
    [Documentation]    Verify that the edit modal is not displayed
    Wait For Elements State    ${EDIT_MODAL}    hidden    timeout=${DEFAULT_TIMEOUT}

Then I Should See A Success Message
    [Documentation]    Verify that a success message is displayed
    Wait For Elements State    css=.notification.success    visible    timeout=${DEFAULT_TIMEOUT}

Then I Should See An Error Message
    [Documentation]    Verify that an error message is displayed
    Wait For Elements State    css=.notification.error    visible    timeout=${DEFAULT_TIMEOUT}

Then I Should See The Book Count
    [Documentation]    Verify the displayed book count
    [Arguments]    ${expected_count}
    ${count_element}=    Get Text    id=total-count
    Should Be Equal As Strings    ${count_element}    ${expected_count}

And I Should See The Book Count
    [Documentation]    Verify the displayed book count (alias for Then)
    [Arguments]    ${expected_count}
    Then I Should See The Book Count    ${expected_count}

Then The Book Should Be Marked As Favorite
    [Documentation]    Verify that a book is marked as favorite
    [Arguments]    ${book_title}
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    FOR    ${card}    IN    @{book_cards}
        ${card_title}=    Get Text    ${card} >> css=.book-title
        IF    '${card_title}' == '${book_title}'
            ${favorite_btn}=    Get Element    ${card} >> css=.favorite-btn
            ${class_attr}=    Get Attribute    ${favorite_btn}    class
            Should Contain    ${class_attr}    active
            BREAK
        END
    END

When I Load More Books
    [Documentation]    Click the load more button to load additional books
    Click    ${LOAD_MORE_BUTTON}

Then I Should See More Books Loaded
    [Documentation]    Verify that more books have been loaded
    [Arguments]    ${initial_count}
    Wait For Books To Load
    ${book_cards}=    Get Elements    ${BOOKS_LIST} >> css=.book-card
    ${current_count}=    Get Length    ${book_cards}
    Should Be True    ${current_count} > ${initial_count}

Verify Form Validation Error
    [Documentation]    Verify that form validation errors are displayed
    [Arguments]    ${field}    ${error_message}
    ${error_element}=    Get Element    css=.form-group:has(#${field}) .error-message
    Get Text    ${error_element}    contains    ${error_message}

And Verify Form Validation Error
    [Documentation]    Verify that form validation errors are displayed (alias for main keyword)
    [Arguments]    ${field}    ${error_message}
    Verify Form Validation Error    ${field}    ${error_message}

Clear Form Fields
    [Documentation]    Clear all form fields
    Clear Text    ${TITLE_INPUT}
    Clear Text    ${AUTHOR_INPUT}
    Clear Text    ${PAGES_INPUT}
    Select Options By    ${CATEGORY_SELECT}    text    Fiction

And I Have Multiple Books In The Database
    [Documentation]    Create multiple books in the database for testing (alias for API keyword)
    [Arguments]    ${count}=5
    Given I Have Multiple Books In The Database    ${count}