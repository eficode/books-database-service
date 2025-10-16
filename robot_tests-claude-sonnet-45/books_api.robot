*** Settings ***
Documentation    API acceptance tests for Books Library REST API using Gherkin syntax
Resource         resources/common.resource
Resource         keywords/api_keywords.resource

Suite Setup      Setup Test Suite
Suite Teardown   Teardown Test Suite
Test Setup       Setup Test Case
Test Teardown    Teardown Test Case

Test Tags        api    acceptance

*** Variables ***
${VALID_BOOK_DATA}       {"title": "API Test Book", "author": "API Author", "pages": 300, "category": "Science Fiction", "favorite": false}

*** Keywords ***
Setup Test Suite
    [Documentation]    Suite-level setup for API tests
    Setup API Session

Teardown Test Suite
    [Documentation]    Suite-level teardown for API tests
    Clean Up Test Books
    Teardown API Session

Setup Test Case
    [Documentation]    Test case setup for API tests
    Clean Up Test Books

Teardown Test Case
    [Documentation]    Test case teardown for API tests
    Clean Up Test Books

*** Test Cases ***
Scenario: API Is Available And Responds To Health Check
    [Documentation]    Verify that the Books API is accessible and responds correctly
    [Tags]    smoke    health-check
    Given The Books API Is Available
    When I Send A GET Request To Get All Books
    Then The Response Status Should Be    200
    And The Response Should Contain A List Of Books

Scenario: User Can Retrieve All Books When Database Is Empty
    [Documentation]    Verify that API returns empty list when no books exist
    [Tags]    smoke    get-books    empty-state
    Given The Books API Is Available
    When I Send A GET Request To Get All Books
    Then The Response Status Should Be    200
    And The Response Should Contain A List Of Books
    And The Books List Should Contain    0

Scenario: User Can Create A New Book Via API
    [Documentation]    Verify that users can create books through the REST API
    [Tags]    smoke    create-book    crud
    Given The Books API Is Available
    When I Send A POST Request To Create A Book    ${VALID_BOOK_DATA}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    API Test Book    API Author    300    Science Fiction

Scenario: User Can Retrieve A Specific Book By ID
    [Documentation]    Verify that users can retrieve individual books by ID
    [Tags]    smoke    get-book    crud
    Given The Books API Is Available
    And I Have A Book In The Database    Specific Book    Specific Author    250    Fantasy
    When I Send A GET Request To Get Book By ID    ${TEST_BOOK_ID}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Specific Book    Specific Author    250    Fantasy

Scenario: User Can Update An Existing Book Via API
    [Documentation]    Verify that users can update book details through the API
    [Tags]    update-book    crud
    Given The Books API Is Available
    And I Have A Book In The Database    Original Title    Original Author    200    Fiction
    When I Send A PUT Request To Update A Book    ${TEST_BOOK_ID}    {"title": "Updated Title", "author": "Updated Author", "pages": 350, "category": "Science", "favorite": false}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Updated Title    Updated Author    350    Science

Scenario: User Can Delete A Book Via API
    [Documentation]    Verify that users can delete books through the API
    [Tags]    delete-book    crud
    Given The Books API Is Available
    And I Have A Book In The Database    Book To Delete    Delete Author    180    Horror
    When I Send A DELETE Request To Delete A Book    ${TEST_BOOK_ID}
    Then The Response Status Should Be    200
    And The Response Should Contain Success Message    Book deleted successfully

Scenario: User Can Toggle Book Favorite Status Via API
    [Documentation]    Verify that users can mark/unmark books as favorites
    [Tags]    favorite-book    patch
    Given The Books API Is Available
    And I Have A Book In The Database    Favorite Test    Favorite Author    220    Romance
    When I Send A PATCH Request To Toggle Book Favorite    ${TEST_BOOK_ID}    ${True}
    Then The Response Status Should Be    200
    And The Book Should Have Favorite Status    ${True}

