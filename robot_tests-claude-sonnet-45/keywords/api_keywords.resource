*** Settings ***
Documentation    API-specific keywords for Books Library REST API
Resource         ../resources/common.resource

*** Keywords ***
Given The Books API Is Available
    [Documentation]    Verify that the Books API is accessible
    Setup API Session
    ${response}=    GET On Session    books_api    /books/    expected_status=200
    Should Be Equal As Strings    ${response.status_code}    200

When I Send A GET Request To Get All Books
    [Documentation]    Send GET request to retrieve all books
    ${response}=    GET On Session    books_api    /books/
    Set Test Variable    ${API_RESPONSE}    ${response}
    RETURN    ${response}

When I Send A POST Request To Create A Book
    [Documentation]    Send POST request to create a new book
    [Arguments]    ${book_data}
    ${response}=    POST On Session    books_api    /books/    json=${book_data}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${CREATED_BOOK}    ${response.json()}
    RETURN    ${response}

When I Send A GET Request To Get Book By ID
    [Documentation]    Send GET request to retrieve a specific book by ID
    [Arguments]    ${book_id}
    ${response}=    GET On Session    books_api    /books/${book_id}
    Set Test Variable    ${API_RESPONSE}    ${response}
    RETURN    ${response}

When I Send A PUT Request To Update A Book
    [Documentation]    Send PUT request to update an existing book
    [Arguments]    ${book_id}    ${book_data}
    ${response}=    PUT On Session    books_api    /books/${book_id}    json=${book_data}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${UPDATED_BOOK}    ${response.json()}
    RETURN    ${response}

When I Send A DELETE Request To Delete A Book
    [Documentation]    Send DELETE request to delete a book
    [Arguments]    ${book_id}
    ${response}=    DELETE On Session    books_api    /books/${book_id}
    Set Test Variable    ${API_RESPONSE}    ${response}
    RETURN    ${response}

When I Send A PATCH Request To Toggle Book Favorite
    [Documentation]    Send PATCH request to toggle book favorite status
    [Arguments]    ${book_id}    ${favorite_status}
    ${favorite_data}=    Create Dictionary    favorite=${favorite_status}
    ${response}=    PATCH On Session    books_api    /books/${book_id}/favorite    json=${favorite_data}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${UPDATED_BOOK}    ${response.json()}
    RETURN    ${response}

Then The Response Status Should Be
    [Documentation]    Verify the HTTP response status code
    [Arguments]    ${expected_status}
    Should Be Equal As Strings    ${API_RESPONSE.status_code}    ${expected_status}

Then The Response Should Contain Book Data
    [Documentation]    Verify that the response contains expected book data
    [Arguments]    ${expected_title}    ${expected_author}    ${expected_pages}    ${expected_category}=Fiction
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Strings    ${response_data}[title]    ${expected_title}
    Should Be Equal As Strings    ${response_data}[author]    ${expected_author}
    Should Be Equal As Integers    ${response_data}[pages]    ${expected_pages}
    Should Be Equal As Strings    ${response_data}[category]    ${expected_category}
    Should Not Be Empty    ${response_data}[id]

Then The Response Should Contain A List Of Books
    [Documentation]    Verify that the response contains a list of books
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Be True    isinstance($response_data, list)
    Set Test Variable    ${BOOKS_LIST_RESPONSE}    ${response_data}

Then The Books List Should Contain
    [Documentation]    Verify that the books list contains a specific number of books
    [Arguments]    ${expected_count}
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    ${actual_count}=    Get Length    ${response_data}
    Should Be Equal As Integers    ${actual_count}    ${expected_count}

Then The Response Should Contain Error Message
    [Documentation]    Verify that the response contains an error message
    [Arguments]    ${expected_message}
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Strings    ${response_data}[detail]    ${expected_message}

Then The Response Should Contain Success Message
    [Documentation]    Verify that the response contains a success message
    [Arguments]    ${expected_message}
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Strings    ${response_data}[message]    ${expected_message}

Then The Book Should Have Favorite Status
    [Documentation]    Verify that the book has the expected favorite status
    [Arguments]    ${expected_status}
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal    ${response_data}[favorite]    ${expected_status}

Given I Have A Book In The Database
    [Documentation]    Create a book in the database for testing
    [Arguments]    ${title}=Test Book    ${author}=Test Author    ${pages}=200    ${category}=Fiction
    ${book_data}=    Create Dictionary    title=${title}    author=${author}    pages=${pages}    category=${category}    favorite=${False}
    ${response}=    When I Send A POST Request To Create A Book    ${book_data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${created_book}=    Set Variable    ${response.json()}
    Set Test Variable    ${TEST_BOOK_ID}    ${created_book}[id]
    Set Test Variable    ${TEST_BOOK_DATA}    ${created_book}
    RETURN    ${created_book}

Given I Have Multiple Books In The Database
    [Documentation]    Create multiple books in the database for testing
    [Arguments]    ${count}=5
    ${created_books}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${book_data}=    Generate Random Book Data    Test${i}
        ${response}=    When I Send A POST Request To Create A Book    ${book_data}
        Should Be Equal As Strings    ${response.status_code}    200
        ${created_book}=    Set Variable    ${response.json()}
        Append To List    ${created_books}    ${created_book}
    END
    Set Test Variable    ${TEST_BOOKS}    ${created_books}
    RETURN    ${created_books}

Verify Book Data Matches
    [Documentation]    Verify that book data matches expected values
    [Arguments]    ${actual_book}    ${expected_book}
    Should Be Equal As Strings    ${actual_book}[title]    ${expected_book}[title]
    Should Be Equal As Strings    ${actual_book}[author]    ${expected_book}[author]
    Should Be Equal As Integers    ${actual_book}[pages]    ${expected_book}[pages]
    Should Be Equal As Strings    ${actual_book}[category]    ${expected_book}[category]
    Should Be Equal    ${actual_book}[favorite]    ${expected_book}[favorite]

Verify Response Headers
    [Documentation]    Verify that response headers contain expected values
    [Arguments]    ${header_name}    ${expected_value}
    ${headers}=    Set Variable    ${API_RESPONSE.headers}
    Should Be Equal As Strings    ${headers}[${header_name}]    ${expected_value}

Verify Response Time
    [Documentation]    Verify that the response time is within acceptable limits
    [Arguments]    ${max_response_time}=2.0
    ${response_time}=    Set Variable    ${API_RESPONSE.elapsed.total_seconds()}
    Should Be True    ${response_time} < ${max_response_time}    Response time ${response_time}s exceeds maximum ${max_response_time}s

Create Book With Invalid Data
    [Documentation]    Attempt to create a book with invalid data
    [Arguments]    ${invalid_data}
    ${response}=    POST On Session    books_api    /books/    json=${invalid_data}    expected_status=any
    Set Test Variable    ${API_RESPONSE}    ${response}
    RETURN    ${response}

Verify Validation Error Response
    [Documentation]    Verify that the response contains validation errors
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${response_data}    detail
    Should Be True    isinstance($response_data['detail'], list)

Clean Up Test Books
    [Documentation]    Clean up books created during testing
    TRY
        ${response}=    GET On Session    books_api    /books/
        ${books}=    Set Variable    ${response.json()}
        FOR    ${book}    IN    @{books}
            ${title}=    Set Variable    ${book}[title]
            IF    'Test' in '${title}'
                DELETE On Session    books_api    /books/${book}[id]    expected_status=any
            END
        END
    EXCEPT
        Log    Failed to clean up test books, continuing...
    END