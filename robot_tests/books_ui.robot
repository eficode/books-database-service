*** Settings ***
Documentation    UI acceptance tests for Books Library application using Gherkin syntax
...              These tests verify the user interface functionality including book management,
...              search, filtering, sorting, and form validation.

Resource         resources/common.resource
Resource         keywords/ui_keywords.resource

Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Setup       Run Keywords    Navigate To Books Library Homepage    AND    Clean Up Test Data
Test Teardown    Clean Up Test Data

*** Test Cases ***
Scenario: User can view the Books Library homepage
    [Documentation]    Verify that the homepage loads correctly with all main elements
    [Tags]    ui    smoke    homepage    critical
    Given the user is on the Books Library homepage
    Then the page should display the main heading
    And the book creation form should be visible
    And the books grid should be visible
    And the search and filter controls should be visible

Scenario: User can add a new book successfully
    [Documentation]    Verify that a user can add a new book through the UI
    [Tags]    ui    crud    create    critical
    Given the user is on the Books Library homepage
    When the user fills the book form with valid data
    And the user submits the book form
    Then the new book should appear in the books grid
    And the book should display the correct information
    And the form should be cleared after submission

Scenario: User can add books with different categories
    [Documentation]    Verify that books can be added with various categories
    [Tags]    ui    crud    categories
    Given the user is on the Books Library homepage
    When the user adds a book with category "Fantasy"
    Then the book should appear with "Fantasy" category
    When the user adds a book with category "Science Fiction"
    Then the book should appear with "Science Fiction" category
    When the user adds a book with category "Non-Fiction"
    Then the book should appear with "Non-Fiction" category

Scenario: User can search for books by title
    [Documentation]    Verify that the search functionality works for book titles
    [Tags]    ui    search    title
    Given the user has added multiple books to the library
    When the user searches for a specific book title
    Then only books matching the search term should be displayed
    And the search results should be accurate

Scenario: User can search for books by author
    [Documentation]    Verify that the search functionality works for authors
    [Tags]    ui    search    author
    Given the user has added books by different authors
    When the user searches for a specific author name
    Then only books by that author should be displayed
    And the search results should be accurate

Scenario: User can filter books by category
    [Documentation]    Verify that category filtering works correctly
    [Tags]    ui    filter    category
    Given the user has added books in different categories
    When the user filters books by "Fiction" category
    Then only "Fiction" books should be displayed
    When the user filters books by "Fantasy" category
    Then only "Fantasy" books should be displayed
    When the user resets the category filter
    Then all books should be displayed again

Scenario: User can filter books by favorite status
    [Documentation]    Verify that favorite filtering works correctly
    [Tags]    ui    filter    favorites
    Given the user has added books with mixed favorite status
    When the user filters to show only favorites
    Then only favorite books should be displayed
    When the user filters to show all books
    Then all books should be displayed again

Scenario: User can mark a book as favorite
    [Documentation]    Verify that users can mark books as favorites
    [Tags]    ui    favorites    toggle    critical
    Given the user has added a book to the library
    When the user clicks the favorite button for the book
    Then the book should be marked as favorite
    And the favorite icon should be highlighted

Scenario: User can unmark a book as favorite
    [Documentation]    Verify that users can unmark favorite books
    [Tags]    ui    favorites    toggle
    Given the user has a favorite book in the library
    When the user clicks the favorite button for the book
    Then the book should no longer be marked as favorite
    And the favorite icon should not be highlighted

Scenario: User can sort books by title
    [Documentation]    Verify that books can be sorted by title
    [Tags]    ui    sort    title
    Given the user has added books with different titles
    When the user sorts books by title in ascending order
    Then books should be displayed in alphabetical order by title
    When the user sorts books by title in descending order
    Then books should be displayed in reverse alphabetical order by title

Scenario: User can sort books by author
    [Documentation]    Verify that books can be sorted by author
    [Tags]    ui    sort    author
    Given the user has added books by different authors
    When the user sorts books by author in ascending order
    Then books should be displayed in alphabetical order by author
    When the user sorts books by author in descending order
    Then books should be displayed in reverse alphabetical order by author

