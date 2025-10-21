*** Settings ***
Documentation    API acceptance tests for Books Database Service.
...              Tests cover CRUD operations and error handling.
Resource         resources/api_keywords.resource
Suite Setup      Create API Session
Suite Teardown   Delete API Session
Test Tags        api    acceptance

*** Variables ***
${CREATED_BOOK}    ${NONE}
${BOOK_ID}         ${NONE}
${ALL_BOOKS}       ${NONE}

*** Test Cases ***
API can create a new book
    [Documentation]    Verify that a new book can be created via API
    [Tags]    create    smoke
    Given the API is available
    When book is created with title "The Catcher in the Rye" author "J.D. Salinger"
    ...      pages "277" category "Fiction"
    Then the book should be created successfully
    And the book should have correct properties

API can retrieve all books
    [Documentation]    Verify that all books can be retrieved via API
    [Tags]    read
    Given the API is available
    And multiple books exist in the system
    When all books are requested
    Then a list of books should be received
    And the list should contain all created books

API can retrieve a book by ID
    [Documentation]    Verify that a specific book can be retrieved by ID
    [Tags]    read
    Given the API is available
    And a book exists with title "Brave New World"
    When the book is requested by its ID
    Then the book details should be received
    And the details should match the created book

API can update a book
    [Documentation]    Verify that a book can be updated via API
    [Tags]    update
    Given the API is available
    And a book exists with title "Animal Farm"
    When the book is updated with new title "Animal Farm: A Fairy Story"
    Then the book should be updated successfully
    And the book should have the new title

API can delete a book
    [Documentation]    Verify that a book can be deleted via API
    [Tags]    delete
    Given the API is available
    And a book exists with title "Lord of the Flies"
    When the book is deleted
    Then the book should be deleted successfully
    And the book should not exist in the system

API can toggle book favorite status
    [Documentation]    Verify that a book's favorite status can be toggled
    [Tags]    favorite
    Given the API is available
    And a book exists with title "The Great Gatsby"
    When the book is marked as favorite
    Then the book should be marked as favorite
    When the book is unmarked as favorite
    Then the book should not be marked as favorite

API returns 404 for non-existent book
    [Documentation]    Verify that API returns 404 for non-existent book
    [Tags]    error    negative
    Given the API is available
    When a book with non-existent ID "99999" is requested
    Then a 404 error should be received

API validates required fields
    [Documentation]    Verify that API validates required fields when creating a book
    [Tags]    validation    negative
    Given the API is available
    When book creation is attempted without required fields
    Then a validation error should be received

*** Keywords ***
The API Is Available
    ${response}=    GET On Session    books_api    /books/    expected_status=200

Book Is Created With Title "${title}" Author "${author}" Pages "${pages}" Category "${category}"
    ${book}=    Create Book Via API    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${CREATED_BOOK}    ${book}
    Set Test Variable    ${BOOK_ID}    ${book['id']}

The Book Should Be Created Successfully
    Should Not Be Empty    ${CREATED_BOOK}
    Should Not Be Equal    ${CREATED_BOOK['id']}    ${NONE}

The Book Should Have Correct Properties
    Should Be Equal As Strings    ${CREATED_BOOK['title']}    The Catcher in the Rye
    Should Be Equal As Strings    ${CREATED_BOOK['author']}    J.D. Salinger
    Should Be Equal As Numbers    ${CREATED_BOOK['pages']}    277
    Should Be Equal As Strings    ${CREATED_BOOK['category']}    Fiction

Multiple Books Exist In The System
    ${book1}=    Create Book Via API    Book One    Author One    100    Fiction
    ${book2}=    Create Book Via API    Book Two    Author Two    200    Non-Fiction
    ${book3}=    Create Book Via API    Book Three    Author Three    300    Fantasy

All Books Are Requested
    ${books}=    Get All Books Via API
    Set Test Variable    ${ALL_BOOKS}    ${books}

A List Of Books Should Be Received
    Should Not Be Empty    ${ALL_BOOKS}
    ${length}=    Get Length    ${ALL_BOOKS}
    Should Be True    ${length} > 0    msg=Expected at least 1 book, got ${length}

The List Should Contain All Created Books
    ${length}=    Get Length    ${ALL_BOOKS}
    Should Be True    ${length} >= 3    msg=Expected at least 3 books, got ${length}

A Book Exists With Title "${title}"
    ${book}=    Create Book Via API    ${title}    Test Author    250    Fiction
    Set Test Variable    ${CREATED_BOOK}    ${book}
    Set Test Variable    ${BOOK_ID}    ${book['id']}

The Book Is Requested By Its ID
    ${book}=    Get Book By ID Via API    ${BOOK_ID}
    Set Test Variable    ${CREATED_BOOK}    ${book}

The Book Details Should Be Received
    Should Not Be Empty    ${CREATED_BOOK}
    Should Be Equal As Numbers    ${CREATED_BOOK['id']}    ${BOOK_ID}

The Details Should Match The Created Book
    Should Not Be Empty    ${CREATED_BOOK['title']}
    Should Not Be Empty    ${CREATED_BOOK['author']}

The Book Is Updated With New Title "${new_title}"
    ${updated_book}=    Update Book Via API    ${BOOK_ID}    ${new_title}    Test Author    250    Fiction
    Set Test Variable    ${CREATED_BOOK}    ${updated_book}

The Book Should Be Updated Successfully
    Should Not Be Empty    ${CREATED_BOOK}

The Book Should Have The New Title
    Should Be Equal As Strings    ${CREATED_BOOK['title']}    Animal Farm: A Fairy Story

The Book Is Deleted
    ${response}=    Delete Book Via API    ${BOOK_ID}
    Should Be Equal As Strings    ${response['message']}    Book deleted successfully

The Book Should Be Deleted Successfully
    Wait For Response

The Book Should Not Exist In The System
    Book Should Not Exist    ${BOOK_ID}

The Book Is Marked As Favorite
    ${book}=    Toggle Favorite Via API    ${BOOK_ID}    ${True}
    Set Test Variable    ${CREATED_BOOK}    ${book}

The Book Should Be Marked As Favorite
    Should Be True    ${CREATED_BOOK['favorite']}

The Book Is Unmarked As Favorite
    ${book}=    Toggle Favorite Via API    ${BOOK_ID}    ${False}
    Set Test Variable    ${CREATED_BOOK}    ${book}

The Book Should Not Be Marked As Favorite
    Should Not Be True    ${CREATED_BOOK['favorite']}

A Book With Non-Existent ID "${book_id}" Is Requested
    Book Should Not Exist    ${book_id}

A 404 Error Should Be Received
    Log    404 error received as expected

Book Creation Is Attempted Without Required Fields
    ${body}=    Create Dictionary    title=Incomplete Book
    ${response}=    POST On Session    books_api    /books/    json=${body}    expected_status=422

A Validation Error Should Be Received
    Log    Validation error received as expected
