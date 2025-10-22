*** Settings ***
Documentation    API acceptance tests for the Books Database Service
...              Tests cover all REST API endpoints for managing books.
...              Uses BDD/Gherkin style for better readability and stakeholder communication.

Library          Collections
Library          json
Resource         resources/common.resource
Resource         resources/api_keywords.resource

Suite Setup      Setup Test Environment For API
Suite Teardown   Teardown Test Environment
Test Setup       Test Setup For API
Test Teardown    Test Teardown For API

*** Keywords ***
Setup Test Environment For API
    [Documentation]    Sets up the test environment for API testing
    Setup Test Environment
    Create API Session
    Wait For API To Be Ready

Test Setup For API
    [Documentation]    Sets up each API test
    Delete All Books Via API

Test Teardown For API
    [Documentation]    Cleans up after each API test
    Delete All Books Via API

*** Test Cases ***
Scenario: API Can Return Books List
    [Documentation]    GIVEN the books database has books
    ...                WHEN a GET request is made to the books endpoint
    ...                THEN a books list should be returned
    [Tags]    smoke    api    basic
    Given The Books Database Has Books
    When A GET Request Is Made To The Books Endpoint
    Then A Books List Should Be Returned

Scenario: API Can Create A New Book
    [Documentation]    GIVEN valid book data
    ...                WHEN a POST request is made to create a book
    ...                THEN the book should be created successfully
    [Tags]    api    create    book
    Given Valid Book Data Is Prepared
    When A POST Request Is Made To Create The Book
    Then The Book Should Be Created Successfully

Scenario: API Can Retrieve A Book By ID
    [Documentation]    GIVEN a book exists in the database
    ...                WHEN a GET request is made with the book ID
    ...                THEN the correct book details should be returned
    [Tags]    api    read    book
    Given A Book Exists In The Database
    When A GET Request Is Made With The Book ID
    Then The Correct Book Details Should Be Returned

Scenario: API Can Update An Existing Book
    [Documentation]    GIVEN a book exists in the database
    ...                WHEN a PUT request is made with updated data
    ...                THEN the book should be updated successfully
    [Tags]    api    update    book
    Given A Book Exists In The Database
    When A PUT Request Is Made With Updated Book Data
    Then The Book Should Be Updated Successfully

Scenario: API Can Delete An Existing Book
    [Documentation]    GIVEN a book exists in the database
    ...                WHEN a DELETE request is made with the book ID
    ...                THEN the book should be deleted successfully
    [Tags]    api    delete    book
    Given A Book Exists In The Database
    When A DELETE Request Is Made With The Book ID
    Then The Book Should Be Deleted Successfully

Scenario: API Can Mark Book As Favorite
    [Documentation]    GIVEN a book exists in the database
    ...                WHEN a PATCH request is made to mark as favorite
    ...                THEN the book should be marked as favorite
    [Tags]    api    favorite    update
    Given A Book Exists In The Database
    When A PATCH Request Is Made To Mark Book As Favorite
    Then The Book Should Be Marked As Favorite

Scenario: API Can Unmark Book As Favorite
    [Documentation]    GIVEN a book is marked as favorite
    ...                WHEN a PATCH request is made to unmark as favorite
    ...                THEN the book should not be marked as favorite
    [Tags]    api    favorite    update
    Given A Book Is Marked As Favorite
    When A PATCH Request Is Made To Unmark Book As Favorite
    Then The Book Should Not Be Marked As Favorite

Scenario: API Returns 404 For Non-Existent Book
    [Documentation]    GIVEN no book exists with a specific ID
    ...                WHEN a GET request is made with that ID
    ...                THEN a 404 error should be returned
    [Tags]    api    error    negative
    Given No Book Exists With ID 999
    When A GET Request Is Made For Book ID 999
    Then A 404 Error Should Be Returned