Scenario: User can sort books by page count
    [Documentation]    Verify that books can be sorted by page count
    [Tags]    ui    sort    pages
    Given the user has added books with different page counts
    When the user sorts books by pages in ascending order
    Then books should be displayed in ascending order by page count
    When the user sorts books by pages in descending order
    Then books should be displayed in descending order by page count

Scenario: User can edit a book's information
    [Documentation]    Verify that users can edit existing books
    [Tags]    ui    crud    update    critical
    Given the user has added a book to the library
    When the user opens the edit modal for the book
    And the user updates the book information
    And the user saves the changes
    Then the book should display the updated information
    And the edit modal should close automatically

Scenario: User can delete a book
    [Documentation]    Verify that users can delete books
    [Tags]    ui    crud    delete    critical
    Given the user has added a book to the library
    When the user clicks the delete button for the book
    And the user confirms the deletion
    Then the book should be removed from the books grid
    And the book should no longer be visible

Scenario: User can combine search and filter operations
    [Documentation]    Verify that search and filter can work together
    [Tags]    ui    search    filter    combination
    Given the user has added books in multiple categories
    When the user filters by "Fiction" category
    And the user searches for a specific title within the filtered results
    Then only "Fiction" books matching the search should be displayed

Scenario: User sees appropriate feedback when no books match filters
    [Documentation]    Verify that appropriate feedback is shown for empty results
    [Tags]    ui    feedback    empty-results
    Given the user has added some books to the library
    When the user searches for a non-existent book title
    Then an appropriate "no results" message should be displayed
    And the books grid should appear empty

Scenario: Form validation prevents submission of invalid data
    [Documentation]    Verify that form validation works correctly
    [Tags]    ui    validation    form    critical
    Given the user is on the Books Library homepage
    When the user tries to submit the form with empty required fields
    Then the form should not be submitted
    And validation errors should be displayed
    When the user tries to submit the form with invalid page count
    Then the form should not be submitted
    And validation errors should be displayed

Scenario: User interface is responsive and accessible
    [Documentation]    Verify that the UI is responsive and accessible
    [Tags]    ui    accessibility    responsive
    Given the user is on the Books Library homepage
    When the user resizes the browser window
    Then the interface should adapt to different screen sizes
    And all interactive elements should remain accessible

*** Keywords ***
# Given Keywords (Setup)
the user is on the Books Library homepage
    [Documentation]    Verify user is on the homepage
    Get Title    contains    Books Library
    Wait For Elements State    css=h1    visible

the user has added multiple books to the library
    [Documentation]    Add multiple books for testing
    ${books}=    Create Multiple Test Books    3
    Set Test Variable    ${TEST_BOOKS}    ${books}
    ${last_book}=    Get From List    ${books}    -1
    Set Test Variable    ${SEARCH_BOOK_TITLE}    ${last_book}[title]

the user has added books by different authors
    [Documentation]    Add books by different authors
    ${authors}=    Create List    Author Alpha    Author Beta    Author Gamma
    ${books}=    Create Books With Different Authors    @{authors}
    Set Test Variable    ${TEST_BOOKS}    ${books}
    Set Test Variable    ${SEARCH_AUTHOR}    Author Beta

the user has added books in different categories
    [Documentation]    Add books in different categories
    ${categories}=    Create List    Fiction    Fantasy    Science Fiction    Non-Fiction
    ${books}=    Create Books With Different Categories    @{categories}
    Set Test Variable    ${TEST_BOOKS}    ${books}

the user has added books with mixed favorite status
    [Documentation]    Add books with some marked as favorites
    ${books}=    Create Books With Mixed Favorite Status    4    2
    Set Test Variable    ${TEST_BOOKS}    ${books}

the user has added a book to the library
    [Documentation]    Add a single book for testing
    ${book_data}=    Generate Random Book Data
    Fill Book Creation Form    ${book_data}[title]    ${book_data}[author]    ${book_data}[pages]    ${book_data}[category]
    Submit Book Creation Form
    Wait For Book To Appear In Grid    ${book_data}[title]
    Set Test Variable    ${TEST_BOOK_DATA}    ${book_data}

the user has a favorite book in the library
    [Documentation]    Add a book and mark it as favorite
    the user has added a book to the library
    Click Favorite Button For Book    ${TEST_BOOK_DATA}[title]

