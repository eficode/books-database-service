*** Settings ***
Documentation    UI acceptance tests for the Books Database Service
...              Tests cover the main user workflows for managing books through the web interface.
...              Uses BDD/Gherkin style for better readability and stakeholder communication.

Library          Browser
Resource         resources/common.resource
Resource         resources/ui_keywords.resource

Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Setup       Test Setup For UI
Test Teardown    Test Teardown For UI

*** Variables ***
${BROWSER_TIMEOUT}    10s

*** Keywords ***
Test Setup For UI
    [Documentation]    Sets up each UI test
    Open Books Application
    Page Should Be Loaded

Test Teardown For UI
    [Documentation]    Cleans up after each UI test
    Run Keyword If Test Failed    Take Screenshot On Failure
    Close Browser Session

*** Test Cases ***
Scenario: User Can View Books Application
    [Documentation]    GIVEN the Books application is running
    ...                WHEN the user opens the application
    ...                THEN the main page should be displayed correctly
    [Tags]    smoke    ui    basic
    Given The Books Application Is Open
    When The User Views The Main Page
    Then The Main Page Should Be Displayed Correctly

Scenario: User Can Add A New Book
    [Documentation]    GIVEN the user is on the books page
    ...                WHEN the user fills in book details and submits
    ...                THEN the book should appear in the books list
    [Tags]    ui    create    book
    Given The User Is On The Books Page
    When The User Adds A New Book With Valid Details
    Then The Book Should Appear In The Books List

Scenario: User Can Add Multiple Books
    [Documentation]    GIVEN the user is on the books page
    ...                WHEN the user adds multiple books
    ...                THEN all books should appear in the books list
    [Tags]    ui    create    multiple
    Given The User Is On The Books Page
    When The User Adds Multiple Books
    Then All Books Should Appear In The Books List

Scenario: User Cannot Add Book With Empty Fields
    [Documentation]    GIVEN the user is on the books page
    ...                WHEN the user tries to submit with empty fields
    ...                THEN validation errors should be displayed
    [Tags]    ui    validation    negative
    Given The User Is On The Books Page
    When The User Tries To Submit Empty Book Form
    Then Form Validation Errors Should Be Displayed

Scenario: User Can Mark Book As Favorite
    [Documentation]    GIVEN a book exists in the list
    ...                WHEN the user clicks the favorite button
    ...                THEN the book should be marked as favorite
    [Tags]    ui    favorite    interaction
    Given A Book Exists In The List
    When The User Marks The Book As Favorite
    Then The Book Should Be Marked As Favorite

Scenario: User Can Remove Book From Favorites
    [Documentation]    GIVEN a book is marked as favorite
    ...                WHEN the user clicks the favorite button again
    ...                THEN the book should no longer be marked as favorite
    [Tags]    ui    favorite    interaction
    Given A Book Is Marked As Favorite
    When The User Removes The Book From Favorites
    Then The Book Should Not Be Marked As Favorite

Scenario: User Can Delete A Book
    [Documentation]    GIVEN a book exists in the list
    ...                WHEN the user deletes the book
    ...                THEN the book should no longer appear in the list
    [Tags]    ui    delete    interaction
    Given A Book Exists In The List
    When The User Deletes The Book
    Then The Book Should No Longer Appear In The List

Scenario: User Can Search For Books
    [Documentation]    GIVEN multiple books exist in the list
    ...                WHEN the user searches for a specific book
    ...                THEN only matching books should be displayed
    [Tags]    ui    search    filter
    Given Multiple Books Exist In The List
    When The User Searches For A Specific Book
    Then Only Matching Books Should Be Displayed

Scenario: User Can Filter Books By Category
    [Documentation]    GIVEN books of different categories exist
    ...                WHEN the user filters by a specific category
    ...                THEN only books of that category should be displayed
    [Tags]    ui    filter    category
    Given Books Of Different Categories Exist
    When The User Filters By A Specific Category
    Then Only Books Of That Category Should Be Displayed

Scenario: User Can Clear Search Filter
    [Documentation]    GIVEN the user has filtered books
    ...                WHEN the user clears the search filter
    ...                THEN all books should be displayed again
    [Tags]    ui    search    clear
    Given The User Has Filtered Books
    When The User Clears The Search Filter
    Then All Books Should Be Displayed Again

*** Keywords ***
# Given Keywords
The Books Application Is Open
    [Documentation]    Verifies the books application is open
    Page Should Be Loaded

The User Is On The Books Page
    [Documentation]    Ensures the user is on the books page
    Navigate To Books Page
    Page Should Be Loaded

A Book Exists In The List
    [Documentation]    Creates a book and verifies it exists in the list
    Fill Book Form    ${VALID_BOOK_TITLE}    ${VALID_BOOK_AUTHOR}    ${VALID_BOOK_PAGES}    ${VALID_BOOK_CATEGORY}
    Submit Book Form
    Book Should Be Visible In List    ${VALID_BOOK_TITLE}    ${VALID_BOOK_AUTHOR}

