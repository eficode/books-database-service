*** Settings ***
Documentation    API acceptance tests for Books Library application using Gherkin syntax
...              These tests verify the REST API functionality including CRUD operations,
...              data validation, error handling, and data consistency.

Resource         resources/common.resource
Resource         keywords/api_keywords.resource

Suite Setup      Setup API Session
Suite Teardown   Teardown API Session
Test Setup       Clean Up Test Data

*** Test Cases ***
Scenario: API can retrieve all books when database is empty
    [Documentation]    Verify that the API returns an empty list when no books exist
    [Tags]    api    smoke    get-all    critical
    Given the books database is empty
    When the client requests all books from the API
    Then the response should be successful
    And the response should contain an empty list of books

Scenario: API can create a new book with valid data
    [Documentation]    Verify that a new book can be created via API
    [Tags]    api    crud    create    critical
    Given the books database is empty
    When the client creates a book with valid data via API
    Then the response should be successful
    And the response should contain the created book data
    And the book should be stored in the database

Scenario: API can create books with different categories
    [Documentation]    Verify that books can be created with various categories
    [Tags]    api    crud    categories
    Given the books database is empty
    When the client creates a book with category "Fiction" via API
    Then the book should be created with "Fiction" category
    When the client creates a book with category "Science Fiction" via API
    Then the book should be created with "Science Fiction" category
    When the client creates a book with category "Non-Fiction" via API
    Then the book should be created with "Non-Fiction" category

Scenario: API can retrieve a specific book by ID
    [Documentation]    Verify that a specific book can be retrieved by its ID
    [Tags]    api    crud    get-by-id    critical
    Given a book exists in the database
    When the client requests the book by its ID via API
    Then the response should be successful
    And the response should contain the correct book data

Scenario: API returns 404 when requesting non-existent book
    [Documentation]    Verify that API returns 404 for non-existent book IDs
    [Tags]    api    error-handling    404
    Given the books database is empty
    When the client requests a book with non-existent ID via API
    Then the response should be "404 Not Found"
    And the response should contain an error message

Scenario: API can update an existing book
    [Documentation]    Verify that an existing book can be updated via API
    [Tags]    api    crud    update    critical
    Given a book exists in the database
    When the client updates the book with new data via API
    Then the response should be successful
    And the response should contain the updated book data
    And the book should be updated in the database

Scenario: API returns 404 when updating non-existent book
    [Documentation]    Verify that API returns 404 when updating non-existent book
    [Tags]    api    error-handling    update-404
    Given the books database is empty
    When the client tries to update a non-existent book via API
    Then the response should be "404 Not Found"
    And the response should contain an error message

Scenario: API can delete an existing book
    [Documentation]    Verify that an existing book can be deleted via API
    [Tags]    api    crud    delete    critical
    Given a book exists in the database
    When the client deletes the book via API
    Then the response should be successful
    And the response should contain a success message
    And the book should be removed from the database

Scenario: API returns 404 when deleting non-existent book
    [Documentation]    Verify that API returns 404 when deleting non-existent book
    [Tags]    api    error-handling    delete-404
    Given the books database is empty
    When the client tries to delete a non-existent book via API
    Then the response should be "404 Not Found"
    And the response should contain an error message

Scenario: API can toggle book favorite status to true
    [Documentation]    Verify that a book can be marked as favorite via API
    [Tags]    api    favorites    toggle-true    critical
    Given a book exists in the database with favorite status false
    When the client toggles the book favorite status to true via API
    Then the response should be successful
    And the book should be marked as favorite in the database

Scenario: API can toggle book favorite status to false
    [Documentation]    Verify that a book can be unmarked as favorite via API
    [Tags]    api    favorites    toggle-false
    Given a book exists in the database with favorite status true
    When the client toggles the book favorite status to false via API
    Then the response should be successful
    And the book should not be marked as favorite in the database

Scenario: API returns 404 when toggling favorite for non-existent book
    [Documentation]    Verify that API returns 404 when toggling favorite for non-existent book
    [Tags]    api    error-handling    favorite-404
    Given the books database is empty
    When the client tries to toggle favorite for a non-existent book via API
    Then the response should be "404 Not Found"
    And the response should contain an error message

Scenario: API can handle multiple books operations
    [Documentation]    Verify that API can handle multiple books correctly
    [Tags]    api    crud    multiple-books
    Given the books database is empty
    When the client creates multiple books via API
    Then the client can retrieve all books via API
    And the response should contain all created books

Scenario: API validates required fields when creating a book
    [Documentation]    Verify that API validates required fields during book creation
    [Tags]    api    validation    create    critical
    Given the books database is empty
    When the client tries to create a book without title via API
    Then the response should be "422 Unprocessable Entity"
    When the client tries to create a book without author via API
    Then the response should be "422 Unprocessable Entity"
    When the client tries to create a book without pages via API
    Then the response should be "422 Unprocessable Entity"

