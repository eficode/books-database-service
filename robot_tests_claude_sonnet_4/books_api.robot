*** Settings ***
Documentation    API acceptance tests for Books Database Service
Resource         resources/common.resource
Resource         resources/keywords/api_keywords.resource
Suite Setup      Create API Session
Test Tags        api    acceptance

*** Test Cases ***
API Can Create A New Book
    [Documentation]    Verify API can create a new book
    [Tags]    crud
    Given the API is available
    When a new book is created with title "API Test Book" author "API Author" pages "150" category "Fiction"
    Then the book should be created successfully
    And the book should have correct properties

API Can Retrieve All Books
    [Documentation]    Verify API can retrieve all books
    [Tags]    read
    Given the API has books
    When all books are requested
    Then all books should be returned

API Can Retrieve A Specific Book
    [Documentation]    Verify API can retrieve a book by ID
    [Tags]    read
    Given the API has a book
    When the book is requested by ID
    Then the correct book should be returned

API Can Update An Existing Book
    [Documentation]    Verify API can update book properties
    [Tags]    crud
    Given the API has a book to update
    When the book is updated with new title "Updated Title"
    Then the book should be updated successfully
    And the book should have the new properties

API Can Delete A Book
    [Documentation]    Verify API can delete a book
    [Tags]    crud
    Given the API has a book to delete
    When the book is deleted
    Then the book should be removed successfully

API Can Search For Books
    [Documentation]    Verify API can search books by title
    [Tags]    search
    Given the API has searchable books
    When books are searched with term "Search"
    Then only matching books should be returned

API Can Filter Books By Category
    [Documentation]    Verify API can filter books by category
    [Tags]    filter
    Given the API has books in different categories
    When books are filtered by "Fiction" category
    Then only fiction books should be returned

API Handles Invalid Book Creation
    [Documentation]    Verify API handles invalid book data
    [Tags]    validation
    Given the API is available
    When an invalid book is created
    Then an error response should be returned

*** Keywords ***
The API Is Available
    [Documentation]    Verify API is accessible
    ${response}=    GET On Session    books_api    /books    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    200

A New Book Is Created With Title "${title}" Author "${author}" Pages "${pages}" Category "${category}"
    [Documentation]    Create a new book via API
    ${book}=    Create Book Via API    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${CREATED_BOOK}    ${book}

The Book Should Be Created Successfully
    [Documentation]    Verify book creation was successful
    Should Not Be Equal    ${CREATED_BOOK}[id]    ${None}
    Should Be True    ${CREATED_BOOK}[id] > 0
    Should Be Equal    ${CREATED_BOOK}[title]    API Test Book

The Book Should Have Correct Properties
    [Documentation]    Verify book has expected properties
    Verify Book Properties    ${CREATED_BOOK}    API Test Book    API Author    150    Fiction

The API Has Books
    [Documentation]    Ensure API has books for testing
    Create Book Via API    Book 1    Author 1    100    Fiction
    Create Book Via API    Book 2    Author 2    200    Non-Fiction

All Books Are Requested
    [Documentation]    Request all books from API
    ${books}=    Get All Books Via API
    Set Test Variable    ${ALL_BOOKS}    ${books}

All Books Should Be Returned
    [Documentation]    Verify all books are returned
    Should Not Be Empty    ${ALL_BOOKS}
    ${length}=    Get Length    ${ALL_BOOKS}
    Should Be True    ${length} >= 2

The API Has A Book
    [Documentation]    Create a book for retrieval testing
    ${book}=    Create Book Via API    Retrieve Test    Test Author    120    Fiction
    Set Test Variable    ${TEST_BOOK}    ${book}

The Book Is Requested By ID
    [Documentation]    Request specific book by ID
    ${book}=    Get Book By ID Via API    ${TEST_BOOK}[id]
    Set Test Variable    ${RETRIEVED_BOOK}    ${book}

