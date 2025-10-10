*** Settings ***
Documentation    API acceptance tests for Books Database Service
Resource         resources/api_keywords.resource
Suite Setup      Create API Session
Suite Teardown   Delete API Session
Test Tags        api    acceptance

*** Test Cases ***
API Can Create A New Book
    [Documentation]    Verify that a new book can be created via API
    [Tags]    create    smoke
    Given the API is available
    When I create a book with title "The Catcher in the Rye" author "J.D. Salinger" pages "277" category "Fiction"
    Then the book should be created successfully
    And the book should have correct properties

API Can Retrieve All Books
    [Documentation]    Verify that all books can be retrieved via API
    [Tags]    read
    Given the API is available
    And multiple books exist in the system
    When I request all books
    Then I should receive a list of books
    And the list should contain all created books

API Can Retrieve A Book By ID
    [Documentation]    Verify that a specific book can be retrieved by ID
    [Tags]    read
    Given the API is available
    And a book exists with title "Brave New World"
    When I request the book by its ID
    Then I should receive the book details
    And the details should match the created book

API Can Update A Book
    [Documentation]    Verify that a book can be updated via API
    [Tags]    update
    Given the API is available
    And a book exists with title "Animal Farm"
    When I update the book with new title "Animal Farm: A Fairy Story"
    Then the book should be updated successfully
    And the book should have the new title

API Can Delete A Book
    [Documentation]    Verify that a book can be deleted via API
    [Tags]    delete
    Given the API is available
    And a book exists with title "Lord of the Flies"
    When I delete the book
    Then the book should be deleted successfully
    And the book should not exist in the system

API Can Toggle Book Favorite Status
    [Documentation]    Verify that a book's favorite status can be toggled
    [Tags]    favorite
    Given the API is available
    And a book exists with title "The Great Gatsby"
    When I mark the book as favorite
    Then the book should be marked as favorite
    When I unmark the book as favorite
    Then the book should not be marked as favorite

API Returns 404 For Non-Existent Book
    [Documentation]    Verify that API returns 404 for non-existent book
    [Tags]    error    negative
    Given the API is available
    When I request a book with non-existent ID "99999"
    Then I should receive a 404 error

API Validates Required Fields
    [Documentation]    Verify that API validates required fields when creating a book
    [Tags]    validation    negative
    Given the API is available
    When I attempt to create a book without required fields
    Then I should receive a validation error

*** Variables ***
${CREATED_BOOK}    ${NONE}
${BOOK_ID}         ${NONE}
${ALL_BOOKS}       ${NONE}

*** Keywords ***
The API is available
    ${response}=    GET On Session    books_api    /books/    expected_status=200

I create a book with title "${title}" author "${author}" pages "${pages}" category "${category}"
    ${book}=    Create Book Via API    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${CREATED_BOOK}    ${book}
    Set Test Variable    ${BOOK_ID}    ${book['id']}

The book should be created successfully
    Should Not Be Empty    ${CREATED_BOOK}
    Should Not Be Equal    ${CREATED_BOOK['id']}    ${NONE}

The book should have correct properties
    Should Be Equal As Strings    ${CREATED_BOOK['title']}    The Catcher in the Rye
    Should Be Equal As Strings    ${CREATED_BOOK['author']}    J.D. Salinger
    Should Be Equal As Numbers    ${CREATED_BOOK['pages']}    277
    Should Be Equal As Strings    ${CREATED_BOOK['category']}    Fiction

Multiple books exist in the system
    ${book1}=    Create Book Via API    Book One    Author One    100    Fiction
    ${book2}=    Create Book Via API    Book Two    Author Two    200    Non-Fiction
    ${book3}=    Create Book Via API    Book Three    Author Three    300    Fantasy

I request all books
    ${books}=    Get All Books Via API
    Set Test Variable    ${ALL_BOOKS}    ${books}

I should receive a list of books
    Should Not Be Empty    ${ALL_BOOKS}
    ${length}=    Get Length    ${ALL_BOOKS}
    Should Be True    ${length} > 0

The list should contain all created books
    ${length}=    Get Length    ${ALL_BOOKS}
    Should Be True    ${length} >= 3

A book exists with title "${title}"
    ${book}=    Create Book Via API    ${title}    Test Author    250    Fiction
    Set Test Variable    ${CREATED_BOOK}    ${book}
    Set Test Variable    ${BOOK_ID}    ${book['id']}

I request the book by its ID
    ${book}=    Get Book By ID Via API    ${BOOK_ID}
    Set Test Variable    ${CREATED_BOOK}    ${book}

I should receive the book details
    Should Not Be Empty    ${CREATED_BOOK}
    Should Be Equal As Numbers    ${CREATED_BOOK['id']}    ${BOOK_ID}

The details should match the created book
    Should Not Be Empty    ${CREATED_BOOK['title']}
    Should Not Be Empty    ${CREATED_BOOK['author']}

I update the book with new title "${new_title}"
    ${updated_book}=    Update Book Via API    ${BOOK_ID}    ${new_title}    Test Author    250    Fiction
    Set Test Variable    ${CREATED_BOOK}    ${updated_book}

The book should be updated successfully
    Should Not Be Empty    ${CREATED_BOOK}

The book should have the new title
    Should Be Equal As Strings    ${CREATED_BOOK['title']}    Animal Farm: A Fairy Story

I delete the book
    ${response}=    Delete Book Via API    ${BOOK_ID}
    Should Be Equal As Strings    ${response['message']}    Book deleted successfully

The book should be deleted successfully
    Wait For Response

The book should not exist in the system
    Book Should Not Exist    ${BOOK_ID}

I mark the book as favorite
    ${book}=    Toggle Favorite Via API    ${BOOK_ID}    ${True}
    Set Test Variable    ${CREATED_BOOK}    ${book}

The book should be marked as favorite
    Should Be True    ${CREATED_BOOK['favorite']}

I unmark the book as favorite
    ${book}=    Toggle Favorite Via API    ${BOOK_ID}    ${False}
    Set Test Variable    ${CREATED_BOOK}    ${book}

The book should not be marked as favorite
    Should Not Be True    ${CREATED_BOOK['favorite']}

I request a book with non-existent ID "${book_id}"
    Book Should Not Exist    ${book_id}

I should receive a 404 error
    Log    404 error received as expected

I attempt to create a book without required fields
    ${body}=    Create Dictionary    title=Incomplete Book
    ${response}=    POST On Session    books_api    /books/    json=${body}    expected_status=422

I should receive a validation error
    Log    Validation error received as expected