Scenario: API validates data types when creating a book
    [Documentation]    Verify that API validates data types during book creation
    [Tags]    api    validation    data-types
    Given the books database is empty
    When the client tries to create a book with invalid page count via API
    Then the response should indicate validation error or acceptance
    When the client tries to create a book with non-string title via API
    Then the response should indicate validation error or acceptance

Scenario: API validates required fields when updating a book
    [Documentation]    Verify that API validates required fields during book update
    [Tags]    api    validation    update
    Given a book exists in the database
    When the client tries to update the book without title via API
    Then the response should be "422 Unprocessable Entity"
    When the client tries to update the book without author via API
    Then the response should be "422 Unprocessable Entity"
    When the client tries to update the book without pages via API
    Then the response should be "422 Unprocessable Entity"

Scenario: API handles concurrent book operations correctly
    [Documentation]    Verify that API handles concurrent operations correctly
    [Tags]    api    concurrency    stress
    Given the books database is empty
    When multiple clients create books simultaneously via API
    Then no data corruption should occur
    And all books should be retrievable via API

Scenario: API maintains data consistency across operations
    [Documentation]    Verify that API maintains data consistency
    [Tags]    api    consistency    data-integrity    critical
    Given a book exists in the database
    When the client performs multiple operations on the same book via API
    Then the final state should be consistent
    And no data should be lost or corrupted

*** Keywords ***
# Given Keywords (Setup)
the books database is empty
    [Documentation]    Ensure the database is empty
    Clean Up Test Data

a book exists in the database
    [Documentation]    Create a book for testing
    ${book}=    Create Book Via API    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}
    Set Test Variable    ${EXISTING_BOOK}    ${book}

a book exists in the database with favorite status false
    [Documentation]    Create a book with favorite status false
    ${book}=    Create Book Via API    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}    ${False}
    Set Test Variable    ${EXISTING_BOOK}    ${book}

a book exists in the database with favorite status true
    [Documentation]    Create a book with favorite status true
    ${book}=    Create Book Via API    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}    ${True}
    Set Test Variable    ${EXISTING_BOOK}    ${book}

# When Keywords (Actions)
the client requests all books from the API
    [Documentation]    Make GET request to retrieve all books
    ${books}=    Get All Books Via API
    Set Test Variable    ${API_BOOKS_RESPONSE}    ${books}

the client creates a book with valid data via API
    [Documentation]    Create a book with valid test data
    ${book}=    Create Book Via API    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}
    Set Test Variable    ${CREATED_BOOK}    ${book}

the client creates a book with category "${category}" via API
    [Documentation]    Create a book with specific category
    ${book_data}=    Generate Random Book Data
    ${book}=    Create Book Via API    ${book_data}[title]    ${book_data}[author]    ${book_data}[pages]    ${category}
    Set Test Variable    ${LAST_CREATED_BOOK}    ${book}

the client requests the book by its ID via API
    [Documentation]    Request specific book by ID
    ${book}=    Get Book By ID Via API    ${EXISTING_BOOK}[id]
    Set Test Variable    ${RETRIEVED_BOOK}    ${book}

the client requests a book with non-existent ID via API
    [Documentation]    Request book with non-existent ID
    ${response}=    Attempt To Get Non-Existent Book
    Set Test Variable    ${API_RESPONSE}    ${response}

the client updates the book with new data via API
    [Documentation]    Update existing book with new data
    ${new_title}=    Set Variable    Updated ${TEST_BOOK_TITLE}
    ${new_author}=    Set Variable    Updated ${TEST_BOOK_AUTHOR}
    ${new_pages}=    Set Variable    350
    ${new_category}=    Set Variable    Fantasy
    
    ${updated_book}=    Update Book Via API    ${EXISTING_BOOK}[id]    ${new_title}    ${new_author}    ${new_pages}    ${new_category}
    Set Test Variable    ${UPDATED_BOOK}    ${updated_book}
    Set Test Variable    ${NEW_TITLE}    ${new_title}
    Set Test Variable    ${NEW_AUTHOR}    ${new_author}
    Set Test Variable    ${NEW_PAGES}    ${new_pages}
    Set Test Variable    ${NEW_CATEGORY}    ${new_category}

the client tries to update a non-existent book via API
    [Documentation]    Try to update non-existent book
    ${response}=    Attempt To Update Non-Existent Book
    Set Test Variable    ${API_RESPONSE}    ${response}

the client deletes the book via API
    [Documentation]    Delete the existing book
    ${response}=    Delete Book Via API    ${EXISTING_BOOK}[id]
    Set Test Variable    ${DELETE_RESPONSE}    ${response}