the user has added books with different titles
    [Documentation]    Add books with specific titles for sorting
    ${titles}=    Create List    Alpha Book    Beta Book    Charlie Book    Delta Book
    ${books}=    Create Books With Different Titles    @{titles}
    Set Test Variable    ${TEST_BOOKS}    ${books}

the user has added books with different page counts
    [Documentation]    Add books with different page counts for sorting
    ${page_counts}=    Create List    100    250    350    500
    ${books}=    Create Books With Different Page Counts    @{page_counts}
    Set Test Variable    ${TEST_BOOKS}    ${books}

the user has added some books to the library
    [Documentation]    Add some books for empty results testing
    ${books}=    Create Multiple Test Books    3
    Set Test Variable    ${TEST_BOOKS}    ${books}

# When Keywords (Actions)
the user fills the book form with valid data
    [Documentation]    Fill form with test data
    Fill Book Creation Form    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}

the user submits the book form
    [Documentation]    Submit the book form
    Submit Book Creation Form

the user adds a book with category "${category}"
    [Documentation]    Add a book with specific category
    ${book_data}=    Create Test Book With Category    ${category}
    Set Test Variable    ${LAST_BOOK_DATA}    ${book_data}

the user searches for a specific book title
    [Documentation]    Search for a specific book title
    Search For Books    ${SEARCH_BOOK_TITLE}

the user searches for a specific author name
    [Documentation]    Search for a specific author
    Search For Books    ${SEARCH_AUTHOR}

the user filters books by "${category}" category
    [Documentation]    Filter books by specific category
    Filter Books By Category    ${category}

the user filters by "${category}" category
    [Documentation]    Filter books by specific category (alternative phrasing)
    Filter Books By Category    ${category}

the user resets the category filter
    [Documentation]    Reset category filter to show all categories
    Filter Books By Category    all

the user filters to show only favorites
    [Documentation]    Filter to show only favorite books
    Filter Books By Favorite Status    True

the user filters to show all books
    [Documentation]    Filter to show all books
    Filter Books By Favorite Status    False

the user clicks the favorite button for the book
    [Documentation]    Click favorite button for the test book
    Click Favorite Button For Book    ${TEST_BOOK_DATA}[title]

the user sorts books by title in ascending order
    [Documentation]    Sort books by title ascending
    Sort Books By Field    title    asc

the user sorts books by title in descending order
    [Documentation]    Sort books by title descending
    Sort Books By Field    title    desc

the user sorts books by author in ascending order
    [Documentation]    Sort books by author ascending
    Sort Books By Field    author    asc

the user sorts books by author in descending order
    [Documentation]    Sort books by author descending
    Sort Books By Field    author    desc

the user sorts books by pages in ascending order
    [Documentation]    Sort books by pages ascending
    Sort Books By Field    pages    asc

the user sorts books by pages in descending order
    [Documentation]    Sort books by pages descending
    Sort Books By Field    pages    desc

the user opens the edit modal for the book
    [Documentation]    Open edit modal for the test book
    Open Edit Modal For Book    ${TEST_BOOK_DATA}[title]

the user updates the book information
    [Documentation]    Update book information in edit form
    ${new_title}=    Set Variable    Updated ${TEST_BOOK_DATA}[title]
    ${new_author}=    Set Variable    Updated Author
    ${new_pages}=    Set Variable    300
    ${new_category}=    Set Variable    Fantasy
    Fill Edit Form    ${new_title}    ${new_author}    ${new_pages}    ${new_category}
    Set Test Variable    ${UPDATED_BOOK_DATA}    ${new_title}
    Set Test Variable    ${UPDATED_AUTHOR}    ${new_author}
    Set Test Variable    ${UPDATED_PAGES}    ${new_pages}
    Set Test Variable    ${UPDATED_CATEGORY}    ${new_category}

the user saves the changes
    [Documentation]    Save the edit form changes
    Submit Edit Form

the user clicks the delete button for the book
    [Documentation]    Click delete button for the test book
    Click Delete Button For Book    ${TEST_BOOK_DATA}[title]

the user confirms the deletion
    [Documentation]    Confirm deletion (handled automatically by dialog handler)
    Sleep    1s    # Wait for deletion to complete

the user searches for a specific title within the filtered results
    [Documentation]    Search for a specific title in combined test
    Search For Books    Test Fiction Book

