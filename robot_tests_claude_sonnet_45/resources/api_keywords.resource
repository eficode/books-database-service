*** Settings ***
Documentation    API Keywords for RESTful API testing with RequestsLibrary
Library          RequestsLibrary
Library          Collections
Library          String
Resource         common.resource


*** Variables ***
${API_ENDPOINT}    ${API_URL}


*** Keywords ***
API Get All Books
    [Documentation]    Get all books from the API
    ${response}=    GET    ${API_ENDPOINT}    expected_status=200
    Status Should Be    200    ${response}
    RETURN    ${response.json()}

API Get Book By ID
    [Documentation]    Get a specific book by ID
    [Arguments]    ${book_id}
    ${response}=    GET    ${API_ENDPOINT}/${book_id}    expected_status=any
    RETURN    ${response}

API Create Book
    [Documentation]    Create a new book via API
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction    ${favorite}=False
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    ...    favorite=${favorite}
    ${response}=    POST    ${API_ENDPOINT}    json=${book_data}    expected_status=any
    RETURN    ${response}

API Update Book
    [Documentation]    Update an existing book via API
    [Arguments]    ${book_id}    ${title}    ${author}    ${pages}    ${category}=Fiction    ${favorite}=False
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    ...    favorite=${favorite}
    ${response}=    PUT    ${API_ENDPOINT}/${book_id}    json=${book_data}    expected_status=any
    RETURN    ${response}

API Delete Book
    [Documentation]    Delete a book via API
    [Arguments]    ${book_id}
    ${response}=    DELETE    ${API_ENDPOINT}/${book_id}    expected_status=any
    RETURN    ${response}

API Toggle Book Favorite
    [Documentation]    Toggle favorite status of a book via API
    [Arguments]    ${book_id}    ${favorite}
    ${favorite_data}=    Create Dictionary    favorite=${favorite}
    ${response}=    PATCH    ${API_ENDPOINT}/${book_id}/favorite    json=${favorite_data}    expected_status=any
    RETURN    ${response}

API Response Should Be Successful
    [Documentation]    Verify that API response status is in the 200 range
    [Arguments]    ${response}
    Should Be True    200 <= ${response.status_code} < 300
    ...    msg=Expected successful status code, got ${response.status_code}: ${response.text}

API Response Should Have Status
    [Documentation]    Verify that API response has expected status code
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    ...    msg=Expected status ${expected_status}, got ${response.status_code}: ${response.text}

API Response Should Contain Book Data
    [Documentation]    Verify that response contains expected book data
    [Arguments]    ${response}    ${title}    ${author}    ${pages}    ${category}
    ${book}=    Set Variable    ${response.json()}
    Should Be Equal    ${book}[title]    ${title}
    Should Be Equal    ${book}[author]    ${author}
    Should Be Equal As Numbers    ${book}[pages]    ${pages}
    Should Be Equal    ${book}[category]    ${category}

API Response Should Contain Book Field
    [Documentation]    Verify that response contains a specific field with expected value
    [Arguments]    ${response}    ${field}    ${expected_value}
    ${book}=    Set Variable    ${response.json()}
    Should Be Equal    ${book}[${field}]    ${expected_value}

API Response Should Have Error Message
    [Documentation]    Verify that error response contains expected message
    [Arguments]    ${response}    ${expected_message}
    ${error}=    Set Variable    ${response.json()}
    Should Contain    ${error}[detail]    ${expected_message}

Book Should Exist In Database
    [Documentation]    Verify that a book exists in the database via API
    [Arguments]    ${book_id}
    ${response}=    API Get Book By ID    ${book_id}
    API Response Should Have Status    ${response}    200
    RETURN    ${response.json()}

Book Should Not Exist In Database
    [Documentation]    Verify that a book does not exist in the database via API
    [Arguments]    ${book_id}
    ${response}=    API Get Book By ID    ${book_id}
    API Response Should Have Status    ${response}    404

Books List Should Contain Book
    [Documentation]    Verify that the books list contains a book with specific properties
    [Arguments]    ${books_list}    ${title}
    ${found}=    Set Variable    ${False}
    FOR    ${book}    IN    @{books_list}
        ${found}=    Run Keyword And Return Status    Should Be Equal    ${book}[title]    ${title}
        IF    ${found}    BREAK
    END
    Should Be True    ${found}    msg=Book with title "${title}" not found in the list

Books List Should Not Contain Book
    [Documentation]    Verify that the books list does not contain a book with specific title
    [Arguments]    ${books_list}    ${title}
    FOR    ${book}    IN    @{books_list}
        Should Not Be Equal    ${book}[title]    ${title}
    END

Books List Should Have Length
    [Documentation]    Verify the number of books in the list
    [Arguments]    ${books_list}    ${expected_length}
    ${actual_length}=    Get Length    ${books_list}
    Should Be Equal As Numbers    ${actual_length}    ${expected_length}

Get Book From Response
    [Documentation]    Extract book data from API response
    [Arguments]    ${response}
    API Response Should Be Successful    ${response}
    ${book}=    Set Variable    ${response.json()}
    RETURN    ${book}

Get Book ID From Response
    [Documentation]    Extract book ID from API response
    [Arguments]    ${response}
    ${book}=    Get Book From Response    ${response}
    RETURN    ${book}[id]

Verify Book Has All Required Fields
    [Documentation]    Verify that a book object has all required fields
    [Arguments]    ${book}
    Should Not Be Empty    ${book}[id]
    Should Not Be Empty    ${book}[title]
    Should Not Be Empty    ${book}[author]
    Should Not Be Empty    ${book}[pages]
    Should Not Be Empty    ${book}[category]
    Dictionary Should Contain Key    ${book}    favorite

Create Multiple Books Via API
    [Documentation]    Create multiple books and return their IDs
    [Arguments]    ${count}
    ${book_ids}=    Create List
    FOR    ${index}    IN RANGE    ${count}
        ${book_data}=    Generate Random Book Data
        ${response}=    API Create Book    
        ...    ${book_data}[title]
        ...    ${book_data}[author]
        ...    ${book_data}[pages]
        ...    ${book_data}[category]
        API Response Should Be Successful    ${response}
        ${book_id}=    Get Book ID From Response    ${response}
        Append To List    ${book_ids}    ${book_id}
    END
    RETURN    ${book_ids}

Delete Multiple Books Via API
    [Documentation]    Delete multiple books by their IDs
    [Arguments]    @{book_ids}
    FOR    ${book_id}    IN    @{book_ids}
        ${response}=    API Delete Book    ${book_id}
        # Ignore if book already deleted (404)
        Run Keyword If    ${response.status_code} != 404
        ...    API Response Should Be Successful    ${response}
    END

Verify Books Are Sorted By Field
    [Documentation]    Verify that books list is sorted by specified field
    [Arguments]    ${books_list}    ${field}    ${ascending}=True
    ${values}=    Create List
    FOR    ${book}    IN    @{books_list}
        Append To List    ${values}    ${book}[${field}]
    END
    ${sorted_values}=    Copy List    ${values}
    ${sorted_values}=    Evaluate    sorted(${sorted_values}, reverse=${not ${ascending}})
    Lists Should Be Equal    ${values}    ${sorted_values}
    ...    msg=Books are not sorted by ${field} in ${'ascending' if ${ascending} else 'descending'} order