Scenario: User Can Untoggle Book Favorite Status Via API
    [Documentation]    Verify that users can remove favorite status from books
    [Tags]    favorite-book    patch
    Given The Books API Is Available
    And I Have A Book In The Database    Unfavorite Test    Unfavorite Author    190    Biography
    And I Send A PATCH Request To Toggle Book Favorite    ${TEST_BOOK_ID}    ${True}
    When I Send A PATCH Request To Toggle Book Favorite    ${TEST_BOOK_ID}    ${False}
    Then The Response Status Should Be    200
    And The Book Should Have Favorite Status    ${False}

Scenario: API Returns 404 When Requesting Non-Existent Book
    [Documentation]    Verify that API returns 404 for non-existent book IDs
    [Tags]    error-handling    404    not-found
    Given The Books API Is Available
    When I Send A GET Request To Get Book By ID    99999
    Then The Response Status Should Be    404
    And The Response Should Contain Error Message    Book not found

Scenario: API Returns 404 When Updating Non-Existent Book
    [Documentation]    Verify that API returns 404 when trying to update non-existent book
    [Tags]    error-handling    404    not-found    update
    Given The Books API Is Available
    When I Send A PUT Request To Update A Book    99999    {"title": "Non-existent", "author": "No Author", "pages": 100, "category": "Fiction", "favorite": false}
    Then The Response Status Should Be    404
    And The Response Should Contain Error Message    Book not found

Scenario: API Returns 404 When Deleting Non-Existent Book
    [Documentation]    Verify that API returns 404 when trying to delete non-existent book
    [Tags]    error-handling    404    not-found    delete
    Given The Books API Is Available
    When I Send A DELETE Request To Delete A Book    99999
    Then The Response Status Should Be    404
    And The Response Should Contain Error Message    Book not found

Scenario: API Returns 404 When Toggling Favorite On Non-Existent Book
    [Documentation]    Verify that API returns 404 when trying to toggle favorite on non-existent book
    [Tags]    error-handling    404    not-found    favorite
    Given The Books API Is Available
    When I Send A PATCH Request To Toggle Book Favorite    99999    ${True}
    Then The Response Status Should Be    404
    And The Response Should Contain Error Message    Book not found

Scenario: API Validates Required Fields When Creating Book
    [Documentation]    Verify that API validates required fields during book creation
    [Tags]    validation    error-handling    create-book
    Given The Books API Is Available
    When Create Book With Invalid Data    {"author": "Author Only", "pages": 200}
    Then The Response Status Should Be    422
    And Verify Validation Error Response

Scenario: API Validates Data Types When Creating Book
    [Documentation]    Verify that API validates data types during book creation
    [Tags]    validation    error-handling    data-types
    Given The Books API Is Available
    When Create Book With Invalid Data    {"title": "Valid Title", "author": "Valid Author", "pages": "not_a_number", "category": "Fiction"}
    Then The Response Status Should Be    422
    And Verify Validation Error Response

Scenario: API Validates Positive Page Numbers
    [Documentation]    Verify that API validates page numbers are positive
    [Tags]    validation    error-handling    pages
    Given The Books API Is Available
    When Create Book With Invalid Data    {"title": "Valid Title", "author": "Valid Author", "pages": -100, "category": "Fiction"}
    Then The Response Status Should Be    422
    And Verify Validation Error Response

Scenario: User Can Create Books With All Valid Categories
    [Documentation]    Verify that all predefined categories are accepted
    [Tags]    categories    create-book    comprehensive
    Given The Books API Is Available
    # Test each valid category
    When I Send A POST Request To Create A Book    {"title": "Fiction Book", "author": "Author", "pages": 200, "category": "Fiction", "favorite": false}
    Then The Response Status Should Be    200
    When I Send A POST Request To Create A Book    {"title": "Non-Fiction Book", "author": "Author", "pages": 200, "category": "Non-Fiction", "favorite": false}
    Then The Response Status Should Be    200
    When I Send A POST Request To Create A Book    {"title": "Fantasy Book", "author": "Author", "pages": 200, "category": "Fantasy", "favorite": false}
    Then The Response Status Should Be    200
    When I Send A POST Request To Create A Book    {"title": "Science Fiction Book", "author": "Author", "pages": 200, "category": "Science Fiction", "favorite": false}
    Then The Response Status Should Be    200