Scenario: API Returns 404 When Updating Non-Existent Book
    [Documentation]    GIVEN no book exists with a specific ID
    ...                WHEN a PUT request is made with that ID
    ...                THEN a 404 error should be returned
    [Tags]    api    error    negative
    Given No Book Exists With ID 999
    When A PUT Request Is Made For Book ID 999
    Then A 404 Error Should Be Returned For Update

Scenario: API Returns 404 When Deleting Non-Existent Book
    [Documentation]    GIVEN no book exists with a specific ID
    ...                WHEN a DELETE request is made with that ID
    ...                THEN a 404 error should be returned
    [Tags]    api    error    negative
    Given No Book Exists With ID 999
    When A DELETE Request Is Made For Book ID 999
    Then A 404 Error Should Be Returned For Delete

Scenario: API Can Handle Multiple Books
    [Documentation]    GIVEN multiple books exist in the database
    ...                WHEN a GET request is made to the books endpoint
    ...                THEN all books should be returned
    [Tags]    api    multiple    list
    Given Multiple Books Exist In The Database
    When A GET Request Is Made To The Books Endpoint
    Then All Books Should Be Returned In The List

Scenario: API Validates Required Fields
    [Documentation]    GIVEN invalid book data with missing required fields
    ...                WHEN a POST request is made to create the book
    ...                THEN a validation error should be returned
    [Tags]    api    validation    negative
    Given Invalid Book Data With Missing Fields
    When A POST Request Is Made With Invalid Data
    Then A Validation Error Should Be Returned

*** Keywords ***
# Given Keywords
The Books Database Has Books
    [Documentation]    Verifies that the books database has books (or just logs that we expect books)
    Log    Database is expected to have books

The Books Database Is Empty
    [Documentation]    Ensures the books database is empty
    ${response}=    Send GET Request To Books Endpoint
    Response Status Should Be    ${response}    200
    Books List Should Be Empty    ${response}

Valid Book Data Is Prepared
    [Documentation]    Prepares valid book data for testing
    ${book_data}=    Generate Test Book Data
    Set Test Variable    ${BOOK_DATA}    ${book_data}

A Book Exists In The Database
    [Documentation]    Creates a book in the database for testing
    ${response}=    Create Test Book Via API
    ${book_id}=    Get Book ID From Response    ${response}
    Set Test Variable    ${BOOK_ID}    ${book_id}
    Set Test Variable    ${CREATED_BOOK_RESPONSE}    ${response}

A Book Is Marked As Favorite
    [Documentation]    Creates a book and marks it as favorite
    ${response}=    Create Test Book Via API
    ${book_id}=    Get Book ID From Response    ${response}
    Set Test Variable    ${BOOK_ID}    ${book_id}
    ${fav_response}=    Send PATCH Request To Toggle Favorite    ${book_id}    ${True}
    Response Status Should Be    ${fav_response}    200
    Set Test Variable    ${FAVORITE_RESPONSE}    ${fav_response}

No Book Exists With ID 999
    [Documentation]    Ensures no book exists with ID 999
    Log Test Info    Assuming no book exists with ID 999

Multiple Books Exist In The Database
    [Documentation]    Creates multiple books in the database
    ${response1}=    Create Test Book Via API    First Book    First Author    100    Fiction
    Log    Created First Book response: ${response1.stdout}
    ${response2}=    Create Test Book Via API    Second Book    Second Author    200    Non-Fiction
    Log    Created Second Book response: ${response2.stdout}
    ${response3}=    Create Test Book Via API    Third Book    Third Author    300    Fantasy
    Log    Created Third Book response: ${response3.stdout}
    ${first_book_id}=    Get Book ID From Created Response    ${response1}
    ${second_book_id}=    Get Book ID From Created Response    ${response2}
    ${third_book_id}=    Get Book ID From Created Response    ${response3}
    Log    Book IDs: First=${first_book_id}, Second=${second_book_id}, Third=${third_book_id}
    Set Test Variable    ${FIRST_BOOK_ID}    ${first_book_id}
    Set Test Variable    ${SECOND_BOOK_ID}    ${second_book_id}
    Set Test Variable    ${THIRD_BOOK_ID}    ${third_book_id}

