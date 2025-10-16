*** Settings ***
Documentation    UI acceptance tests for Books Library application using Gherkin syntax
Resource         resources/common.resource
Resource         keywords/ui_keywords.resource
Resource         keywords/api_keywords.resource

Suite Setup      Setup Test Suite
Suite Teardown   Teardown Test Suite
Test Setup       Setup Test Case
Test Teardown    Teardown Test Case

Test Tags        ui    acceptance

*** Variables ***
${TEST_BOOK_TITLE}       Robot Framework Testing Guide
${TEST_BOOK_AUTHOR}      Test Automation Expert
${TEST_BOOK_PAGES}       350
${TEST_BOOK_CATEGORY}    Science

*** Keywords ***
Setup Test Suite
    [Documentation]    Suite-level setup
    Setup API Session
    Clean Up Test Books

Teardown Test Suite
    [Documentation]    Suite-level teardown
    Clean Up Test Books
    Teardown API Session

Setup Test Case
    [Documentation]    Test case setup
    Setup Browser Session
    Clear All Books Via API

Teardown Test Case
    [Documentation]    Test case teardown
    Run Keyword If Test Failed    Take Screenshot On Failure
    Run Keyword If Test Failed    Log Browser Console
    Teardown Browser Session

*** Test Cases ***
Scenario: User Can Access The Books Library Homepage
    [Documentation]    Verify that users can access the main Books Library page
    [Tags]    smoke    homepage
    Given I Am On The Books Library Homepage
    Then I Should See The Book Count    0
    And Verify No Books Message

Scenario: User Can Add A New Book Successfully
    [Documentation]    Verify that users can add a new book through the UI
    [Tags]    smoke    add-book    crud
    Given I Am On The Books Library Homepage
    When I Add A New Book    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}
    Then I Should See The Book In The List    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}
    And I Should See The Book Count    1

Scenario: User Can Add Multiple Books With Different Categories
    [Documentation]    Verify that users can add multiple books with various categories
    [Tags]    add-book    categories    crud
    Given I Am On The Books Library Homepage
    When I Add A New Book    Fiction Book    Fiction Author    200    Fiction
    And I Add A New Book    Science Book    Science Author    300    Science
    And I Add A New Book    Fantasy Book    Fantasy Author    400    Fantasy
    Then I Should See The Book In The List    Fiction Book    Fiction Author    200    Fiction
    And I Should See The Book In The List    Science Book    Science Author    300    Science
    And I Should See The Book In The List    Fantasy Book    Fantasy Author    400    Fantasy
    And I Should See The Book Count    3

Scenario: User Can Search For Books By Title
    [Documentation]    Verify that users can search for books using the search functionality
    [Tags]    search    filter
    Given I Am On The Books Library Homepage
    And I Add A New Book    Searchable Book    Search Author    250    Fiction
    And I Add A New Book    Another Book    Another Author    150    Science
    When I Search For Books    Searchable
    Then I Should See The Book In The List    Searchable Book    Search Author    250    Fiction
    And I Should Not See The Book In The List    Another Book

Scenario: User Can Search For Books By Author
    [Documentation]    Verify that users can search for books by author name
    [Tags]    search    filter
    Given I Am On The Books Library Homepage
    And I Add A New Book    Book One    Unique Author    200    Fiction
    And I Add A New Book    Book Two    Common Author    300    Science
    When I Search For Books    Unique Author
    Then I Should See The Book In The List    Book One    Unique Author    200    Fiction
    And I Should Not See The Book In The List    Book Two

Scenario: User Can Filter Books By Category
    [Documentation]    Verify that users can filter books by category
    [Tags]    filter    categories
    Given I Am On The Books Library Homepage
    And I Add A New Book    Fiction Book    Fiction Author    200    Fiction
    And I Add A New Book    Science Book    Science Author    300    Science
    And I Add A New Book    Fantasy Book    Fantasy Author    400    Fantasy
    When I Filter Books By Category    Science
    Then I Should See Books Filtered By    category    Science
    And I Should See The Book In The List    Science Book    Science Author    300    Science
    And I Should Not See The Book In The List    Fiction Book

Scenario: User Can Sort Books By Title
    [Documentation]    Verify that users can sort books alphabetically by title
    [Tags]    sort    ordering
    Given I Am On The Books Library Homepage
    And I Add A New Book    Zebra Book    Author Z    200    Fiction
    And I Add A New Book    Alpha Book    Author A    300    Science
    And I Add A New Book    Beta Book    Author B    400    Fantasy
    When I Sort Books By    Title
    Then I Should See Books Sorted By    title    ascending