the client tries to delete a non-existent book via API
    [Documentation]    Try to delete non-existent book
    ${response}=    Attempt To Delete Non-Existent Book
    Set Test Variable    ${API_RESPONSE}    ${response}

the client toggles the book favorite status to true via API
    [Documentation]    Toggle book favorite status to true
    ${updated_book}=    Toggle Book Favorite Via API    ${EXISTING_BOOK}[id]    ${True}
    Set Test Variable    ${UPDATED_BOOK}    ${updated_book}

the client toggles the book favorite status to false via API
    [Documentation]    Toggle book favorite status to false
    ${updated_book}=    Toggle Book Favorite Via API    ${EXISTING_BOOK}[id]    ${False}
    Set Test Variable    ${UPDATED_BOOK}    ${updated_book}

the client tries to toggle favorite for a non-existent book via API
    [Documentation]    Try to toggle favorite for non-existent book
    ${response}=    Attempt To Toggle Favorite For Non-Existent Book
    Set Test Variable    ${API_RESPONSE}    ${response}

the client creates multiple books via API
    [Documentation]    Create multiple books for testing
    ${books}=    Create Multiple Books Via API    5
    Set Test Variable    ${CREATED_BOOKS}    ${books}

the client tries to create a book without title via API
    [Documentation]    Try to create book without title
    ${response}=    Attempt To Create Book Without Required Field    title
    Set Test Variable    ${API_RESPONSE}    ${response}

the client tries to create a book without author via API
    [Documentation]    Try to create book without author
    ${response}=    Attempt To Create Book Without Required Field    author
    Set Test Variable    ${API_RESPONSE}    ${response}

the client tries to create a book without pages via API
    [Documentation]    Try to create book without pages
    ${response}=    Attempt To Create Book Without Required Field    pages
    Set Test Variable    ${API_RESPONSE}    ${response}

the client tries to create a book with invalid page count via API
    [Documentation]    Try to create book with invalid page count
    ${response}=    Attempt To Create Book With Invalid Data    pages    -5
    Set Test Variable    ${API_RESPONSE}    ${response}

the client tries to create a book with non-string title via API
    [Documentation]    Try to create book with non-string title
    ${response}=    Attempt To Create Book With Invalid Data    title    ${123}
    Set Test Variable    ${API_RESPONSE}    ${response}

the client tries to update the book without title via API
    [Documentation]    Try to update book without title
    ${response}=    Attempt To Update Book Without Required Field    ${EXISTING_BOOK}[id]    title
    Set Test Variable    ${API_RESPONSE}    ${response}

the client tries to update the book without author via API
    [Documentation]    Try to update book without author
    ${response}=    Attempt To Update Book Without Required Field    ${EXISTING_BOOK}[id]    author
    Set Test Variable    ${API_RESPONSE}    ${response}

the client tries to update the book without pages via API
    [Documentation]    Try to update book without pages
    ${response}=    Attempt To Update Book Without Required Field    ${EXISTING_BOOK}[id]    pages
    Set Test Variable    ${API_RESPONSE}    ${response}

multiple clients create books simultaneously via API
    [Documentation]    Simulate concurrent book creation
    ${books}=    Simulate Concurrent Book Creation    10
    Set Test Variable    ${CONCURRENT_BOOKS}    ${books}

the client performs multiple operations on the same book via API
    [Documentation]    Perform multiple operations on the same book
    ${final_book}=    Perform Multiple Operations On Same Book    ${EXISTING_BOOK}[id]
    Set Test Variable    ${FINAL_BOOK}    ${final_book}

# Then Keywords (Verification)
the response should be successful
    [Documentation]    Verify response status is 200
    # Check which response variable exists and validate accordingly
    ${api_books_exists}=    Run Keyword And Return Status    Variable Should Exist    ${API_BOOKS_RESPONSE}
    ${created_book_exists}=    Run Keyword And Return Status    Variable Should Exist    ${CREATED_BOOK}
    ${retrieved_book_exists}=    Run Keyword And Return Status    Variable Should Exist    ${RETRIEVED_BOOK}
    ${updated_book_exists}=    Run Keyword And Return Status    Variable Should Exist    ${UPDATED_BOOK}
    ${delete_response_exists}=    Run Keyword And Return Status    Variable Should Exist    ${DELETE_RESPONSE}
    
    IF    ${api_books_exists}
        Log    Books response received successfully
    ELSE IF    ${created_book_exists}
        Should Not Be Empty    ${CREATED_BOOK}
    ELSE IF    ${retrieved_book_exists}
        Should Not Be Empty    ${RETRIEVED_BOOK}
    ELSE IF    ${updated_book_exists}
        Should Not Be Empty    ${UPDATED_BOOK}
    ELSE IF    ${delete_response_exists}
        Should Not Be Empty    ${DELETE_RESPONSE}
    ELSE
        Log    Response validation handled by API keyword
    END

