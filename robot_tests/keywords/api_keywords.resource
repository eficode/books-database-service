*** Settings ***
Documentation    API-specific keywords for Books Library application
Resource         ../resources/common.resource

*** Keywords ***
# Basic CRUD Operations
Create Book Via API
    [Documentation]    Create a book using the REST API
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction    ${favorite}=${False}
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    ...    favorite=${favorite}
    
    ${response}=    POST On Session    books_api    /books    json=${book_data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${book}=    Set Variable    ${response.json()}
    RETURN    ${book}

Get All Books Via API
    [Documentation]    Retrieve all books using the REST API
    ${response}=    GET On Session    books_api    /books
    Should Be Equal As Strings    ${response.status_code}    200
    ${books}=    Set Variable    ${response.json()}
    RETURN    ${books}

Get Book By ID Via API
    [Documentation]    Retrieve a specific book by ID using the REST API
    [Arguments]    ${book_id}
    ${response}=    GET On Session    books_api    /books/${book_id}
    Should Be Equal As Strings    ${response.status_code}    200
    ${book}=    Set Variable    ${response.json()}
    RETURN    ${book}

Update Book Via API
    [Documentation]    Update a book using the REST API
    [Arguments]    ${book_id}    ${title}    ${author}    ${pages}    ${category}=Fiction    ${favorite}=${False}
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    ...    favorite=${favorite}
    
    ${response}=    PUT On Session    books_api    /books/${book_id}    json=${book_data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${book}=    Set Variable    ${response.json()}
    RETURN    ${book}

Delete Book Via API
    [Documentation]    Delete a book using the REST API
    [Arguments]    ${book_id}
    ${response}=    DELETE On Session    books_api    /books/${book_id}
    Should Be Equal As Strings    ${response.status_code}    200
    ${result}=    Set Variable    ${response.json()}
    RETURN    ${result}

Toggle Book Favorite Via API
    [Documentation]    Toggle book favorite status using the REST API
    [Arguments]    ${book_id}    ${favorite_status}
    ${favorite_data}=    Create Dictionary    favorite=${favorite_status}
    ${response}=    PATCH On Session    books_api    /books/${book_id}/favorite    json=${favorite_data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${book}=    Set Variable    ${response.json()}
    RETURN    ${book}

# Error Handling Operations
Attempt To Get Non-Existent Book
    [Documentation]    Attempt to get a book that doesn't exist
    [Arguments]    ${book_id}=99999
    ${response}=    GET On Session    books_api    /books/${book_id}    expected_status=404
    RETURN    ${response}

Attempt To Update Non-Existent Book
    [Documentation]    Attempt to update a book that doesn't exist
    [Arguments]    ${book_id}=99999
    ${book_data}=    Create Dictionary    title=Test    author=Test    pages=100    category=Fiction
    ${response}=    PUT On Session    books_api    /books/${book_id}    json=${book_data}    expected_status=404
    RETURN    ${response}

Attempt To Delete Non-Existent Book
    [Documentation]    Attempt to delete a book that doesn't exist
    [Arguments]    ${book_id}=99999
    ${response}=    DELETE On Session    books_api    /books/${book_id}    expected_status=404
    RETURN    ${response}

Attempt To Toggle Favorite For Non-Existent Book
    [Documentation]    Attempt to toggle favorite for a book that doesn't exist
    [Arguments]    ${book_id}=99999
    ${favorite_data}=    Create Dictionary    favorite=True
    ${response}=    PATCH On Session    books_api    /books/${book_id}/favorite    json=${favorite_data}    expected_status=404
    RETURN    ${response}

# Validation Testing
Attempt To Create Book Without Required Field
    [Documentation]    Attempt to create a book missing a required field
    [Arguments]    ${missing_field}
    ${book_data}=    Create Dictionary    title=Test Title    author=Test Author    pages=100    category=Fiction
    Remove From Dictionary    ${book_data}    ${missing_field}
    ${response}=    POST On Session    books_api    /books    json=${book_data}    expected_status=422
    RETURN    ${response}

Attempt To Create Book With Invalid Data
    [Documentation]    Attempt to create a book with invalid data
    [Arguments]    ${field}    ${invalid_value}
    ${book_data}=    Create Dictionary    title=Test Title    author=Test Author    pages=100    category=Fiction
    Set To Dictionary    ${book_data}    ${field}    ${invalid_value}
    ${response}=    POST On Session    books_api    /books    json=${book_data}    expected_status=any
    RETURN    ${response}

Attempt To Update Book Without Required Field
    [Documentation]    Attempt to update a book missing a required field
    [Arguments]    ${book_id}    ${missing_field}
    ${book_data}=    Create Dictionary    title=Updated Title    author=Updated Author    pages=200    category=Fiction
    Remove From Dictionary    ${book_data}    ${missing_field}
    ${response}=    PUT On Session    books_api    /books/${book_id}    json=${book_data}    expected_status=422
    RETURN    ${response}

# Data Verification
Verify Book Data Matches Expected
    [Documentation]    Verify book data matches expected values
    [Arguments]    ${book}    ${expected_title}    ${expected_author}    ${expected_pages}    ${expected_category}    ${expected_favorite}=${False}
    Should Be Equal As Strings    ${book}[title]    ${expected_title}
    Should Be Equal As Strings    ${book}[author]    ${expected_author}
    Should Be Equal As Numbers    ${book}[pages]    ${expected_pages}
    Should Be Equal As Strings    ${book}[category]    ${expected_category}
    Should Be Equal    ${book}[favorite]    ${expected_favorite}

Verify Response Contains Error
    [Documentation]    Verify that response contains error information
    [Arguments]    ${response}
    ${error_data}=    Set Variable    ${response.json()}
    Should Contain    ${error_data}    detail

Verify Response Status Code
    [Documentation]    Verify response has expected status code
    [Arguments]    ${response}    ${expected_status}
    ${status_code}=    Convert To String    ${response.status_code}
    ${expected_code}=    Convert To String    ${expected_status}
    Should Be Equal As Strings    ${status_code}    ${expected_code}

# Bulk Operations
Create Multiple Books Via API
    [Documentation]    Create multiple books via API for testing
    [Arguments]    ${count}=5
    ${books}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${book_data}=    Generate Random Book Data
        ${book}=    Create Book Via API    ${book_data}[title]    ${book_data}[author]    ${book_data}[pages]    ${book_data}[category]
        Append To List    ${books}    ${book}
    END
    RETURN    ${books}

Create Books With Specific Data Via API
    [Documentation]    Create books with specific data sets
    [Arguments]    @{book_data_list}
    ${books}=    Create List
    FOR    ${book_data}    IN    @{book_data_list}
        ${book}=    Create Book Via API    ${book_data}[title]    ${book_data}[author]    ${book_data}[pages]    ${book_data}[category]
        Append To List    ${books}    ${book}
    END
    RETURN    ${books}

Verify All Books Exist In Database
    [Documentation]    Verify that all provided books exist in the database
    [Arguments]    ${expected_books}
    ${all_books}=    Get All Books Via API
    ${all_books_count}=    Get Length    ${all_books}
    ${expected_count}=    Get Length    ${expected_books}
    Should Be Equal As Numbers    ${all_books_count}    ${expected_count}
    
    FOR    ${expected_book}    IN    @{expected_books}
        ${found}=    Set Variable    ${False}
        FOR    ${book}    IN    @{all_books}
            IF    ${book}[id] == ${expected_book}[id]
                ${found}=    Set Variable    ${True}
                Verify Book Data Matches Expected    ${book}    ${expected_book}[title]    ${expected_book}[author]    ${expected_book}[pages]    ${expected_book}[category]
                BREAK
            END
        END
        Should Be True    ${found}    Book with ID ${expected_book}[id] not found in database
    END

# Data Consistency Testing
Perform Multiple Operations On Same Book
    [Documentation]    Perform multiple operations on the same book to test consistency
    [Arguments]    ${book_id}
    # Update the book
    ${updated_book}=    Update Book Via API    ${book_id}    Updated Title    Updated Author    300    Fantasy    ${False}
    
    # Toggle favorite status
    ${favorite_book}=    Toggle Book Favorite Via API    ${book_id}    ${True}
    
    # Update again with favorite preserved
    ${final_book}=    Update Book Via API    ${book_id}    Final Title    Final Author    400    Science Fiction    ${True}
    
    RETURN    ${final_book}

Verify Data Consistency After Operations
    [Documentation]    Verify data consistency after multiple operations
    [Arguments]    ${book_id}    ${expected_title}    ${expected_author}    ${expected_pages}    ${expected_category}    ${expected_favorite}
    ${retrieved_book}=    Get Book By ID Via API    ${book_id}
    Verify Book Data Matches Expected    ${retrieved_book}    ${expected_title}    ${expected_author}    ${expected_pages}    ${expected_category}    ${expected_favorite}

# Concurrent Testing Helpers
Simulate Concurrent Book Creation
    [Documentation]    Simulate concurrent book creation
    [Arguments]    ${count}=10
    ${books}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${book_data}=    Generate Random Book Data
        ${book}=    Create Book Via API    Concurrent Book ${i}    ${book_data}[author]    ${book_data}[pages]    ${book_data}[category]
        Append To List    ${books}    ${book}
    END
    RETURN    ${books}

Verify No Data Corruption Occurred
    [Documentation]    Verify that no data corruption occurred during concurrent operations
    [Arguments]    ${expected_books}
    FOR    ${expected_book}    IN    @{expected_books}
        ${retrieved_book}=    Get Book By ID Via API    ${expected_book}[id]
        Should Be Equal As Strings    ${retrieved_book}[title]    ${expected_book}[title]
        Should Be Equal As Strings    ${retrieved_book}[author]    ${expected_book}[author]
        Should Be Equal As Numbers    ${retrieved_book}[pages]    ${expected_book}[pages]
        Should Be Equal As Strings    ${retrieved_book}[category]    ${expected_book}[category]
    END