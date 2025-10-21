*** Settings ***
Documentation    API acceptance tests for Books Database Service.
...              Tests cover CRUD operations, favorite toggle, and error handling.
Resource         resources/common.resource
Resource         resources/api_keywords.resource
Suite Setup      Setup API Test Suite
Suite Teardown   Teardown API Test Suite
Test Setup       Create Session For API

*** Keywords ***
Setup API Test Suite
    [Documentation]    Setup test suite with Docker environment
    Setup Test Environment

Teardown API Test Suite
    [Documentation]    Cleanup test suite environment
    Teardown Test Environment

*** Test Cases ***
User can retrieve all books via API
    [Documentation]    Test retrieving all books through API
    [Tags]    api    smoke
    Given the books API is available
    When all books are requested from the API
    Then a successful response should be received
    And the response should contain a list of books

User can create a new book via API
    [Documentation]    Test creating a new book through API
    [Tags]    api    crud
    Given the books API is available
    When a new book is created with valid data
    Then a successful creation response should be received
    And the book should be created with correct details

User can retrieve a specific book via API
    [Documentation]    Test retrieving a specific book by ID through API
    [Tags]    api    crud
    Given the books API is available
    And a book has been created via API
    When the book is requested by its ID
    Then the correct book details should be received

User can update an existing book via API
    [Documentation]    Test updating an existing book through API
    [Tags]    api    crud
    Given the books API is available
    And a book has been created via API
    When the book is updated with new data
    Then a successful update response should be received
    And the book should be updated with new details

User can delete a book via API
    [Documentation]    Test deleting a book through API
    [Tags]    api    crud
    Given the books API is available
    And a book has been created via API
    When the book is deleted
    Then a successful deletion response should be received
    And the book should no longer exist

User can toggle book favorite status via API
    [Documentation]    Test toggling book favorite status through API
    [Tags]    api    favorite
    Given the books API is available
    And a book has been created via API
    When the book favorite status is toggled to true
    Then a successful response should be received
    And the book should be marked as favorite

API returns 404 for non-existent book
    [Documentation]    Test API returns 404 for non-existent book
    [Tags]    api    error
    Given the books API is available
    When a non-existent book is requested
    Then a 404 not found response should be received

*** Keywords ***
The Books API Is Available
    [Documentation]    Verify API is accessible
    ${response}=    Get All Books Via API
    Verify Response Status Code    ${response}    200

All Books Are Requested From The API
    [Documentation]    Request all books from API
    ${response}=    Get All Books Via API
    Set Test Variable    ${API_RESPONSE}    ${response}

A Successful Response Should Be Received
    [Documentation]    Verify successful API response
    Verify Response Status Code    ${API_RESPONSE}    200

The Response Should Contain A List Of Books
    [Documentation]    Verify response contains books list
    ${books_list}=    Set Variable    ${API_RESPONSE.json()}
    Should Be True    isinstance($books_list, list)

A New Book Is Created With Valid Data
    [Documentation]    Create a new book with test data
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    ${response}=    Create Book Via API    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${TEST_TITLE}    ${title}
    Set Test Variable    ${TEST_AUTHOR}    ${author}
    Set Test Variable    ${TEST_PAGES}    ${pages}
    Set Test Variable    ${TEST_CATEGORY}    ${category}

A Successful Creation Response Should Be Received
    [Documentation]    Verify successful book creation
    Verify Response Status Code    ${API_RESPONSE}    200

The Book Should Be Created With Correct Details
    [Documentation]    Verify created book has correct details
    Verify Book Data In Response    ${API_RESPONSE}    ${TEST_TITLE}    ${TEST_AUTHOR}
    ...                             ${TEST_PAGES}    ${TEST_CATEGORY}
    ${book_data}=    Set Variable    ${API_RESPONSE.json()}
    Set Test Variable    ${CREATED_BOOK_ID}    ${book_data}[id]

A Book Has Been Created Via API
    [Documentation]    Create a book for testing
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    ${response}=    Create Book Via API    ${title}    ${author}    ${pages}    ${category}
    ${book_data}=    Set Variable    ${response.json()}
    Set Test Variable    ${CREATED_BOOK_ID}    ${book_data}[id]
    Set Test Variable    ${TEST_TITLE}    ${title}
    Set Test Variable    ${TEST_AUTHOR}    ${author}
    Set Test Variable    ${TEST_PAGES}    ${pages}
    Set Test Variable    ${TEST_CATEGORY}    ${category}

The Book Is Requested By Its ID
    [Documentation]    Request specific book by ID
    ${response}=    Get Book By ID Via API    ${CREATED_BOOK_ID}
    Set Test Variable    ${API_RESPONSE}    ${response}

The Correct Book Details Should Be Received
    [Documentation]    Verify correct book details in response
    Verify Response Status Code    ${API_RESPONSE}    200
    Verify Book Data In Response    ${API_RESPONSE}    ${TEST_TITLE}    ${TEST_AUTHOR}
    ...                             ${TEST_PAGES}    ${TEST_CATEGORY}

The Book Is Updated With New Data
    [Documentation]    Update book with new test data
    ${new_title}    ${new_author}    ${new_pages}    ${new_category}=    Generate Random Book Data
    ${response}=    Update Book Via API    ${CREATED_BOOK_ID}    ${new_title}    ${new_author}
    ...                                    ${new_pages}    ${new_category}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${UPDATED_TITLE}    ${new_title}
    Set Test Variable    ${UPDATED_AUTHOR}    ${new_author}
    Set Test Variable    ${UPDATED_PAGES}    ${new_pages}
    Set Test Variable    ${UPDATED_CATEGORY}    ${new_category}

A Successful Update Response Should Be Received
    [Documentation]    Verify successful book update
    Verify Response Status Code    ${API_RESPONSE}    200

The Book Should Be Updated With New Details
    [Documentation]    Verify book has updated details
    Verify Book Data In Response    ${API_RESPONSE}    ${UPDATED_TITLE}    ${UPDATED_AUTHOR}
    ...                             ${UPDATED_PAGES}    ${UPDATED_CATEGORY}

The Book Is Deleted
    [Documentation]    Delete the test book
    ${response}=    Delete Book Via API    ${CREATED_BOOK_ID}
    Set Test Variable    ${API_RESPONSE}    ${response}

A Successful Deletion Response Should Be Received
    [Documentation]    Verify successful book deletion
    Verify Response Status Code    ${API_RESPONSE}    200

The Book Should No Longer Exist
    [Documentation]    Verify book no longer exists
    ${response}=    Get Book By ID Via API    ${CREATED_BOOK_ID}
    Verify Response Status Code    ${response}    404

The Book Favorite Status Is Toggled To True
    [Documentation]    Toggle book favorite status to true
    ${response}=    Toggle Book Favorite Via API    ${CREATED_BOOK_ID}    ${True}
    Set Test Variable    ${API_RESPONSE}    ${response}

The Book Should Be Marked As Favorite
    [Documentation]    Verify book is marked as favorite
    ${book_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Be True    ${book_data}[favorite]

A Non-Existent Book Is Requested
    [Documentation]    Request a book that doesn't exist
    ${response}=    Get Book By ID Via API    99999
    Set Test Variable    ${API_RESPONSE}    ${response}

A 404 Not Found Response Should Be Received
    [Documentation]    Verify 404 response for non-existent book
    Verify Response Status Code    ${API_RESPONSE}    404