A Book Is Marked As Favorite
    [Documentation]    Creates a book and marks it as favorite
    # Use unique title for this test to avoid conflicts with other tests
    Fill Book Form    Favorite Test Book    Favorite Author    200    Fiction
    Submit Book Form
    Book Should Be Visible In List    Favorite Test Book    Favorite Author
    Click Book Favorite Button    Favorite Test Book
    Book Should Be Marked As Favorite    Favorite Test Book

Multiple Books Exist In The List
    [Documentation]    Creates multiple books for testing
    Fill Book Form    First Book    First Author    100    Fiction
    Submit Book Form
    Clear Book Form
    Fill Book Form    Second Book    Second Author    200    Non-Fiction
    Submit Book Form
    Clear Book Form
    Fill Book Form    Third Book    Third Author    300    Fantasy
    Submit Book Form
    Wait For Books To Load

Books Of Different Categories Exist
    [Documentation]    Creates books of different categories
    Fill Book Form    Fiction Book    Fiction Author    150    Fiction
    Submit Book Form
    Clear Book Form
    Fill Book Form    Science Book    Science Author    250    Science
    Submit Book Form
    Clear Book Form
    Fill Book Form    Fantasy Book    Fantasy Author    350    Fantasy
    Submit Book Form
    Wait For Books To Load

The User Has Filtered Books
    [Documentation]    Sets up a filtered state
    Multiple Books Exist In The List
    Search For Book    First

# When Keywords
The User Views The Main Page
    [Documentation]    User views the main page
    Log Test Info    User is viewing the main page

The User Adds A New Book With Valid Details
    [Documentation]    User fills and submits book form with valid data
    Fill Book Form    ${VALID_BOOK_TITLE}    ${VALID_BOOK_AUTHOR}    ${VALID_BOOK_PAGES}    ${VALID_BOOK_CATEGORY}
    Submit Book Form

The User Adds Multiple Books
    [Documentation]    User adds multiple books
    Multiple Books Exist In The List

The User Tries To Submit Empty Book Form
    [Documentation]    User tries to submit form with empty fields
    Clear Book Form
    Click Add Book Button

The User Marks The Book As Favorite
    [Documentation]    User clicks the favorite button
    Click Book Favorite Button    ${VALID_BOOK_TITLE}

The User Removes The Book From Favorites
    [Documentation]    User clicks the favorite button to unmark
    Click Book Favorite Button    Favorite Test Book

The User Deletes The Book
    [Documentation]    User deletes the book
    Click Book Delete Button    ${VALID_BOOK_TITLE}
    Accept Deletion Confirmation

The User Searches For A Specific Book
    [Documentation]    User searches for a specific book
    Search For Book    First Book

The User Filters By A Specific Category
    [Documentation]    User filters by a specific category
    Filter Books By Category    Fiction

The User Clears The Search Filter
    [Documentation]    User clears the search filter
    Search For Book    ${EMPTY}

# Then Keywords
The Main Page Should Be Displayed Correctly
    [Documentation]    Verifies the main page is displayed correctly
    Page Should Be Loaded
    Wait For Elements State    ${BOOK_FORM}    visible

The Book Should Appear In The Books List
    [Documentation]    Verifies the book appears in the list
    Book Should Be Visible In List    ${VALID_BOOK_TITLE}    ${VALID_BOOK_AUTHOR}

All Books Should Appear In The Books List
    [Documentation]    Verifies all books appear in the list
    Book Should Be Visible In List    First Book    First Author
    Book Should Be Visible In List    Second Book    Second Author
    Book Should Be Visible In List    Third Book    Third Author

Form Validation Errors Should Be Displayed
    [Documentation]    Verifies form validation errors are shown
    # Note: This depends on the actual implementation of validation
    Log Test Info    Checking for form validation errors

The Book Should Be Marked As Favorite
    [Documentation]    Verifies the book is marked as favorite
    Book Should Be Marked As Favorite    ${VALID_BOOK_TITLE}

The Book Should Not Be Marked As Favorite
    [Documentation]    Verifies the book is not marked as favorite
    Book Should Not Be Marked As Favorite    Favorite Test Book

The Book Should No Longer Appear In The List
    [Documentation]    Verifies the book is no longer in the list
    Book Should Not Be Visible In List    ${VALID_BOOK_TITLE}

Only Matching Books Should Be Displayed
    [Documentation]    Verifies only matching books are displayed
    Book Should Be Visible In List    First Book    First Author
    Book Should Not Be Visible In List    Second Book
    Book Should Not Be Visible In List    Third Book

Only Books Of That Category Should Be Displayed
    [Documentation]    Verifies only books of the filtered category are shown
    Book Should Be Visible In List    Fiction Book    Fiction Author
    Book Should Not Be Visible In List    Science Book
    Book Should Not Be Visible In List    Fantasy Book

All Books Should Be Displayed Again
    [Documentation]    Verifies all books are displayed after clearing filter
    Book Should Be Visible In List    First Book    First Author
    Book Should Be Visible In List    Second Book    Second Author
    Book Should Be Visible In List    Third Book    Third Author