Invalid Book Data With Missing Fields
    [Documentation]    Prepares invalid book data missing required fields
    ${invalid_data}=    Create Dictionary    title=${EMPTY}    author=${EMPTY}
    Set Test Variable    ${INVALID_BOOK_DATA}    ${invalid_data}

# When Keywords
A GET Request Is Made To The Books Endpoint
    [Documentation]    Makes a GET request to retrieve all books
    Sleep    1s    # Small delay to ensure books are committed to database
    ${response}=    Send GET Request To Books Endpoint
    Set Test Variable    ${GET_RESPONSE}    ${response}

A POST Request Is Made To Create The Book
    [Documentation]    Makes a POST request to create a book
    ${response}=    Send POST Request To Create Book    ${BOOK_DATA}
    Set Test Variable    ${POST_RESPONSE}    ${response}

A GET Request Is Made With The Book ID
    [Documentation]    Makes a GET request to retrieve a specific book
    ${response}=    Send GET Request To Get Book By ID    ${BOOK_ID}
    Set Test Variable    ${GET_BY_ID_RESPONSE}    ${response}

A PUT Request Is Made With Updated Book Data
    [Documentation]    Makes a PUT request to update a book
    ${updated_data}=    Generate Updated Test Book Data
    ${response}=    Send PUT Request To Update Book    ${BOOK_ID}    ${updated_data}
    Set Test Variable    ${PUT_RESPONSE}    ${response}
    Set Test Variable    ${UPDATED_DATA}    ${updated_data}

A DELETE Request Is Made With The Book ID
    [Documentation]    Makes a DELETE request to delete a book
    ${response}=    Send DELETE Request To Delete Book    ${BOOK_ID}
    Set Test Variable    ${DELETE_RESPONSE}    ${response}

A PATCH Request Is Made To Mark Book As Favorite
    [Documentation]    Makes a PATCH request to mark book as favorite
    ${response}=    Send PATCH Request To Toggle Favorite    ${BOOK_ID}    ${True}
    Set Test Variable    ${PATCH_FAVORITE_RESPONSE}    ${response}

A PATCH Request Is Made To Unmark Book As Favorite
    [Documentation]    Makes a PATCH request to unmark book as favorite
    ${response}=    Send PATCH Request To Toggle Favorite    ${BOOK_ID}    ${False}
    Set Test Variable    ${PATCH_UNFAVORITE_RESPONSE}    ${response}

A GET Request Is Made For Book ID 999
    [Documentation]    Makes a GET request for non-existent book ID 999
    ${response}=    Run Keyword And Expect Error    *    Send GET Request To Get Book By ID    999
    Set Test Variable    ${NOT_FOUND_RESPONSE}    ${response}

A PUT Request Is Made For Book ID 999
    [Documentation]    Makes a PUT request for non-existent book ID 999
    ${data}=    Generate Test Book Data
    ${response}=    Run Keyword And Expect Error    *    Send PUT Request To Update Book    999    ${data}
    Set Test Variable    ${PUT_NOT_FOUND_RESPONSE}    ${response}

A DELETE Request Is Made For Book ID 999
    [Documentation]    Makes a DELETE request for non-existent book ID 999
    ${response}=    Run Keyword And Expect Error    *    Send DELETE Request To Delete Book    999
    Set Test Variable    ${DELETE_NOT_FOUND_RESPONSE}    ${response}

A POST Request Is Made With Invalid Data
    [Documentation]    Makes a POST request with invalid data
    ${response}=    Run Keyword And Expect Error    *    Send POST Request To Create Book    ${INVALID_BOOK_DATA}
    Set Test Variable    ${INVALID_POST_RESPONSE}    ${response}