Scenario: User Can Sort Books By Author
    [Documentation]    Verify that users can sort books by author name
    [Tags]    sort    ordering
    Given I Am On The Books Library Homepage
    And I Add A New Book    Book Z    Zebra Author    200    Fiction
    And I Add A New Book    Book A    Alpha Author    300    Science
    And I Add A New Book    Book B    Beta Author    400    Fantasy
    When I Sort Books By    Author
    Then I Should See Books Sorted By    author    ascending

Scenario: User Can Sort Books By Pages
    [Documentation]    Verify that users can sort books by page count
    [Tags]    sort    ordering
    Given I Am On The Books Library Homepage
    And I Add A New Book    Short Book    Author    100    Fiction
    And I Add A New Book    Long Book    Author    500    Science
    And I Add A New Book    Medium Book    Author    300    Fantasy
    When I Sort Books By    Pages
    Then I Should See Books Sorted By    pages    ascending

Scenario: User Can Toggle Sort Direction
    [Documentation]    Verify that users can change sort direction from ascending to descending
    [Tags]    sort    ordering
    Given I Am On The Books Library Homepage
    And I Add A New Book    Alpha Book    Author A    200    Fiction
    And I Add A New Book    Beta Book    Author B    300    Science
    And I Add A New Book    Gamma Book    Author C    400    Fantasy
    When I Sort Books By    Title
    And I Toggle Sort Direction
    Then I Should See Books Sorted By    title    descending

Scenario: User Can Mark A Book As Favorite
    [Documentation]    Verify that users can mark books as favorites
    [Tags]    favorites    interaction
    Given I Am On The Books Library Homepage
    And I Add A New Book    Favorite Book    Favorite Author    250    Fiction
    When I Toggle Favorite On Book    Favorite Book
    Then The Book Should Be Marked As Favorite    Favorite Book

Scenario: User Can Filter Books By Favorites
    [Documentation]    Verify that users can filter to show only favorite books
    [Tags]    favorites    filter
    Given I Am On The Books Library Homepage
    And I Add A New Book    Regular Book    Regular Author    200    Fiction
    And I Add A New Book    Favorite Book    Favorite Author    300    Science
    And I Toggle Favorite On Book    Favorite Book
    When I Filter Books By Favorites
    Then I Should See Books Filtered By    favorite    true
    And I Should See The Book In The List    Favorite Book    Favorite Author    300    Science
    And I Should Not See The Book In The List    Regular Book

Scenario: User Can Edit An Existing Book
    [Documentation]    Verify that users can edit book details
    [Tags]    edit-book    crud    modal
    Given I Am On The Books Library Homepage
    And I Add A New Book    Original Book    Original Author    200    Fiction
    When I Click Edit On Book    Original Book
    Then I Should See The Edit Modal
    When I Edit The Book Details    Updated Book    Updated Author    300    Science
    And I Save The Book Changes
    Then I Should Not See The Edit Modal
    And I Should See The Book In The List    Updated Book    Updated Author    300    Science
    And I Should Not See The Book In The List    Original Book

Scenario: User Can Cancel Book Editing
    [Documentation]    Verify that users can cancel editing without saving changes
    [Tags]    edit-book    modal    cancel
    Given I Am On The Books Library Homepage
    And I Add A New Book    Original Book    Original Author    200    Fiction
    When I Click Edit On Book    Original Book
    Then I Should See The Edit Modal
    When I Edit The Book Details    Should Not Save    Should Not Save    999    Horror
    And I Close The Edit Modal
    Then I Should Not See The Edit Modal
    And I Should See The Book In The List    Original Book    Original Author    200    Fiction
    And I Should Not See The Book In The List    Should Not Save

Scenario: User Can Delete A Book
    [Documentation]    Verify that users can delete books from the library
    [Tags]    delete-book    crud
    Given I Am On The Books Library Homepage
    And I Add A New Book    Book To Delete    Delete Author    200    Fiction
    And I Add A New Book    Book To Keep    Keep Author    300    Science
    When I Click Delete On Book    Book To Delete
    And I Confirm The Deletion
    Then I Should Not See The Book In The List    Book To Delete
    And I Should See The Book In The List    Book To Keep    Keep Author    300    Science
    And I Should See The Book Count    1

