*** Settings ***
Documentation    UI acceptance tests for Books Database Service
Resource         resources/common.resource
Resource         resources/keywords/ui_keywords.resource
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Tags        ui    acceptance

*** Test Cases ***
User Can Open Books UI
    [Documentation]    Verify user can access the books application
    [Tags]    smoke
    Given the books application is running
    When user opens the books application
    Then the books page should be displayed

User Can Add A New Book
    [Documentation]    Verify user can add a new book through UI
    [Tags]    crud
    Given the books application is open
    When user adds a new book with title "Test Book" author "Test Author" pages "200" category "Fiction"
    Then the book should be displayed in the list

User Can Search For Books
    [Documentation]    Verify user can search for books
    [Tags]    search
    Given the books application has books
    When user searches for "Test Book"
    Then only matching books should be displayed

User Can Filter Books By Category
    [Documentation]    Verify user can filter books by category
    [Tags]    filter
    Given the books application has books in different categories
    When user filters books by "Fiction" category
    Then only fiction books should be displayed

User Can Mark Book As Favorite
    [Documentation]    Verify user can mark books as favorites
    [Tags]    favorite
    Given the books application has a book "Sample Book"
    When user marks the book as favorite
    Then the book should show as favorited

User Can Delete A Book
    [Documentation]    Verify user can delete books
    [Tags]    crud
    Given the books application has a book "Book to Delete"
    When user deletes the book
    Then the book should not be displayed in the list

*** Keywords ***
The Books Application Is Running
    [Documentation]    Ensure the application is accessible
    Open Books Application

User Opens The Books Application
    [Documentation]    User navigates to the books application
    Navigate To Books Page

The Books Page Should Be Displayed
    [Documentation]    Verify the main books page is shown
    Wait For Elements State    h1:has-text("Books Database")    visible    timeout=${TIMEOUT}

The Books Application Is Open
    [Documentation]    Ensure the books application is open
    Open Books Application
    Navigate To Books Page

User Adds A New Book With Title "${title}" Author "${author}" Pages "${pages}" Category "${category}"
    [Documentation]    User adds a new book with specified details
    Add New Book    ${title}    ${author}    ${pages}    ${category}

The Book Should Be Displayed In The List
    [Documentation]    Verify the book appears in the books list
    Wait For Elements State    [data-testid="book-item"]    visible    timeout=${TIMEOUT}

The Books Application Has Books
    [Documentation]    Ensure there are books in the application
    Open Books Application
    Navigate To Books Page
    Add New Book    Sample Book 1    Author 1    150    Fiction
    Add New Book    Sample Book 2    Author 2    250    Non-Fiction

User Searches For "${search_term}"
    [Documentation]    User performs a search
    Search For Book    ${search_term}

Only Matching Books Should Be Displayed
    [Documentation]    Verify only matching books are shown
    Wait For Elements State    [data-testid="book-item"]    visible    timeout=${TIMEOUT}

The Books Application Has Books In Different Categories
    [Documentation]    Setup books in different categories
    Open Books Application
    Navigate To Books Page
    Add New Book    Fiction Book    Fiction Author    200    Fiction
    Add New Book    Science Book    Science Author    300    Non-Fiction

User Filters Books By "${category}" Category
    [Documentation]    User applies category filter
    Filter Books By Category    ${category}

Only Fiction Books Should Be Displayed
    [Documentation]    Verify only fiction books are visible
    Wait For Elements State    [data-testid="book-item"]:has-text("Fiction")    visible    timeout=${TIMEOUT}

The Books Application Has A Book "${book_title}"
    [Documentation]    Ensure specific book exists
    Open Books Application
    Navigate To Books Page
    Add New Book    ${book_title}    Test Author    100    Fiction

User Marks The Book As Favorite
    [Documentation]    User toggles favorite status
    Toggle Book Favorite    Sample Book

The Book Should Show As Favorited
    [Documentation]    Verify book shows favorite status
    Wait For Elements State    [data-testid="favorite-icon"][class*="favorited"]    visible    timeout=${TIMEOUT}

User Deletes The Book
    [Documentation]    User removes the book
    Delete Book    Book to Delete

The Book Should Not Be Displayed In The List
    [Documentation]    Verify book is removed from list
    Wait For Elements State    [data-testid="book-item"]:has-text("Book to Delete")    hidden    timeout=${TIMEOUT}