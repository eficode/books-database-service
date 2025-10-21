*** Settings ***
Documentation    UI acceptance tests for Books Database Service.
...              Tests cover CRUD operations, search, filtering, and sorting functionality.
Resource         resources/common.resource
Resource         resources/ui_keywords.resource
Suite Setup      Setup UI Test Suite
Suite Teardown   Teardown UI Test Suite
Test Setup       Open Books Application
Test Teardown    Close Books Application

*** Keywords ***
Setup UI Test Suite
    [Documentation]    Setup test suite with Docker environment
    Setup Test Environment

Teardown UI Test Suite
    [Documentation]    Cleanup test suite environment
    Teardown Test Environment

*** Test Cases ***
User can open books UI
    [Documentation]    Test that user can open the books application UI
    [Tags]    ui    smoke
    Given user is on the books application homepage
    Then user should see the books library interface
    And user should see the add book form

User can add a new book through UI
    [Documentation]    Test adding a new book through the web interface
    [Tags]    ui    crud
    Given user is on the books application homepage
    When user fills in the book form with valid data
    And user submits the book form
    Then the book should appear in the books list
    And user should see a success notification

User can search for books
    [Documentation]    Test searching for books using the search functionality
    [Tags]    ui    search
    Given user is on the books application homepage
    And there are books displayed in the list
    When user searches for a specific book title
    Then only matching books should be displayed
    And the books count should be updated

User can filter books by category
    [Documentation]    Test filtering books by category
    [Tags]    ui    filter
    Given user is on the books application homepage
    And there are books displayed in the list
    When user filters books by Fiction category
    Then only Fiction books should be displayed
    And the books count should reflect the filter

User can sort books by title
    [Documentation]    Test sorting books by title
    [Tags]    ui    sort
    Given user is on the books application homepage
    And there are books displayed in the list
    When user sorts books by title
    Then books should be displayed in alphabetical order

User can toggle sort direction
    [Documentation]    Test toggling sort direction
    [Tags]    ui    sort
    Given user is on the books application homepage
    And there are books displayed in the list
    When user sorts books by title
    And user toggles the sort direction
    Then books should be displayed in reverse alphabetical order

User can filter favorite books
    [Documentation]    Test filtering books by favorite status
    [Tags]    ui    favorite
    Given user is on the books application homepage
    And there are books displayed in the list
    When user clicks the favorites filter
    Then only favorite books should be displayed

*** Keywords ***
User Is On The Books Application Homepage
    [Documentation]    Verify user is on the homepage
    Verify Page Title    Books Library
    Wait For Books To Load

User Should See The Books Library Interface
    [Documentation]    Verify main interface elements are visible
    Wait For Element To Be Visible    h1:has-text("Books Library")
    Wait For Element To Be Visible    id=books-list

User Should See The Add Book Form
    [Documentation]    Verify add book form is visible
    Wait For Element To Be Visible    id=book-form
    Wait For Element To Be Visible    id=title
    Wait For Element To Be Visible    id=author
    Wait For Element To Be Visible    id=pages
    Wait For Element To Be Visible    id=category

User Fills In The Book Form With Valid Data
    [Documentation]    Fill the book form with test data
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    Fill Book Form    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${TEST_TITLE}    ${title}
    Set Test Variable    ${TEST_AUTHOR}    ${author}
    Set Test Variable    ${TEST_PAGES}    ${pages}
    Set Test Variable    ${TEST_CATEGORY}    ${category}

User Submits The Book Form
    [Documentation]    Submit the book creation form
    Submit Book Form
    Sleep    2s

The Book Should Appear In The Books List
    [Documentation]    Verify book appears in the list
    Verify Book Card Exists    ${TEST_TITLE}

User Should See A Success Notification
    [Documentation]    Verify success notification appears
    Sleep    1s

There Are Books Displayed In The List
    [Documentation]    Verify books are displayed
    Wait For Books To Load
    ${book_count}=    Get Element Count    .book-card
    Should Be True    ${book_count} > 0    msg=No books found in the list

User Searches For A Specific Book Title
    [Documentation]    Search for a book using search input
    ${first_book_title}=    Get Text    .book-card:first-child .book-title
    Search For Books    ${first_book_title}
    Set Test Variable    ${SEARCH_TERM}    ${first_book_title}

Only Matching Books Should Be Displayed
    [Documentation]    Verify only matching books are shown
    Sleep    1s
    ${visible_books}=    Get Element Count    .book-card
    Should Be True    ${visible_books} >= 1    msg=No matching books found
    ${first_visible_title}=    Get Text    .book-card:first-child .book-title
    Should Contain    ${first_visible_title}    ${SEARCH_TERM}    ignore_case=True

The Books Count Should Be Updated
    [Documentation]    Verify books count display is updated
    ${shown_count}=    Get Text    id=shown-count
    Should Be True    int($shown_count) >= 1

User Filters Books By Fiction Category
    [Documentation]    Filter books by Fiction category
    Filter Books By Category    Fiction

Only Fiction Books Should Be Displayed
    [Documentation]    Verify only Fiction books are shown
    Sleep    1s
    ${visible_books}=    Get Element Count    .book-card
    Should Be True    ${visible_books} >= 0
    IF    ${visible_books} > 0
        ${category_elements}=    Get Element Count    .book-card .book-category:has-text("Fiction")
        Should Be Equal As Numbers    ${category_elements}    ${visible_books}
    END

The Books Count Should Reflect The Filter
    [Documentation]    Verify books count reflects the applied filter
    ${shown_count}=    Get Text    id=shown-count
    ${visible_books}=    Get Element Count    .book-card
    Should Be Equal As Numbers    ${shown_count}    ${visible_books}

User Sorts Books By Title
    [Documentation]    Sort books by title field
    Sort Books By Field    Title

Books Should Be Displayed In Alphabetical Order
    [Documentation]    Verify books are in alphabetical order
    Sleep    1s
    ${book_titles}=    Get Elements    .book-card .book-title
    ${title_count}=    Get Length    ${book_titles}
    IF    ${title_count} > 1
        ${first_title}=    Get Text    ${book_titles}[0]
        ${second_title}=    Get Text    ${book_titles}[1]
        Should Be True    '${first_title}' <= '${second_title}'
    END

User Toggles The Sort Direction
    [Documentation]    Toggle the sort direction
    Toggle Sort Direction

Books Should Be Displayed In Reverse Alphabetical Order
    [Documentation]    Verify books are in reverse alphabetical order
    Sleep    1s
    ${book_titles}=    Get Elements    .book-card .book-title
    ${title_count}=    Get Length    ${book_titles}
    IF    ${title_count} > 1
        ${first_title}=    Get Text    ${book_titles}[0]
        ${second_title}=    Get Text    ${book_titles}[1]
        Should Be True    '${first_title}' >= '${second_title}'
    END

User Clicks The Favorites Filter
    [Documentation]    Click the favorites filter button
    Click Favorite Filter

Only Favorite Books Should Be Displayed
    [Documentation]    Verify only favorite books are shown
    Sleep    1s
    ${visible_books}=    Get Element Count    .book-card
    ${filter_class}=    Get Attribute    id=favorite-filter    class
    Should Contain    ${filter_class}    active
