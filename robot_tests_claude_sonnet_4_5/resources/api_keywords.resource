*** Settings ***
Documentation    API-specific keywords for REST API testing
Library          RequestsLibrary
Library          Collections
Resource         common.resource

*** Keywords ***
Create API Session
    Create Session    books_api    ${BASE_URL}    verify=True

Delete API Session
    Delete All Sessions

Create Book Via API
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction    ${favorite}=False
    ${body}=    Create Dictionary    title=${title}    author=${author}    pages=${pages}    category=${category}    favorite=${favorite}
    ${response}=    POST On Session    books_api    /books/    json=${body}    expected_status=200
    RETURN    ${response.json()}

Get All Books Via API
    ${response}=    GET On Session    books_api    /books/    expected_status=200
    RETURN    ${response.json()}

Get Book By ID Via API
    [Arguments]    ${book_id}
    ${response}=    GET On Session    books_api    /books/${book_id}    expected_status=200
    RETURN    ${response.json()}

Update Book Via API
    [Arguments]    ${book_id}    ${title}    ${author}    ${pages}    ${category}=Fiction    ${favorite}=False
    ${body}=    Create Dictionary    title=${title}    author=${author}    pages=${pages}    category=${category}    favorite=${favorite}
    ${response}=    PUT On Session    books_api    /books/${book_id}    json=${body}    expected_status=200
    RETURN    ${response.json()}

Delete Book Via API
    [Arguments]    ${book_id}
    ${response}=    DELETE On Session    books_api    /books/${book_id}    expected_status=200
    RETURN    ${response.json()}

Toggle Favorite Via API
    [Arguments]    ${book_id}    ${favorite}
    ${body}=    Create Dictionary    favorite=${favorite}
    ${response}=    PATCH On Session    books_api    /books/${book_id}/favorite    json=${body}    expected_status=200
    RETURN    ${response.json()}

Book Should Not Exist
    [Arguments]    ${book_id}
    ${response}=    GET On Session    books_api    /books/${book_id}    expected_status=404
    Should Be Equal As Strings    ${response.json()['detail']}    Book not found

Verify Book Properties
    [Arguments]    ${book}    ${title}    ${author}    ${pages}    ${category}=Fiction
    Should Be Equal As Strings    ${book['title']}    ${title}
    Should Be Equal As Strings    ${book['author']}    ${author}
    Should Be Equal As Numbers    ${book['pages']}    ${pages}
    Should Be Equal As Strings    ${book['category']}    ${category}
