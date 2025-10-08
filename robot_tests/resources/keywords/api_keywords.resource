*** Settings ***
Documentation    API-specific keywords for Books Database Service
Resource         ../common.resource

*** Keywords ***
Create API Session
    [Documentation]    Create session for API testing
    Create Session    books_api    ${API_URL}

Create Book Via API
    [Documentation]    Create a new book via API
    [Arguments]    ${title}    ${author}    ${pages}    ${category}    ${favorite}=False
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    ...    favorite=${favorite}
    ${response}=    POST On Session    books_api    /books    json=${book_data}
    Should Be Equal As Numbers    ${response.status_code}    201
    [Return]    ${response.json()}

Get All Books Via API
    [Documentation]    Get all books via API
    ${response}=    GET On Session    books_api    /books
    Should Be Equal As Numbers    ${response.status_code}    200
    [Return]    ${response.json()}

Get Book By ID Via API
    [Documentation]    Get a specific book by ID via API
    [Arguments]    ${book_id}
    ${response}=    GET On Session    books_api    /books/${book_id}
    Should Be Equal As Numbers    ${response.status_code}    200
    [Return]    ${response.json()}

Update Book Via API
    [Documentation]    Update a book via API
    [Arguments]    ${book_id}    ${title}    ${author}    ${pages}    ${category}    ${favorite}=False
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    ...    favorite=${favorite}
    ${response}=    PUT On Session    books_api    /books/${book_id}    json=${book_data}
    Should Be Equal As Numbers    ${response.status_code}    200
    [Return]    ${response.json()}

Delete Book Via API
    [Documentation]    Delete a book via API
    [Arguments]    ${book_id}
    ${response}=    DELETE On Session    books_api    /books/${book_id}
    Should Be Equal As Numbers    ${response.status_code}    204

Search Books Via API
    [Documentation]    Search books via API
    [Arguments]    ${search_term}
    ${response}=    GET On Session    books_api    /books    params=search=${search_term}
    Should Be Equal As Numbers    ${response.status_code}    200
    [Return]    ${response.json()}

Filter Books By Category Via API
    [Documentation]    Filter books by category via API
    [Arguments]    ${category}
    ${response}=    GET On Session    books_api    /books    params=category=${category}
    Should Be Equal As Numbers    ${response.status_code}    200
    [Return]    ${response.json()}

Verify Book Properties
    [Documentation]    Verify book has expected properties
    [Arguments]    ${book}    ${title}    ${author}    ${pages}    ${category}
    Should Be Equal    ${book}[title]    ${title}
    Should Be Equal    ${book}[author]    ${author}
    Should Be Equal As Numbers    ${book}[pages]    ${pages}
    Should Be Equal    ${book}[category]    ${category}

Verify API Error Response
    [Documentation]    Verify API returns expected error
    [Arguments]    ${response}    ${expected_status}    ${expected_message}
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    Should Contain    ${response.json()}[detail]    ${expected_message}