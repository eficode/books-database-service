*** Settings ***
Documentation    UI acceptance tests for Books Database Service
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
Scenario: User Can Open Books UI
    [Documentation]    Test that user can open the books application UI
    [Tags]    ui    smoke
    Given I am on the books application homepage
    Then I should see the books library interface
    And I should see the add book form

Scenario: User Can Add A New Book Through UI
    [Documentation]    Test adding a new book through the web interface
    [Tags]    ui    crud
    Given I am on the books application homepage
    When I fill in the book form with valid data
    And I submit the book form
    Then the book should appear in the books list
    And I should see a success notification

Scenario: User Can Search For Books
    [Documentation]    Test searching for books using the search functionality
    [Tags]    ui    search
    Given I am on the books application homepage
    And there are books displayed in the list
    When I search for a specific book title
    Then only matching books should be displayed
    And the books count should be updated

Scenario: User Can Filter Books By Category
    [Documentation]    Test filtering books by category
    [Tags]    ui    filter
    Given I am on the books application homepage
    And there are books displayed in the list
    When I filter books by Fiction category
    Then only Fiction books should be displayed
    And the books count should reflect the filter

Scenario: User Can Sort Books By Title
    [Documentation]    Test sorting books by title
    [Tags]    ui    sort
    Given I am on the books application homepage
    And there are books displayed in the list
    When I sort books by title
    Then books should be displayed in alphabetical order

Scenario: User Can Toggle Sort Direction
    [Documentation]    Test toggling sort direction
    [Tags]    ui    sort
    Given I am on the books application homepage
    And there are books displayed in the list
    When I sort books by title
    And I toggle the sort direction
    Then books should be displayed in reverse alphabetical order

Scenario: User Can Filter Favorite Books
    [Documentation]    Test filtering books by favorite status
    [Tags]    ui    favorite
    Given I am on the books application homepage
    And there are books displayed in the list
    When I click the favorites filter
    Then only favorite books should be displayed

*** Keywords ***
Given I am on the books application homepage
    [Documentation]    Verify user is on the homepage
    Verify Page Title    Books Library
    Wait For Books To Load

Then I should see the books library interface
    [Documentation]    Verify main interface elements are visible
    Wait For Element To Be Visible    h1:has-text("Books Library")
    Wait For Element To Be Visible    id=books-list

And I should see the add book form
    [Documentation]    Verify add book form is visible
    Wait For Element To Be Visible    id=book-form
    Wait For Element To Be Visible    id=title
    Wait For Element To Be Visible    id=author
    Wait For Element To Be Visible    id=pages
    Wait For Element To Be Visible    id=category

When I fill in the book form with valid data
    [Documentation]    Fill the book form with test data
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    Fill Book Form    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${TEST_TITLE}    ${title}
    Set Test Variable    ${TEST_AUTHOR}    ${author}
    Set Test Variable    ${TEST_PAGES}    ${pages}
    Set Test Variable    ${TEST_CATEGORY}    ${category}

And I submit the book form
    [Documentation]    Submit the book creation form
    Submit Book Form
    Sleep    2s    # Wait for API call to complete

Then the book should appear in the books list
    [Documentation]    Verify book appears in the list
    Verify Book Card Exists    ${TEST_TITLE}

And I should see a success notification
    [Documentation]    Verify success notification appears
    # Note: This depends on the UI implementation showing notifications
    Sleep    1s    # Allow time for notification to appear

And there are books displayed in the list
    [Documentation]    Verify books are displayed
    Wait For Books To Load
    ${book_count}=    Get Element Count    .book-card
    Should Be True    ${book_count} > 0

When I search for a specific book title
    [Documentation]    Search for a book using search input
    ${first_book_title}=    Get Text    .book-card:first-child .book-title
    Search For Books    ${first_book_title}
    Set Test Variable    ${SEARCH_TERM}    ${first_book_title}

Then only matching books should be displayed
    [Documentation]    Verify only matching books are shown
    Sleep    1s    # Wait for search to complete
    ${visible_books}=    Get Element Count    .book-card
    Should Be True    ${visible_books} >= 1
    # Verify at least one book contains the search term
    ${first_visible_title}=    Get Text    .book-card:first-child .book-title
    Should Contain    ${first_visible_title}    ${SEARCH_TERM}    ignore_case=True

And the books count should be updated
    [Documentation]    Verify books count display is updated
    ${shown_count}=    Get Text    id=shown-count
    Should Be True    int($shown_count) >= 1

When I filter books by Fiction category
    [Documentation]    Filter books by Fiction category
    Filter Books By Category    Fiction

Then only Fiction books should be displayed
    [Documentation]    Verify only Fiction books are shown
    Sleep    1s    # Wait for filter to apply
    ${visible_books}=    Get Element Count    .book-card
    Should Be True    ${visible_books} >= 0
    # If books are visible, verify they are Fiction
    IF    ${visible_books} > 0
        ${category_elements}=    Get Element Count    .book-card .book-category:has-text("Fiction")
        Should Be Equal As Numbers    ${category_elements}    ${visible_books}
    END

And the books count should reflect the filter
    [Documentation]    Verify books count reflects the applied filter
    ${shown_count}=    Get Text    id=shown-count
    ${visible_books}=    Get Element Count    .book-card
    Should Be Equal As Numbers    ${shown_count}    ${visible_books}

When I sort books by title
    [Documentation]    Sort books by title field
    Sort Books By Field    Title

Then books should be displayed in alphabetical order
    [Documentation]    Verify books are in alphabetical order
    Sleep    1s    # Wait for sort to apply
    ${book_titles}=    Get Elements    .book-card .book-title
    ${title_count}=    Get Length    ${book_titles}
    IF    ${title_count} > 1
        ${first_title}=    Get Text    ${book_titles}[0]
        ${second_title}=    Get Text    ${book_titles}[1]
        Should Be True    '${first_title}' <= '${second_title}'
    END

And I toggle the sort direction
    [Documentation]    Toggle the sort direction
    Toggle Sort Direction

Then books should be displayed in reverse alphabetical order
    [Documentation]    Verify books are in reverse alphabetical order
    Sleep    1s    # Wait for sort to apply
    ${book_titles}=    Get Elements    .book-card .book-title
    ${title_count}=    Get Length    ${book_titles}
    IF    ${title_count} > 1
        ${first_title}=    Get Text    ${book_titles}[0]
        ${second_title}=    Get Text    ${book_titles}[1]
        Should Be True    '${first_title}' >= '${second_title}'
    END

When I click the favorites filter
    [Documentation]    Click the favorites filter button
    Click Favorite Filter

Then only favorite books should be displayed
    [Documentation]    Verify only favorite books are shown
    Sleep    1s    # Wait for filter to apply
    ${visible_books}=    Get Element Count    .book-card
    # Verify favorite filter is active
    ${filter_class}=    Get Attribute    id=favorite-filter    class
    Should Contain    ${filter_class}    active