The Correct Book Should Be Returned
    [Documentation]    Verify correct book is returned
    Should Be Equal    ${RETRIEVED_BOOK}[id]    ${TEST_BOOK}[id]
    Should Be Equal    ${RETRIEVED_BOOK}[title]    Retrieve Test

The API Has A Book To Update
    [Documentation]    Create a book for update testing
    ${book}=    Create Book Via API    Update Test    Original Author    180    Fiction
    Set Test Variable    ${UPDATE_BOOK}    ${book}

The Book Is Updated With New Title "${new_title}"
    [Documentation]    Update book with new title
    ${updated_book}=    Update Book Via API    ${UPDATE_BOOK}[id]    ${new_title}    Updated Author    180    Fiction
    Set Test Variable    ${UPDATED_BOOK}    ${updated_book}

The Book Should Be Updated Successfully
    [Documentation]    Verify book update was successful
    Should Be Equal    ${UPDATED_BOOK}[title]    Updated Title

The Book Should Have The New Properties
    [Documentation]    Verify book has updated properties
    Should Be Equal    ${UPDATED_BOOK}[author]    Updated Author

The API Has A Book To Delete
    [Documentation]    Create a book for deletion testing
    ${book}=    Create Book Via API    Delete Test    Delete Author    90    Fiction
    Set Test Variable    ${DELETE_BOOK}    ${book}

The Book Is Deleted
    [Documentation]    Delete the book via API
    Delete Book Via API    ${DELETE_BOOK}[id]

The Book Should Be Removed Successfully
    [Documentation]    Verify book is deleted
    ${response}=    GET On Session    books_api    /books/${DELETE_BOOK}[id]    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    404

The API Has Searchable Books
    [Documentation]    Create books for search testing
    Create Book Via API    Search Book 1    Search Author    160    Fiction
    Create Book Via API    Different Book    Other Author    140    Non-Fiction

Books Are Searched With Term "${search_term}"
    [Documentation]    Search for books
    ${books}=    Search Books Via API    ${search_term}
    Set Test Variable    ${SEARCH_RESULTS}    ${books}

Only Matching Books Should Be Returned
    [Documentation]    Verify search results are correct
    Should Not Be Empty    ${SEARCH_RESULTS}
    ${found_search_book}=    Set Variable    ${False}
    FOR    ${book}    IN    @{SEARCH_RESULTS}
        ${contains_search}=    Run Keyword And Return Status    Should Contain    ${book}[title]    Search
        IF    ${contains_search}
            ${found_search_book}=    Set Variable    ${True}
        END
    END
    Should Be True    ${found_search_book}    No books with 'Search' in title found

The API Has Books In Different Categories
    [Documentation]    Create books in different categories
    Create Book Via API    Fiction Book    Fiction Author    200    Fiction
    Create Book Via API    Science Book    Science Author    300    Non-Fiction

Books Are Filtered By "${category}" Category
    [Documentation]    Filter books by category
    ${books}=    Filter Books By Category Via API    ${category}
    Set Test Variable    ${FILTERED_BOOKS}    ${books}

Only Fiction Books Should Be Returned
    [Documentation]    Verify filter results are correct
    Should Not Be Empty    ${FILTERED_BOOKS}
    ${found_fiction_book}=    Set Variable    ${False}
    FOR    ${book}    IN    @{FILTERED_BOOKS}
        ${is_fiction}=    Run Keyword And Return Status    Should Contain    ${book}[category]    Fiction
        IF    ${is_fiction}
            ${found_fiction_book}=    Set Variable    ${True}
        END
    END
    Should Be True    ${found_fiction_book}    No Fiction books found in results

An Invalid Book Is Created
    [Documentation]    Attempt to create invalid book
    ${book_data}=    Create Dictionary    title=${EMPTY}    author=${EMPTY}
    ${response}=    POST On Session    books_api    /books    json=${book_data}    expected_status=any
    Set Test Variable    ${ERROR_RESPONSE}    ${response}

An Error Response Should Be Returned
    [Documentation]    Verify error response is returned
    Should Be Equal As Numbers    ${ERROR_RESPONSE.status_code}    422