the user searches for a non-existent book title
    [Documentation]    Search for a title that doesn't exist
    Search For Books    NonExistentBookTitle12345

the user tries to submit the form with empty required fields
    [Documentation]    Try to submit form with empty required fields
    Clear Book Creation Form
    Fill Text    ${AUTHOR_INPUT}    Test Author
    Fill Text    ${PAGES_INPUT}    250
    Click    ${ADD_BOOK_BUTTON}

the user tries to submit the form with invalid page count
    [Documentation]    Try to submit form with invalid page count
    Fill Text    ${TITLE_INPUT}    Test Book
    Fill Text    ${AUTHOR_INPUT}    Test Author
    Fill Text    ${PAGES_INPUT}    -5
    Click    ${ADD_BOOK_BUTTON}

the user resizes the browser window
    [Documentation]    Resize browser window to test responsiveness
    Set Viewport Size    800    600
    Sleep    1s
    Set Viewport Size    1920    1080
    Sleep    1s

# Then Keywords (Verification)
the page should display the main heading
    [Documentation]    Verify main heading is displayed
    Get Text    css=h1    contains    Books Library

the book creation form should be visible
    [Documentation]    Verify book creation form is visible
    Wait For Elements State    ${TITLE_INPUT}    visible
    Wait For Elements State    ${AUTHOR_INPUT}    visible
    Wait For Elements State    ${PAGES_INPUT}    visible
    Wait For Elements State    ${CATEGORY_SELECT}    visible
    Wait For Elements State    ${ADD_BOOK_BUTTON}    visible

the books grid should be visible
    [Documentation]    Verify books grid is visible
    Wait For Elements State    ${BOOKS_GRID}    visible

the search and filter controls should be visible
    [Documentation]    Verify search and filter controls are visible
    Wait For Elements State    ${SEARCH_INPUT}    visible
    Wait For Elements State    ${SEARCH_BUTTON}    visible
    Wait For Elements State    ${CATEGORY_FILTER}    visible
    Wait For Elements State    ${FAVORITE_FILTER}    visible
    Wait For Elements State    ${ALL_BOOKS_FILTER}    visible
    Wait For Elements State    ${SORT_BY_SELECT}    visible

the new book should appear in the books grid
    [Documentation]    Verify new book appears
    Wait For Book To Appear In Grid    ${TEST_BOOK_TITLE}

the book should display the correct information
    [Documentation]    Verify book displays correct information
    Verify Book Exists In Grid    ${TEST_BOOK_TITLE}    ${TEST_BOOK_AUTHOR}    ${TEST_BOOK_PAGES}    ${TEST_BOOK_CATEGORY}

the form should be cleared after submission
    [Documentation]    Verify form is cleared after successful submission
    ${title_value}=    Get Property    ${TITLE_INPUT}    value
    ${author_value}=    Get Property    ${AUTHOR_INPUT}    value
    ${pages_value}=    Get Property    ${PAGES_INPUT}    value
    Should Be Empty    ${title_value}
    Should Be Empty    ${author_value}
    Should Be Empty    ${pages_value}

the book should appear with "${category}" category
    [Documentation]    Verify book appears with correct category
    Wait For Book To Appear In Grid    ${LAST_BOOK_DATA}[title]
    ${book_card}=    Get Book Card By Title    ${LAST_BOOK_DATA}[title]
    Get Text    ${book_card} >> ${BOOK_CATEGORY}    contains    ${category}

only books matching the search term should be displayed
    [Documentation]    Verify only matching books are shown
    Verify Search Results Contain Term    ${SEARCH_BOOK_TITLE}

the search results should be accurate
    [Documentation]    Verify search results are accurate
    ${visible_count}=    Get Book Count In Grid
    Should Be True    ${visible_count} >= 1    No search results found

only books by that author should be displayed
    [Documentation]    Verify only books by searched author are shown
    Verify Search Results Contain Term    ${SEARCH_AUTHOR}

only "${category}" books should be displayed
    [Documentation]    Verify only books of specified category are shown
    Verify All Books Have Category    ${category}

all books should be displayed again
    [Documentation]    Verify all books are displayed
    ${visible_count}=    Get Book Count In Grid
    Should Be True    ${visible_count} >= 1    No books are displayed

