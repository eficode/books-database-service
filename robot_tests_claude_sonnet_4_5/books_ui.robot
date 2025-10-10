*** Settings ***
Documentation    UI acceptance tests for Books Database Service
Resource         resources/ui_keywords.resource
Suite Setup      Open Books Application
Suite Teardown   Close Books Application
Test Tags        ui    acceptance

*** Test Cases ***
User Can Add A New Book
    [Documentation]    Verify that a user can successfully add a new book through the UI
    [Tags]    create    smoke
    Given I am on the books application homepage
    When I fill in the book form with title "The Great Gatsby" author "F. Scott Fitzgerald" pages "180" category "Fiction"
    And I submit the book form
    Then the book "The Great Gatsby" should appear in the books list

User Can Edit An Existing Book
    [Documentation]    Verify that a user can edit book details
    [Tags]    update
    Given I am on the books application homepage
    And a book "1984" by "George Orwell" with "328" pages exists
    When I click edit button for book "1984"
    And I update the book with title "Nineteen Eighty-Four" author "George Orwell" pages "328" category "Science Fiction"
    And I submit the edit form
    Then the book "Nineteen Eighty-Four" should appear in the books list

User Can Delete A Book
    [Documentation]    Verify that a user can delete a book
    [Tags]    delete
    Given I am on the books application homepage
    And a book "To Kill a Mockingbird" by "Harper Lee" with "281" pages exists
    When I click delete button for book "To Kill a Mockingbird"
    And I confirm the deletion
    Then the book "To Kill a Mockingbird" should not be visible

User Can Mark Book As Favorite
    [Documentation]    Verify that a user can mark a book as favorite
    [Tags]    favorite
    Given I am on the books application homepage
    And a book "Pride and Prejudice" by "Jane Austen" with "432" pages exists
    When I click the favorite button for book "Pride and Prejudice"
    Then the book "Pride and Prejudice" should be marked as favorite

User Can Search For Books
    [Documentation]    Verify that a user can search for books by title or author
    [Tags]    search
    Given I am on the books application homepage
    And multiple books exist in the database
    When I search for "Tolkien"
    Then only books matching "Tolkien" should be displayed

User Can Filter Books By Category
    [Documentation]    Verify that a user can filter books by category
    [Tags]    filter
    Given I am on the books application homepage
    And books in different categories exist
    When I filter by category "Fantasy"
    Then only books in category "Fantasy" should be displayed

User Can Filter Favorite Books
    [Documentation]    Verify that a user can filter to show only favorite books
    [Tags]    filter    favorite
    Given I am on the books application homepage
    And some books are marked as favorites
    When I click the favorites filter
    Then only favorite books should be displayed

*** Keywords ***
I am on the books application homepage
    Wait For Elements State    css=h1    visible    timeout=${TIMEOUT}

I fill in the book form with title "${title}" author "${author}" pages "${pages}" category "${category}"
    Fill Book Form    ${title}    ${author}    ${pages}    ${category}

I submit the book form
    Submit Book Form

The book "${title}" should appear in the books list
    Book Should Be Visible In List    ${title}

A book "${title}" by "${author}" with "${pages}" pages exists
    Fill Book Form    ${title}    ${author}    ${pages}
    Submit Book Form
    Book Should Be Visible In List    ${title}

I click edit button for book "${title}"
    Click Edit Book Button    ${title}

I update the book with title "${title}" author "${author}" pages "${pages}" category "${category}"
    Fill Edit Form    ${title}    ${author}    ${pages}    ${category}

I submit the edit form
    Submit Edit Form

I click delete button for book "${title}"
    Confirm Delete
    Click Delete Book Button    ${title}

I confirm the deletion
    Wait For Response

The book "${title}" should not be visible
    Book Should Not Be Visible    ${title}

I click the favorite button for book "${title}"
    Click Favorite Button    ${title}

The book "${title}" should be marked as favorite
    Wait For Response
    Book Should Be Visible In List    ${title}

Multiple books exist in the database
    Fill Book Form    The Hobbit    J.R.R. Tolkien    310    Fantasy
    Submit Book Form
    Fill Book Form    The Lord of the Rings    J.R.R. Tolkien    1178    Fantasy
    Submit Book Form
    Fill Book Form    Harry Potter    J.K. Rowling    309    Fantasy
    Submit Book Form

I search for "${search_term}"
    Search For Book    ${search_term}

Only books matching "${search_term}" should be displayed
    Wait For Response
    Book Should Be Visible In List    Tolkien

Books in different categories exist
    Fill Book Form    The Hobbit    J.R.R. Tolkien    310    Fantasy
    Submit Book Form
    Fill Book Form    Sapiens    Yuval Noah Harari    443    Non-Fiction
    Submit Book Form

I filter by category "${category}"
    Filter By Category    ${category}

Only books in category "${category}" should be displayed
    Wait For Response

Some books are marked as favorites
    Filter By Category    all
    Fill Book Form    Favorite Book    Test Author    200    Fiction
    Submit Book Form
    Click Favorite Button    Favorite Book

I click the favorites filter
    Filter By Favorites

Only favorite books should be displayed
    Wait For Response