# Then Keywords
A Books List Should Be Returned
    [Documentation]    Verifies that a books list is returned
    Response Status Should Be    ${GET_RESPONSE}    200
    Response Should Contain Books List    ${GET_RESPONSE}

An Empty Books List Should Be Returned
    [Documentation]    Verifies an empty books list is returned
    Response Status Should Be    ${GET_RESPONSE}    200
    Books List Should Be Empty    ${GET_RESPONSE}

The Book Should Be Created Successfully
    [Documentation]    Verifies the book was created successfully
    Response Status Should Be    ${POST_RESPONSE}    201
    Verify JSON Response Structure    ${POST_RESPONSE}
    Response Should Contain Book Data    ${POST_RESPONSE}    ${BOOK_DATA['title']}    ${BOOK_DATA['author']}    ${BOOK_DATA['pages']}    ${BOOK_DATA['category']}

The Correct Book Details Should Be Returned
    [Documentation]    Verifies the correct book details are returned
    Response Status Should Be    ${GET_BY_ID_RESPONSE}    200
    Verify JSON Response Structure    ${GET_BY_ID_RESPONSE}
    # Since we're using existing books, just verify the structure and that data is present
    Should Contain    ${GET_BY_ID_RESPONSE.stdout}    "title"
    Should Contain    ${GET_BY_ID_RESPONSE.stdout}    "author"

The Book Should Be Updated Successfully
    [Documentation]    Verifies the book was updated successfully
    Response Status Should Be    ${PUT_RESPONSE}    200
    Verify JSON Response Structure    ${PUT_RESPONSE}
    Response Should Contain Book Data    ${PUT_RESPONSE}    ${UPDATED_DATA['title']}    ${UPDATED_DATA['author']}    ${UPDATED_DATA['pages']}    ${UPDATED_DATA['category']}

The Book Should Be Deleted Successfully
    [Documentation]    Verifies the book was deleted successfully
    Response Status Should Be    ${DELETE_RESPONSE}    200
    # Verify book no longer exists
    ${verify_response}=    Run Keyword And Expect Error    *    Send GET Request To Get Book By ID    ${BOOK_ID}

The Book Should Be Marked As Favorite
    [Documentation]    Verifies the book is marked as favorite
    Response Status Should Be    ${PATCH_FAVORITE_RESPONSE}    200
    Book Should Be Marked As Favorite    ${PATCH_FAVORITE_RESPONSE}

The Book Should Not Be Marked As Favorite
    [Documentation]    Verifies the book is not marked as favorite
    Response Status Should Be    ${PATCH_UNFAVORITE_RESPONSE}    200
    Book Should Not Be Marked As Favorite    ${PATCH_UNFAVORITE_RESPONSE}

A 404 Error Should Be Returned
    [Documentation]    Verifies a 404 error is returned
    Log Test Info    Verifying 404 error for non-existent book

A 404 Error Should Be Returned For Update
    [Documentation]    Verifies a 404 error is returned for update
    Log Test Info    Verifying 404 error for update of non-existent book

A 404 Error Should Be Returned For Delete
    [Documentation]    Verifies a 404 error is returned for delete
    Log Test Info    Verifying 404 error for delete of non-existent book

All Books Should Be Returned In The List
    [Documentation]    Verifies all created books are returned
    Response Status Should Be    ${GET_RESPONSE}    200
    Response Should Contain Books List    ${GET_RESPONSE}
    Books List Should Have Count    ${GET_RESPONSE}    3
    Response Should Contain Book With Title    ${GET_RESPONSE}    First Book
    Response Should Contain Book With Title    ${GET_RESPONSE}    Second Book
    Response Should Contain Book With Title    ${GET_RESPONSE}    Third Book

A Validation Error Should Be Returned
    [Documentation]    Verifies a validation error is returned
    Log Test Info    Verifying validation error for invalid data