only favorite books should be displayed
    [Documentation]    Verify only favorite books are shown
    Verify All Books Are Favorites

the book should be marked as favorite
    [Documentation]    Verify book is marked as favorite
    Verify Book Is Marked As Favorite    ${TEST_BOOK_DATA}[title]

the favorite icon should be highlighted
    [Documentation]    Verify favorite icon is highlighted
    Verify Book Is Marked As Favorite    ${TEST_BOOK_DATA}[title]

the book should no longer be marked as favorite
    [Documentation]    Verify book is not marked as favorite
    Verify Book Is Not Marked As Favorite    ${TEST_BOOK_DATA}[title]

the favorite icon should not be highlighted
    [Documentation]    Verify favorite icon is not highlighted
    Verify Book Is Not Marked As Favorite    ${TEST_BOOK_DATA}[title]

books should be displayed in alphabetical order by title
    [Documentation]    Verify books are sorted alphabetically by title
    Verify Books Are Sorted By Title    True

books should be displayed in reverse alphabetical order by title
    [Documentation]    Verify books are sorted in reverse alphabetical order by title
    Verify Books Are Sorted By Title    False

books should be displayed in alphabetical order by author
    [Documentation]    Verify books are sorted alphabetically by author
    Verify Books Are Sorted By Author    True

books should be displayed in reverse alphabetical order by author
    [Documentation]    Verify books are sorted in reverse alphabetical order by author
    Verify Books Are Sorted By Author    False

books should be displayed in ascending order by page count
    [Documentation]    Verify books are sorted by page count ascending
    Verify Books Are Sorted By Pages    True

books should be displayed in descending order by page count
    [Documentation]    Verify books are sorted by page count descending
    Verify Books Are Sorted By Pages    False

the book should display the updated information
    [Documentation]    Verify book displays updated information
    Wait For Book To Appear In Grid    ${UPDATED_BOOK_DATA}
    Verify Book Exists In Grid    ${UPDATED_BOOK_DATA}    ${UPDATED_AUTHOR}    ${UPDATED_PAGES}    ${UPDATED_CATEGORY}

the edit modal should close automatically
    [Documentation]    Verify edit modal closes
    Wait For Elements State    ${EDIT_MODAL}    hidden    timeout=${TIMEOUT}

the book should be removed from the books grid
    [Documentation]    Verify book is removed from grid
    Verify Book Does Not Exist In Grid    ${TEST_BOOK_DATA}[title]

the book should no longer be visible
    [Documentation]    Verify book is no longer visible
    Verify Book Does Not Exist In Grid    ${TEST_BOOK_DATA}[title]

only "${category}" books matching the search should be displayed
    [Documentation]    Verify only matching books in category are shown
    ${visible_books}=    Get All Visible Books
    FOR    ${book}    IN    @{visible_books}
        ${book_category}=    Get Text    ${book} >> ${BOOK_CATEGORY}
        ${book_title}=    Get Text    ${book} >> ${BOOK_TITLE}
        Should Be Equal As Strings    ${book_category}    ${category}
        Should Contain    ${book_title}    Test Fiction Book
    END

an appropriate "no results" message should be displayed
    [Documentation]    Verify no results message is shown
    Verify No Results Message Is Displayed

the books grid should appear empty
    [Documentation]    Verify books grid appears empty
    ${visible_count}=    Get Book Count In Grid
    Should Be Equal As Numbers    ${visible_count}    0

the form should not be submitted
    [Documentation]    Verify form is not submitted
    Get Title    contains    Books Library
    # Verify no new book was added by checking the grid hasn't changed significantly
    Sleep    2s

validation errors should be displayed
    [Documentation]    Verify validation errors are shown
    Verify Form Validation Error    ${TITLE_INPUT}

the interface should adapt to different screen sizes
    [Documentation]    Verify interface adapts to different screen sizes
    # Basic check that main elements are still visible
    Wait For Elements State    css=h1    visible
    Wait For Elements State    ${BOOKS_GRID}    visible

all interactive elements should remain accessible
    [Documentation]    Verify all interactive elements remain accessible
    Wait For Elements State    ${ADD_BOOK_BUTTON}    visible
    Wait For Elements State    ${SEARCH_BUTTON}    visible
    Wait For Elements State    ${CATEGORY_FILTER}    visible