*** Settings ***
Documentation    API keywords for Books Database Service
Resource         common.resource

*** Keywords ***
Create Session For API
    [Documentation]    Create HTTP session for API testing
    Create Session    books_api    ${BASE_URL}    verify=False

Get All Books Via API
    [Documentation]    Get all books from API
    ${response}=    GET On Session    books_api    /api/books
    RETURN    ${response}

Create Book Via API
    [Documentation]    Create a new book via API
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    ${book_data}=    Create Dictionary    title=${title}    author=${author}    pages=${pages}    category=${category}
    ${response}=    POST On Session    books_api    /api/books    json=${book_data}
    RETURN    ${response}

Get Book By ID Via API
    [Documentation]    Get a specific book by ID via API
    [Arguments]    ${book_id}
    ${response}=    GET On Session    books_api    /api/books/${book_id}    expected_status=any
    RETURN    ${response}

Update Book Via API
    [Documentation]    Update a book via API
    [Arguments]    ${book_id}    ${title}    ${author}    ${pages}    ${category}
    ${book_data}=    Create Dictionary    title=${title}    author=${author}    pages=${pages}    category=${category}
    ${response}=    PUT On Session    books_api    /api/books/${book_id}    json=${book_data}    expected_status=any
    RETURN    ${response}

Delete Book Via API
    [Documentation]    Delete a book via API
    [Arguments]    ${book_id}
    ${response}=    DELETE On Session    books_api    /api/books/${book_id}    expected_status=any
    RETURN    ${response}

Toggle Book Favorite Via API
    [Documentation]    Toggle book favorite status via API
    [Arguments]    ${book_id}    ${favorite_status}
    ${favorite_data}=    Create Dictionary    favorite=${favorite_status}
    ${response}=    PATCH On Session    books_api    /api/books/${book_id}/favorite    json=${favorite_data}    expected_status=any
    RETURN    ${response}

Verify Response Status Code
    [Documentation]    Verify API response status code
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}

Verify Book Data In Response
    [Documentation]    Verify book data in API response
    [Arguments]    ${response}    ${expected_title}    ${expected_author}    ${expected_pages}    ${expected_category}
    ${json_data}=    Set Variable    ${response.json()}
    Should Be Equal    ${json_data}[title]    ${expected_title}
    Should Be Equal    ${json_data}[author]    ${expected_author}
    Should Be Equal As Numbers    ${json_data}[pages]    ${expected_pages}
    Should Be Equal    ${json_data}[category]    ${expected_category}

Verify Books List Contains Book
    [Documentation]    Verify that books list contains specific book
    [Arguments]    ${response}    ${expected_title}
    ${books_list}=    Set Variable    ${response.json()}
    ${found}=    Set Variable    False
    FOR    ${book}    IN    @{books_list}
        IF    '${book}[title]' == '${expected_title}'
            ${found}=    Set Variable    True
            BREAK
        END
    END
    Should Be True    ${found}    Book with title '${expected_title}' not found in books list