Scenario: User Can Create Books With Default Values
    [Documentation]    Verify that books can be created with minimal required data
    [Tags]    defaults    create-book
    Given The Books API Is Available
    When I Send A POST Request To Create A Book    {"title": "Minimal Book", "author": "Minimal Author", "pages": 100}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Minimal Book    Minimal Author    100    Fiction

Scenario: API Handles Multiple Concurrent Requests
    [Documentation]    Verify that API can handle multiple simultaneous requests
    [Tags]    performance    concurrency    stress
    Given The Books API Is Available
    And I Have Multiple Books In The Database    10
    When I Send A GET Request To Get All Books
    Then The Response Status Should Be    200
    And The Books List Should Contain    10
    And Verify Response Time    2.0

Scenario: API Maintains Data Consistency During CRUD Operations
    [Documentation]    Verify data consistency throughout complete CRUD lifecycle
    [Tags]    crud    consistency    integration
    Given The Books API Is Available
    # Create
    When I Send A POST Request To Create A Book    {"title": "Consistency Test", "author": "Test Author", "pages": 250, "category": "Science", "favorite": false}
    Then The Response Status Should Be    200
    ${book_id}=    Set Variable    ${CREATED_BOOK}[id]
    # Read
    When I Send A GET Request To Get Book By ID    ${book_id}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Consistency Test    Test Author    250    Science
    # Update
    When I Send A PUT Request To Update A Book    ${book_id}    {"title": "Updated Consistency", "author": "Updated Author", "pages": 300, "category": "Fantasy", "favorite": true}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Updated Consistency    Updated Author    300    Fantasy
    And The Book Should Have Favorite Status    ${True}
    # Verify Update
    When I Send A GET Request To Get Book By ID    ${book_id}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Updated Consistency    Updated Author    300    Fantasy
    And The Book Should Have Favorite Status    ${True}
    # Delete
    When I Send A DELETE Request To Delete A Book    ${book_id}
    Then The Response Status Should Be    200
    # Verify Deletion
    When I Send A GET Request To Get Book By ID    ${book_id}
    Then The Response Status Should Be    404

Scenario: API Returns Proper Content-Type Headers
    [Documentation]    Verify that API returns correct content-type headers
    [Tags]    headers    content-type
    Given The Books API Is Available
    When I Send A GET Request To Get All Books
    Then The Response Status Should Be    200
    And Verify Response Headers    content-type    application/json

Scenario: API Handles Large Book Data
    [Documentation]    Verify that API can handle books with large amounts of text
    [Tags]    performance    large-data
    Given The Books API Is Available
    ${long_title}=    Set Variable    ${'Very Long Title ' * 20}
    ${long_author}=    Set Variable    ${'Very Long Author Name ' * 15}
    When I Send A POST Request To Create A Book    {"title": "${long_title}", "author": "${long_author}", "pages": 1000, "category": "Fiction", "favorite": false}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    ${long_title}    ${long_author}    1000    Fiction

Scenario: API Handles Special Characters In Book Data
    [Documentation]    Verify that API properly handles special characters and Unicode
    [Tags]    unicode    special-characters    internationalization
    Given The Books API Is Available
    When I Send A POST Request To Create A Book    {"title": "Spéciål Chåråctërs & Ümläüts", "author": "Authör with Àccénts", "pages": 200, "category": "Fiction", "favorite": false}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Spéciål Chåråctërs & Ümläüts    Authör with Àccénts    200    Fiction

Scenario: API Maintains Favorite Status Across Operations
    [Documentation]    Verify that favorite status is preserved during book updates
    [Tags]    favorite-book    consistency    update
    Given The Books API Is Available
    And I Have A Book In The Database    Favorite Consistency    Author    200    Fiction
    And I Send A PATCH Request To Toggle Book Favorite    ${TEST_BOOK_ID}    ${True}
    When I Send A PUT Request To Update A Book    ${TEST_BOOK_ID}    {"title": "Updated Favorite", "author": "Updated Author", "pages": 250, "category": "Science", "favorite": true}
    Then The Response Status Should Be    200
    And The Response Should Contain Book Data    Updated Favorite    Updated Author    250    Science
    And The Book Should Have Favorite Status    ${True}