Scenario: User Sees Validation Errors For Invalid Book Data
    [Documentation]    Verify that form validation works for invalid input
    [Tags]    validation    error-handling
    Given I Am On The Books Library Homepage
    When I Fill In The Book Form    ${EMPTY}    ${EMPTY}    ${EMPTY}    Fiction
    And I Submit The Book Form
    Then Verify Form Validation Error    title    Title is required
    And Verify Form Validation Error    author    Author is required
    And Verify Form Validation Error    pages    Pages must be a positive number

Scenario: User Can Clear Search And See All Books
    [Documentation]    Verify that clearing search shows all books again
    [Tags]    search    filter    clear
    Given I Am On The Books Library Homepage
    And I Add A New Book    First Book    First Author    200    Fiction
    And I Add A New Book    Second Book    Second Author    300    Science
    When I Search For Books    First
    Then I Should See The Book In The List    First Book    First Author    200    Fiction
    And I Should Not See The Book In The List    Second Book
    When I Search For Books    ${EMPTY}
    Then I Should See The Book In The List    First Book    First Author    200    Fiction
    And I Should See The Book In The List    Second Book    Second Author    300    Science

Scenario: User Can Reset Category Filter To Show All Books
    [Documentation]    Verify that resetting category filter shows all books
    [Tags]    filter    categories    reset
    Given I Am On The Books Library Homepage
    And I Add A New Book    Fiction Book    Fiction Author    200    Fiction
    And I Add A New Book    Science Book    Science Author    300    Science
    When I Filter Books By Category    Fiction
    Then I Should See The Book In The List    Fiction Book    Fiction Author    200    Fiction
    And I Should Not See The Book In The List    Science Book
    When I Filter Books By Category    All Categories
    Then I Should See The Book In The List    Fiction Book    Fiction Author    200    Fiction
    And I Should See The Book In The List    Science Book    Science Author    300    Science

Scenario: User Can Reset Favorite Filter To Show All Books
    [Documentation]    Verify that resetting favorite filter shows all books
    [Tags]    favorites    filter    reset
    Given I Am On The Books Library Homepage
    And I Add A New Book    Regular Book    Regular Author    200    Fiction
    And I Add A New Book    Favorite Book    Favorite Author    300    Science
    And I Toggle Favorite On Book    Favorite Book
    When I Filter Books By Favorites
    Then I Should See The Book In The List    Favorite Book    Favorite Author    300    Science
    And I Should Not See The Book In The List    Regular Book
    When I Show All Books
    Then I Should See The Book In The List    Favorite Book    Favorite Author    300    Science
    And I Should See The Book In The List    Regular Book    Regular Author    200    Fiction

Scenario: User Can Combine Multiple Filters
    [Documentation]    Verify that multiple filters can be applied simultaneously
    [Tags]    filter    combination    advanced
    Given I Am On The Books Library Homepage
    And I Add A New Book    Fiction Favorite    Fiction Author    200    Fiction
    And I Add A New Book    Science Regular    Science Author    300    Science
    And I Add A New Book    Fiction Regular    Another Author    250    Fiction
    And I Toggle Favorite On Book    Fiction Favorite
    When I Filter Books By Category    Fiction
    And I Filter Books By Favorites
    Then I Should See The Book In The List    Fiction Favorite    Fiction Author    200    Fiction
    And I Should Not See The Book In The List    Science Regular
    And I Should Not See The Book In The List    Fiction Regular

Scenario: User Interface Handles Large Number Of Books
    [Documentation]    Verify that the UI can handle displaying many books
    [Tags]    performance    pagination    stress
    Given I Am On The Books Library Homepage
    # Add multiple books via API for performance
    And I Have Multiple Books In The Database    20
    When I Am On The Books Library Homepage
    Then I Should See The Book Count    20
    # Verify pagination or load more functionality if implemented
    And Wait For Books To Load

Scenario: User Can Navigate Between Different Views
    [Documentation]    Verify navigation and state management between different views
    [Tags]    navigation    state-management
    Given I Am On The Books Library Homepage
    And I Add A New Book    Navigation Test    Test Author    200    Fiction
    When I Search For Books    Navigation
    Then I Should See The Book In The List    Navigation Test    Test Author    200    Fiction
    When I Filter Books By Category    Science
    Then I Should Not See The Book In The List    Navigation Test
    When I Filter Books By Category    All Categories
    And I Search For Books    ${EMPTY}
    Then I Should See The Book In The List    Navigation Test    Test Author    200    Fiction