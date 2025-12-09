*** Settings ***
Documentation    UI acceptance tests for Books Database Service.
...              Tests cover CRUD operations, search, and filtering functionality.
Resource         resources/ui_keywords.resource
Suite Setup      Open Books Application
Suite Teardown   Close Books Application
Test Tags        ui    acceptance

*** Test Cases ***
User can add a new book
    [Documentation]    Verify that user can successfully add a new book through the UI
    [Tags]    create    smoke
    Given user is on the books application homepage
    When user fills in the book form with title "The Great Gatsby" author "F. Scott Fitzgerald" pages "180" category "Fiction"
    And user submits the book form
    Then book "The Great Gatsby" should appear in the books list

User can edit an existing book
    [Documentation]    Verify that user can edit book details
    [Tags]    update
    Given user is on the books application homepage
    And book "1984" by "George Orwell" with "328" pages exists
    When user clicks edit button for book "1984"
    And user updates the book with title "Nineteen Eighty-Four" author "George Orwell" pages "328" category "Science Fiction"
    And user submits the edit form
    Then book "Nineteen Eighty-Four" should appear in the books list

User can delete a book
    [Documentation]    Verify that user can delete a book
    [Tags]    delete
    Given user is on the books application homepage
    And book "To Kill a Mockingbird" by "Harper Lee" with "281" pages exists
    When user clicks delete button for book "To Kill a Mockingbird"
    And user confirms the deletion
    Then book "To Kill a Mockingbird" should not be visible

User can mark book as favorite
    [Documentation]    Verify that user can mark a book as favorite
    [Tags]    favorite
    Given user is on the books application homepage
    And book "Pride and Prejudice" by "Jane Austen" with "432" pages exists
    When user clicks the favorite button for book "Pride and Prejudice"
    Then book "Pride and Prejudice" should be marked as favorite

User can search for books
    [Documentation]    Verify that user can search for books by title or author
    [Tags]    search
    Given user is on the books application homepage
    And multiple books exist in the database
    When user searches for "Tolkien"
    Then only books matching "Tolkien" should be displayed

User can filter books by category
    [Documentation]    Verify that user can filter books by category
    [Tags]    filter
    Given user is on the books application homepage
    And books in different categories exist
    When user filters by category "Fantasy"
    Then only books in category "Fantasy" should be displayed

User can filter favorite books
    [Documentation]    Verify that user can filter to show only favorite books
    [Tags]    filter    favorite
    Given user is on the books application homepage
    And some books are marked as favorites
    When user clicks the favorites filter
    Then only favorite books should be displayed

*** Keywords ***
User Is On The Books Application Homepage
    Wait For Elements State    css=h1    visible    timeout=${TIMEOUT}

User Fills In The Book Form With Title "${title}" Author "${author}" Pages "${pages}" Category "${category}"
    Fill Book Form    ${title}    ${author}    ${pages}    ${category}

User Submits The Book Form
    Submit Book Form

Book "${title}" Should Appear In The Books List
    Book Should Be Visible In List    ${title}

Book "${title}" By "${author}" With "${pages}" Pages Exists
    Fill Book Form    ${title}    ${author}    ${pages}
    Submit Book Form
    Book Should Be Visible In List    ${title}

User Clicks Edit Button For Book "${title}"
    Click Edit Book Button    ${title}

User Updates The Book With Title "${title}" Author "${author}" Pages "${pages}" Category "${category}"
    Fill Edit Form    ${title}    ${author}    ${pages}    ${category}

User Submits The Edit Form
    Submit Edit Form

User Clicks Delete Button For Book "${title}"
    Confirm Delete
    Click Delete Book Button    ${title}

User Confirms The Deletion
    Wait For Response

Book "${title}" Should Not Be Visible
    Book Should Not Be Visible    ${title}

User Clicks The Favorite Button For Book "${title}"
    Click Favorite Button    ${title}

Book "${title}" Should Be Marked As Favorite
    Wait For Response
    Book Should Be Visible In List    ${title}

Multiple Books Exist In The Database
    Fill Book Form    The Hobbit    J.R.R. Tolkien    310    Fantasy
    Submit Book Form
    Fill Book Form    The Lord of the Rings    J.R.R. Tolkien    1178    Fantasy
    Submit Book Form
    Fill Book Form    Harry Potter    J.K. Rowling    309    Fantasy
    Submit Book Form

User Searches For "${search_term}"
    Search For Book    ${search_term}

Only Books Matching "${search_term}" Should Be Displayed
    Wait For Response
    Book Should Be Visible In List    Tolkien

Books In Different Categories Exist
    Fill Book Form    The Hobbit    J.R.R. Tolkien    310    Fantasy
    Submit Book Form
    Fill Book Form    Sapiens    Yuval Noah Harari    443    Non-Fiction
    Submit Book Form

User Filters By Category "${category}"
    Filter By Category    ${category}

Only Books In Category "${category}" Should Be Displayed
    Wait For Response

Some Books Are Marked As Favorites
    Filter By Category    all
    Fill Book Form    Favorite Book    Test Author    200    Fiction
    Submit Book Form
    Click Favorite Button    Favorite Book

User Clicks The Favorites Filter
    Filter By Favorites

Only Favorite Books Should Be Displayed
    Wait For Response