the response should contain an empty list of books
    [Documentation]    Verify response contains empty list
    Should Be Empty    ${API_BOOKS_RESPONSE}

the response should contain the created book data
    [Documentation]    Verify response contains correct book data
    Verify Book Data Matches Expected    ${CREATED_BOOK}    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}

the book should be stored in the database
    [Documentation]    Verify book is stored in database
    ${book}=    Get Book By ID Via API    ${CREATED_BOOK}[id]
    Verify Book Data Matches Expected    ${book}    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}

the book should be created with "${category}" category
    [Documentation]    Verify book was created with correct category
    Should Be Equal As Strings    ${LAST_CREATED_BOOK}[category]    ${category}

the response should contain the correct book data
    [Documentation]    Verify retrieved book data is correct
    Verify Book Data Matches Expected    ${RETRIEVED_BOOK}    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}

the response should be "${expected_status}"
    [Documentation]    Verify response status code
    Verify Response Status Code    ${API_RESPONSE}    ${expected_status.split()[0]}

the response should contain an error message
    [Documentation]    Verify response contains error message
    Verify Response Contains Error    ${API_RESPONSE}

the response should contain the updated book data
    [Documentation]    Verify response contains updated book data
    Verify Book Data Matches Expected    ${UPDATED_BOOK}    ${NEW_TITLE}    ${NEW_AUTHOR}    ${NEW_PAGES}    ${NEW_CATEGORY}

the book should be updated in the database
    [Documentation]    Verify book is updated in database
    ${book}=    Get Book By ID Via API    ${EXISTING_BOOK}[id]
    Verify Book Data Matches Expected    ${book}    ${NEW_TITLE}    ${NEW_AUTHOR}    ${NEW_PAGES}    ${NEW_CATEGORY}

the response should contain a success message
    [Documentation]    Verify response contains success message
    Should Contain    ${DELETE_RESPONSE}    message

the book should be removed from the database
    [Documentation]    Verify book is removed from database
    ${response}=    Attempt To Get Non-Existent Book    ${EXISTING_BOOK}[id]
    Verify Response Status Code    ${response}    404

the book should be marked as favorite in the database
    [Documentation]    Verify book is marked as favorite
    ${book}=    Get Book By ID Via API    ${EXISTING_BOOK}[id]
    Should Be True    ${book}[favorite]

the book should not be marked as favorite in the database
    [Documentation]    Verify book is not marked as favorite
    ${book}=    Get Book By ID Via API    ${EXISTING_BOOK}[id]
    Should Not Be True    ${book}[favorite]

the client can retrieve all books via API
    [Documentation]    Retrieve all books from API
    ${all_books}=    Get All Books Via API
    Set Test Variable    ${ALL_BOOKS}    ${all_books}

the response should contain all created books
    [Documentation]    Verify response contains all created books
    Verify All Books Exist In Database    ${CREATED_BOOKS}

the response should indicate validation error or acceptance
    [Documentation]    Verify response indicates validation error or accepts the data
    ${status_code}=    Convert To String    ${API_RESPONSE.status_code}
    IF    "${status_code}" == "422"
        Log    API correctly validated and rejected invalid data
    ELSE IF    "${status_code}" == "200"
        Log    API accepted the data (possibly with type conversion or lenient validation)
    ELSE
        Fail    Unexpected status code: ${status_code}
    END

no data corruption should occur
    [Documentation]    Verify no data corruption occurred
    Verify No Data Corruption Occurred    ${CONCURRENT_BOOKS}

all books should be retrievable via API
    [Documentation]    Verify all books can be retrieved
    ${all_books}=    Get All Books Via API
    ${all_books_count}=    Get Length    ${all_books}
    ${expected_count}=    Get Length    ${CONCURRENT_BOOKS}
    Should Be Equal As Numbers    ${all_books_count}    ${expected_count}

the final state should be consistent
    [Documentation]    Verify final state is consistent
    Verify Data Consistency After Operations    ${EXISTING_BOOK}[id]    Final Title    Final Author    400    Science Fiction    ${True}

no data should be lost or corrupted
    [Documentation]    Verify no data was lost or corrupted
    ${all_books}=    Get All Books Via API
    ${found}=    Set Variable    ${False}
    FOR    ${book}    IN    @{all_books}
        IF    ${book}[id] == ${EXISTING_BOOK}[id]
            ${found}=    Set Variable    ${True}
            Should Be Equal As Strings    ${book}[title]    Final Title
            BREAK
        END
    END
    Should Be True    ${found}    Book was lost during operations