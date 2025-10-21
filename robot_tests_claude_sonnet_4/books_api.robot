*** Settings ***
Documentation    API acceptance tests for Books Database Service
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
Scenario: User Can Retrieve All Books Via API
    [Documentation]    Test retrieving all books through API
    [Tags]    api    smoke
    Given the books API is available
    When I request all books from the API
    Then I should receive a successful response
    And the response should contain a list of books

Scenario: User Can Create A New Book Via API
    [Documentation]    Test creating a new book through API
    [Tags]    api    crud
    Given the books API is available
    When I create a new book with valid data
    Then I should receive a successful creation response
    And the book should be created with correct details

Scenario: User Can Retrieve A Specific Book Via API
    [Documentation]    Test retrieving a specific book by ID through API
    [Tags]    api    crud
    Given the books API is available
    And I have created a book via API
    When I request the book by its ID
    Then I should receive the correct book details

Scenario: User Can Update An Existing Book Via API
    [Documentation]    Test updating an existing book through API
    [Tags]    api    crud
    Given the books API is available
    And I have created a book via API
    When I update the book with new data
    Then I should receive a successful update response
    And the book should be updated with new details

Scenario: User Can Delete A Book Via API
    [Documentation]    Test deleting a book through API
    [Tags]    api    crud
    Given the books API is available
    And I have created a book via API
    When I delete the book
    Then I should receive a successful deletion response
    And the book should no longer exist

Scenario: User Can Toggle Book Favorite Status Via API
    [Documentation]    Test toggling book favorite status through API
    [Tags]    api    favorite
    Given the books API is available
    And I have created a book via API
    When I toggle the book favorite status to true
    Then I should receive a successful response
    And the book should be marked as favorite

Scenario: API Returns 404 For Non-Existent Book
    [Documentation]    Test API returns 404 for non-existent book
    [Tags]    api    error
    Given the books API is available
    When I request a non-existent book
    Then I should receive a 404 not found response

*** Keywords ***
Given the books API is available
    [Documentation]    Verify API is accessible
    ${response}=    Get All Books Via API
    Verify Response Status Code    ${response}    200

When I request all books from the API
    [Documentation]    Request all books from API
    ${response}=    Get All Books Via API
    Set Test Variable    ${API_RESPONSE}    ${response}

Then I should receive a successful response
    [Documentation]    Verify successful API response
    Verify Response Status Code    ${API_RESPONSE}    200

And the response should contain a list of books
    [Documentation]    Verify response contains books list
    ${books_list}=    Set Variable    ${API_RESPONSE.json()}
    Should Be True    isinstance($books_list, list)

When I create a new book with valid data
    [Documentation]    Create a new book with test data
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    ${response}=    Create Book Via API    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${TEST_TITLE}    ${title}
    Set Test Variable    ${TEST_AUTHOR}    ${author}
    Set Test Variable    ${TEST_PAGES}    ${pages}
    Set Test Variable    ${TEST_CATEGORY}    ${category}

Then I should receive a successful creation response
    [Documentation]    Verify successful book creation
    Verify Response Status Code    ${API_RESPONSE}    200

And the book should be created with correct details
    [Documentation]    Verify created book has correct details
    Verify Book Data In Response    ${API_RESPONSE}    ${TEST_TITLE}    ${TEST_AUTHOR}    ${TEST_PAGES}    ${TEST_CATEGORY}
    ${book_data}=    Set Variable    ${API_RESPONSE.json()}
    Set Test Variable    ${CREATED_BOOK_ID}    ${book_data}[id]

And I have created a book via API
    [Documentation]    Create a book for testing
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    ${response}=    Create Book Via API    ${title}    ${author}    ${pages}    ${category}
    ${book_data}=    Set Variable    ${response.json()}
    Set Test Variable    ${CREATED_BOOK_ID}    ${book_data}[id]
    Set Test Variable    ${TEST_TITLE}    ${title}
    Set Test Variable    ${TEST_AUTHOR}    ${author}
    Set Test Variable    ${TEST_PAGES}    ${pages}
    Set Test Variable    ${TEST_CATEGORY}    ${category}

When I request the book by its ID
    [Documentation]    Request specific book by ID
    ${response}=    Get Book By ID Via API    ${CREATED_BOOK_ID}
    Set Test Variable    ${API_RESPONSE}    ${response}

Then I should receive the correct book details
    [Documentation]    Verify correct book details in response
    Verify Response Status Code    ${API_RESPONSE}    200
    Verify Book Data In Response    ${API_RESPONSE}    ${TEST_TITLE}    ${TEST_AUTHOR}    ${TEST_PAGES}    ${TEST_CATEGORY}

When I update the book with new data
    [Documentation]    Update book with new test data
    ${new_title}    ${new_author}    ${new_pages}    ${new_category}=    Generate Random Book Data
    ${response}=    Update Book Via API    ${CREATED_BOOK_ID}    ${new_title}    ${new_author}    ${new_pages}    ${new_category}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${UPDATED_TITLE}    ${new_title}
    Set Test Variable    ${UPDATED_AUTHOR}    ${new_author}
    Set Test Variable    ${UPDATED_PAGES}    ${new_pages}
    Set Test Variable    ${UPDATED_CATEGORY}    ${new_category}

Then I should receive a successful update response
    [Documentation]    Verify successful book update
    Verify Response Status Code    ${API_RESPONSE}    200

And the book should be updated with new details
    [Documentation]    Verify book has updated details
    Verify Book Data In Response    ${API_RESPONSE}    ${UPDATED_TITLE}    ${UPDATED_AUTHOR}    ${UPDATED_PAGES}    ${UPDATED_CATEGORY}

When I delete the book
    [Documentation]    Delete the test book
    ${response}=    Delete Book Via API    ${CREATED_BOOK_ID}
    Set Test Variable    ${API_RESPONSE}    ${response}

Then I should receive a successful deletion response
    [Documentation]    Verify successful book deletion
    Verify Response Status Code    ${API_RESPONSE}    200

And the book should no longer exist
    [Documentation]    Verify book no longer exists
    ${response}=    Get Book By ID Via API    ${CREATED_BOOK_ID}
    Verify Response Status Code    ${response}    404

When I toggle the book favorite status to true
    [Documentation]    Toggle book favorite status to true
    ${response}=    Toggle Book Favorite Via API    ${CREATED_BOOK_ID}    ${True}
    Set Test Variable    ${API_RESPONSE}    ${response}

And the book should be marked as favorite
    [Documentation]    Verify book is marked as favorite
    ${book_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Be True    ${book_data}[favorite]

When I request a non-existent book
    [Documentation]    Request a book that doesn't exist
    ${response}=    Get Book By ID Via API    99999
    Set Test Variable    ${API_RESPONSE}    ${response}

Then I should receive a 404 not found response
    [Documentation]    Verify 404 response for non-existent book
    Verify Response Status Code    ${API_RESPONSE}    404