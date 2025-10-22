*** Settings ***
Documentation     Books Library API Acceptance Tests
...               This test suite verifies the REST API functionality of the Books Library
...               using RequestsLibrary with Gherkin-style BDD syntax

Resource          resources/common.resource
Resource          resources/api_keywords.resource

Suite Setup       Suite Setup For API Tests
Suite Teardown    Suite Teardown For API Tests
Test Setup        Test Setup For API Tests

Default Tags      api    acceptance    books


*** Variables ***
${VALID_BOOK_TITLE}      Test Book
${VALID_BOOK_AUTHOR}     Test Author
${VALID_BOOK_PAGES}      ${250}


*** Test Cases ***
Scenario: API Can Create A New Book
    [Documentation]    Verify that the API can successfully create a new book
    [Tags]    crud    create    critical
    Given the API is accessible
    When a POST request is sent to create a book with title "The Catcher in the Rye" author "J.D. Salinger" pages "234" category "Fiction"
    Then the response status should be successful
    And the response should contain the book data
    And the book should exist in the database

Scenario: API Returns All Books
    [Documentation]    Verify that the API returns all books in the database
    [Tags]    crud    read
    Given the API is accessible
    And multiple books exist in the database
    When a GET request is sent to retrieve all books
    Then the response status should be "200"
    And the response should contain a list of books
    And the list should contain all created books

Scenario: API Can Retrieve A Specific Book By ID
    [Documentation]    Verify that the API can retrieve a specific book by its ID
    [Tags]    crud    read
    Given the API is accessible
    And a book exists in the database
    When a GET request is sent to retrieve the book by ID
    Then the response status should be "200"
    And the response should contain the correct book details

Scenario: API Returns 404 For Non-Existent Book
    [Documentation]    Verify that the API returns 404 when requesting a non-existent book
    [Tags]    crud    read    negative
    Given the API is accessible
    When a GET request is sent to retrieve a book with ID "99999"
    Then the response status should be "404"
    And the response should contain error message "Book not found"

Scenario: API Can Update An Existing Book
    [Documentation]    Verify that the API can update an existing book's information
    [Tags]    crud    update
    Given the API is accessible
    And a book exists in the database
    When a PUT request is sent to update the book with title "Updated Title" author "Updated Author" pages "500" category "Non-Fiction"
    Then the response status should be successful
    And the response should contain the updated book data
    And the book should be updated in the database

Scenario: API Returns 404 When Updating Non-Existent Book
    [Documentation]    Verify that the API returns 404 when updating a non-existent book
    [Tags]    crud    update    negative
    Given the API is accessible
    When a PUT request is sent to update book "99999" with title "Test" author "Test" pages "100" category "Fiction"
    Then the response status should be "404"
    And the response should contain error message "Book not found"

Scenario: API Can Delete A Book
    [Documentation]    Verify that the API can delete a book from the database
    [Tags]    crud    delete
    Given the API is accessible
    And a book exists in the database
    When a DELETE request is sent to delete the book
    Then the response status should be successful
    And the response should contain confirmation message
    And the book should not exist in the database

Scenario: API Returns 404 When Deleting Non-Existent Book
    [Documentation]    Verify that the API returns 404 when deleting a non-existent book
    [Tags]    crud    delete    negative
    Given the API is accessible
    When a DELETE request is sent to delete book with ID "99999"
    Then the response status should be "404"
    And the response should contain error message "Book not found"

Scenario: API Can Toggle Book Favorite Status To True
    [Documentation]    Verify that the API can mark a book as favorite
    [Tags]    favorite
    Given the API is accessible
    And a non-favorite book exists in the database
    When a PATCH request is sent to set favorite status to "True"
    Then the response status should be successful
    And the book should be marked as favorite in the database

Scenario: API Can Toggle Book Favorite Status To False
    [Documentation]    Verify that the API can unmark a book as favorite
    [Tags]    favorite
    Given the API is accessible
    And a favorite book exists in the database
    When a PATCH request is sent to set favorite status to "False"
    Then the response status should be successful
    And the book should not be marked as favorite in the database

Scenario: API Returns 404 When Toggling Favorite For Non-Existent Book
    [Documentation]    Verify that the API returns 404 when toggling favorite for non-existent book
    [Tags]    favorite    negative
    Given the API is accessible
    When a PATCH request is sent to toggle favorite for book "99999"
    Then the response status should be "404"
    And the response should contain error message "Book not found"

Scenario: API Creates Book With Default Category
    [Documentation]    Verify that the API sets default category when not provided
    [Tags]    create    default
    Given the API is accessible
    When a POST request is sent to create a book without category
    Then the response status should be successful
    And the book should have category "Fiction"

Scenario: API Creates Book With Default Favorite Status
    [Documentation]    Verify that the API sets default favorite status to false
    [Tags]    create    default
    Given the API is accessible
    When a POST request is sent to create a book without favorite status
    Then the response status should be successful
    And the book should have favorite status "False"

Scenario: API Can Create Books With Different Categories
    [Documentation]    Verify that the API accepts various book categories
    [Tags]    create    categories
    Given the API is accessible
    When books are created with categories "Fiction", "Non-Fiction", "Fantasy", "Science Fiction", "Mystery"
    Then all books should be created successfully
    And each book should have its assigned category

Scenario: API Can Handle Multiple Concurrent Create Requests
    [Documentation]    Verify that the API can handle multiple book creation requests
    [Tags]    create    performance
    Given the API is accessible
    When "5" books are created via concurrent API calls
    Then all create requests should be successful
    And all books should exist in the database

Scenario: API Created Book Has All Required Fields
    [Documentation]    Verify that created book contains all required fields
    [Tags]    create    validation
    Given the API is accessible
    When a POST request is sent to create a complete book
    Then the response status should be successful
    And the book should have fields "id", "title", "author", "pages", "category", "favorite"

Scenario: API Update Modifies Only Specified Fields
    [Documentation]    Verify that API update changes only the provided fields
    [Tags]    update    validation
    Given the API is accessible
    And a book exists with specific data
    When a PUT request is sent to change only the title
    Then the response status should be successful
    And only the title should be changed
    And other fields should remain unchanged

Scenario: API Deletes Multiple Books Sequentially
    [Documentation]    Verify that multiple books can be deleted one after another
    [Tags]    delete
    Given the API is accessible
    And "3" books exist in the database
    When all books are deleted sequentially
    Then all delete requests should be successful
    And no books should remain in the database

Scenario: API Returns Empty List When No Books Exist
    [Documentation]    Verify that API returns empty list when database is empty
    [Tags]    read    empty
    Given the API is accessible
    And the database is empty
    When a GET request is sent to retrieve all books
    Then the response status should be "200"
    And the response should be an empty list

Scenario: API Accepts Zero Pages
    [Documentation]    Verify that API currently accepts page count of 0 (no validation for positive integer)
    [Tags]    create    validation
    Given the API is accessible
    When a POST request is sent to create a book with pages "0"
    Then the response status should be successful

Scenario: API Requires Title Field For Book Creation
    [Documentation]    Verify that title is a required field
    [Tags]    create    validation    negative
    Given the API is accessible
    When a POST request is sent to create a book without title
    Then the response status should indicate validation error

Scenario: API Requires Author Field For Book Creation
    [Documentation]    Verify that author is a required field
    [Tags]    create    validation    negative
    Given the API is accessible
    When a POST request is sent to create a book without author
    Then the response status should indicate validation error

Scenario: API Response Time For Book Creation Is Acceptable
    [Documentation]    Verify that book creation response time is under threshold
    [Tags]    performance
    Given the API is accessible
    When a POST request is sent to create a book
    Then the response time should be less than "2" seconds

Scenario: API Maintains Data Integrity After Updates
    [Documentation]    Verify that updating a book doesn't affect other books
    [Tags]    update    integrity
    Given the API is accessible
    And "2" books exist in the database
    When one book is updated
    Then the updated book should have new data
    And other books should remain unchanged


*** Keywords ***
Suite Setup For API Tests
    [Documentation]    Setup actions before running the API test suite
    Log    Starting Books Library API Test Suite
    Start Docker Environment
    Clean Up Test Data

Suite Teardown For API Tests
    [Documentation]    Cleanup actions after running the API test suite
    Log    Finishing Books Library API Test Suite
    Stop Docker Environment

Test Setup For API Tests
    [Documentation]    Setup actions before each API test
    Clean Up Test Data

# Given Keywords
The API is accessible
    [Documentation]    Verify that the API is running and accessible
    Application Should Be Running

A book exists in the database
    [Documentation]    Create a test book in the database
    ${response}=    API Create Book    ${VALID_BOOK_TITLE}    ${VALID_BOOK_AUTHOR}    ${VALID_BOOK_PAGES}    Fiction
    API Response Should Be Successful    ${response}
    ${book_id}=    Get Book ID From Response    ${response}
    Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}
    ${book}=    Get Book From Response    ${response}
    Set Test Variable    ${CREATED_BOOK}    ${book}

A non-favorite book exists in the database
    [Documentation]    Create a non-favorite book
    ${response}=    API Create Book    ${VALID_BOOK_TITLE}    ${VALID_BOOK_AUTHOR}    ${VALID_BOOK_PAGES}    Fiction    False
    API Response Should Be Successful    ${response}
    ${book_id}=    Get Book ID From Response    ${response}
    Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}

A favorite book exists in the database
    [Documentation]    Create a favorite book
    ${response}=    API Create Book    ${VALID_BOOK_TITLE}    ${VALID_BOOK_AUTHOR}    ${VALID_BOOK_PAGES}    Fiction    False
    API Response Should Be Successful    ${response}
    ${book_id}=    Get Book ID From Response    ${response}
    ${toggle_response}=    API Toggle Book Favorite    ${book_id}    True
    API Response Should Be Successful    ${toggle_response}
    Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}

Multiple books exist in the database
    [Documentation]    Create multiple test books
    ${book_ids}=    Create Multiple Books Via API    3
    Set Test Variable    ${CREATED_BOOK_IDS}    ${book_ids}

A book exists with specific data
    [Documentation]    Create a book with specific known data
    ${response}=    API Create Book    Original Title    Original Author    100    Fiction    False
    API Response Should Be Successful    ${response}
    ${book}=    Get Book From Response    ${response}
    Set Test Variable    ${ORIGINAL_BOOK}    ${book}

"${count}" books exist in the database
    [Documentation]    Create specified number of books
    ${book_ids}=    Create Multiple Books Via API    ${count}
    Set Test Variable    ${CREATED_BOOK_IDS}    ${book_ids}

The database is empty
    [Documentation]    Ensure database has no books
    Clean Up Test Data

# When Keywords
A POST request is sent to create a book with title "${title}" author "${author}" pages "${pages}" category "${category}"
    [Documentation]    Send POST request to create a book
    ${response}=    API Create Book    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${API_RESPONSE}    ${response}
    ${status_ok}=    Run Keyword And Return Status    API Response Should Be Successful    ${response}
    IF    ${status_ok}
        ${book_id}=    Get Book ID From Response    ${response}
        Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}
    END

A GET request is sent to retrieve all books
    [Documentation]    Send GET request to retrieve all books
    ${response}=    GET    ${API_URL}    expected_status=any
    Set Test Variable    ${API_RESPONSE}    ${response}

A GET request is sent to retrieve the book by ID
    [Documentation]    Send GET request for specific book
    ${response}=    API Get Book By ID    ${CREATED_BOOK_ID}
    Set Test Variable    ${API_RESPONSE}    ${response}

A GET request is sent to retrieve a book with ID "${book_id}"
    [Documentation]    Send GET request for specific book ID
    ${response}=    API Get Book By ID    ${book_id}
    Set Test Variable    ${API_RESPONSE}    ${response}

A PUT request is sent to update the book with title "${title}" author "${author}" pages "${pages}" category "${category}"
    [Documentation]    Send PUT request to update book
    ${response}=    API Update Book    ${CREATED_BOOK_ID}    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${UPDATED_TITLE}    ${title}
    Set Test Variable    ${UPDATED_AUTHOR}    ${author}
    Set Test Variable    ${UPDATED_PAGES}    ${pages}
    Set Test Variable    ${UPDATED_CATEGORY}    ${category}

A PUT request is sent to update book "${book_id}" with title "${title}" author "${author}" pages "${pages}" category "${category}"
    [Documentation]    Send PUT request to update specific book ID
    ${response}=    API Update Book    ${book_id}    ${title}    ${author}    ${pages}    ${category}
    Set Test Variable    ${API_RESPONSE}    ${response}

A DELETE request is sent to delete the book
    [Documentation]    Send DELETE request for created book
    ${response}=    API Delete Book    ${CREATED_BOOK_ID}
    Set Test Variable    ${API_RESPONSE}    ${response}

A DELETE request is sent to delete book with ID "${book_id}"
    [Documentation]    Send DELETE request for specific book ID
    ${response}=    API Delete Book    ${book_id}
    Set Test Variable    ${API_RESPONSE}    ${response}

A PATCH request is sent to set favorite status to "${favorite}"
    [Documentation]    Send PATCH request to toggle favorite
    ${response}=    API Toggle Book Favorite    ${CREATED_BOOK_ID}    ${favorite}
    Set Test Variable    ${API_RESPONSE}    ${response}

A PATCH request is sent to toggle favorite for book "${book_id}"
    [Documentation]    Send PATCH request for specific book ID
    ${response}=    API Toggle Book Favorite    ${book_id}    True
    Set Test Variable    ${API_RESPONSE}    ${response}

A POST request is sent to create a book without category
    [Documentation]    Create book without specifying category
    ${book_data}=    Create Dictionary    title=Test Book    author=Test Author    pages=${200}
    ${response}=    POST    ${API_URL}    json=${book_data}    expected_status=any
    Set Test Variable    ${API_RESPONSE}    ${response}
    ${status_ok}=    Run Keyword And Return Status    API Response Should Be Successful    ${response}
    IF    ${status_ok}
        ${book_id}=    Get Book ID From Response    ${response}
        Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}
    END

A POST request is sent to create a book without favorite status
    [Documentation]    Create book without specifying favorite status
    ${response}=    API Create Book    Test Book    Test Author    200    Fiction
    Set Test Variable    ${API_RESPONSE}    ${response}
    ${status_ok}=    Run Keyword And Return Status    API Response Should Be Successful    ${response}
    IF    ${status_ok}
        ${book_id}=    Get Book ID From Response    ${response}
        Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}
    END

Books are created with categories "${cat1}", "${cat2}", "${cat3}", "${cat4}", "${cat5}"
    [Documentation]    Create books with different categories
    ${categories}=    Create List    ${cat1}    ${cat2}    ${cat3}    ${cat4}    ${cat5}
    ${responses}=    Create List
    FOR    ${category}    IN    @{categories}
        ${response}=    API Create Book    Book-${category}    Author    200    ${category}
        Append To List    ${responses}    ${response}
    END
    Set Test Variable    ${API_RESPONSES}    ${responses}
    Set Test Variable    ${CREATED_CATEGORIES}    ${categories}

"${count}" books are created via concurrent API calls
    [Documentation]    Create multiple books
    ${book_ids}=    Create Multiple Books Via API    ${count}
    Set Test Variable    ${CREATED_BOOK_IDS}    ${book_ids}

A POST request is sent to create a complete book
    [Documentation]    Create book with all fields
    ${response}=    API Create Book    Complete Book    Complete Author    300    Fiction    False
    Set Test Variable    ${API_RESPONSE}    ${response}
    ${status_ok}=    Run Keyword And Return Status    API Response Should Be Successful    ${response}
    IF    ${status_ok}
        ${book_id}=    Get Book ID From Response    ${response}
        Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}
    END

A PUT request is sent to change only the title
    [Documentation]    Update only the title field
    ${book}=    Set Variable    ${ORIGINAL_BOOK}
    ${response}=    API Update Book    ${book}[id]    New Title    ${book}[author]    ${book}[pages]    ${book}[category]
    Set Test Variable    ${API_RESPONSE}    ${response}

All books are deleted sequentially
    [Documentation]    Delete all created books
    ${responses}=    Create List
    FOR    ${book_id}    IN    @{CREATED_BOOK_IDS}
        ${response}=    API Delete Book    ${book_id}
        Append To List    ${responses}    ${response}
    END
    Set Test Variable    ${DELETE_RESPONSES}    ${responses}

A POST request is sent to create a book with pages "${pages}"
    [Documentation]    Create book with specific page count
    ${book_data}=    Create Dictionary    title=Test    author=Test    pages=${pages}    category=Fiction
    ${response}=    POST    ${API_URL}    json=${book_data}    expected_status=any
    Set Test Variable    ${API_RESPONSE}    ${response}

A POST request is sent to create a book without title
    [Documentation]    Create book without title field
    ${book_data}=    Create Dictionary    author=Test Author    pages=${200}    category=Fiction
    ${response}=    POST    ${API_URL}    json=${book_data}    expected_status=any
    Set Test Variable    ${API_RESPONSE}    ${response}

A POST request is sent to create a book without author
    [Documentation]    Create book without author field
    ${book_data}=    Create Dictionary    title=Test Book    pages=${200}    category=Fiction
    ${response}=    POST    ${API_URL}    json=${book_data}    expected_status=any
    Set Test Variable    ${API_RESPONSE}    ${response}

A POST request is sent to create a book
    [Documentation]    Create a test book and measure time
    ${start_time}=    Get Time    epoch
    ${response}=    API Create Book    Test Book    Test Author    200    Fiction
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    ${end_time} - ${start_time}
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${RESPONSE_TIME}    ${elapsed}
    ${status_ok}=    Run Keyword And Return Status    API Response Should Be Successful    ${response}
    IF    ${status_ok}
        ${book_id}=    Get Book ID From Response    ${response}
        Set Test Variable    ${CREATED_BOOK_ID}    ${book_id}
    END

One book is updated
    [Documentation]    Update one of the created books
    ${book_id}=    Set Variable    ${CREATED_BOOK_IDS}[0]
    ${response}=    API Update Book    ${book_id}    Updated Book    Updated Author    999    Non-Fiction
    Set Test Variable    ${API_RESPONSE}    ${response}
    Set Test Variable    ${UPDATED_BOOK_ID}    ${book_id}

# Then Keywords
The response status should be successful
    [Documentation]    Verify response has successful status
    API Response Should Be Successful    ${API_RESPONSE}

The response should contain the book data
    [Documentation]    Verify response contains book data
    ${book}=    Get Book From Response    ${API_RESPONSE}
    Should Not Be Empty    ${book}

The book should exist in the database
    [Documentation]    Verify book exists in database
    ${book}=    Book Should Exist In Database    ${CREATED_BOOK_ID}
    Should Not Be Empty    ${book}

The response status should be "${status}"
    [Documentation]    Verify specific response status
    API Response Should Have Status    ${API_RESPONSE}    ${status}

The response should contain a list of books
    [Documentation]    Verify response is a list
    ${books}=    Set Variable    ${API_RESPONSE.json()}
    Should Be True    isinstance(${books}, list)

The list should contain all created books
    [Documentation]    Verify all created books are in the list
    ${books}=    Set Variable    ${API_RESPONSE.json()}
    ${actual_count}=    Get Length    ${books}
    ${expected_count}=    Get Length    ${CREATED_BOOK_IDS}
    Should Be True    ${actual_count} >= ${expected_count}

The response should contain the correct book details
    [Documentation]    Verify book details match
    ${book}=    Get Book From Response    ${API_RESPONSE}
    Should Be Equal As Numbers    ${book}[id]    ${CREATED_BOOK_ID}

The response should contain error message "${message}"
    [Documentation]    Verify error message in response
    API Response Should Have Error Message    ${API_RESPONSE}    ${message}

The response should contain the updated book data
    [Documentation]    Verify updated data in response
    API Response Should Contain Book Data    ${API_RESPONSE}    ${UPDATED_TITLE}    ${UPDATED_AUTHOR}    ${UPDATED_PAGES}    ${UPDATED_CATEGORY}

The book should be updated in the database
    [Documentation]    Verify book is updated in database
    ${book}=    Book Should Exist In Database    ${CREATED_BOOK_ID}
    Should Be Equal    ${book}[title]    ${UPDATED_TITLE}

The response should contain confirmation message
    [Documentation]    Verify deletion confirmation
    ${response_data}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${response_data}[message]    deleted successfully

The book should not exist in the database
    [Documentation]    Verify book is deleted from database
    Book Should Not Exist In Database    ${CREATED_BOOK_ID}

The book should be marked as favorite in the database
    [Documentation]    Verify favorite status is true
    ${book}=    Book Should Exist In Database    ${CREATED_BOOK_ID}
    Should Be True    ${book}[favorite]

The book should not be marked as favorite in the database
    [Documentation]    Verify favorite status is false
    ${book}=    Book Should Exist In Database    ${CREATED_BOOK_ID}
    Should Not Be True    ${book}[favorite]

The book should have category "${category}"
    [Documentation]    Verify book has specific category
    ${book}=    Get Book From Response    ${API_RESPONSE}
    Should Be Equal    ${book}[category]    ${category}

The book should have favorite status "${status}"
    [Documentation]    Verify favorite status
    ${book}=    Get Book From Response    ${API_RESPONSE}
    ${expected}=    Convert To Boolean    ${status}
    Should Be Equal    ${book}[favorite]    ${expected}

All books should be created successfully
    [Documentation]    Verify all creation responses are successful
    FOR    ${response}    IN    @{API_RESPONSES}
        API Response Should Be Successful    ${response}
    END

Each book should have its assigned category
    [Documentation]    Verify each book has correct category
    ${index}=    Set Variable    ${0}
    FOR    ${response}    IN    @{API_RESPONSES}
        ${book}=    Get Book From Response    ${response}
        Should Be Equal    ${book}[category]    ${CREATED_CATEGORIES}[${index}]
        ${index}=    Evaluate    ${index} + 1
    END

All create requests should be successful
    [Documentation]    Verify all books were created
    ${books}=    API Get All Books
    ${count}=    Get Length    ${books}
    ${expected}=    Get Length    ${CREATED_BOOK_IDS}
    Should Be Equal As Numbers    ${count}    ${expected}

All books should exist in the database
    [Documentation]    Verify all books exist
    FOR    ${book_id}    IN    @{CREATED_BOOK_IDS}
        Book Should Exist In Database    ${book_id}
    END

The book should have fields "${field1}", "${field2}", "${field3}", "${field4}", "${field5}", "${field6}"
    [Documentation]    Verify book has all required fields
    ${book}=    Get Book From Response    ${API_RESPONSE}
    Dictionary Should Contain Key    ${book}    ${field1}
    Dictionary Should Contain Key    ${book}    ${field2}
    Dictionary Should Contain Key    ${book}    ${field3}
    Dictionary Should Contain Key    ${book}    ${field4}
    Dictionary Should Contain Key    ${book}    ${field5}
    Dictionary Should Contain Key    ${book}    ${field6}

Only the title should be changed
    [Documentation]    Verify only title was updated
    ${book}=    Get Book From Response    ${API_RESPONSE}
    Should Be Equal    ${book}[title]    New Title

Other fields should remain unchanged
    [Documentation]    Verify other fields are unchanged
    ${book}=    Get Book From Response    ${API_RESPONSE}
    Should Be Equal    ${book}[author]    ${ORIGINAL_BOOK}[author]
    Should Be Equal As Numbers    ${book}[pages]    ${ORIGINAL_BOOK}[pages]

All delete requests should be successful
    [Documentation]    Verify all deletions succeeded
    FOR    ${response}    IN    @{DELETE_RESPONSES}
        API Response Should Be Successful    ${response}
    END

No books should remain in the database
    [Documentation]    Verify database is empty
    ${books}=    API Get All Books
    ${count}=    Get Length    ${books}
    Should Be Equal As Numbers    ${count}    0

The response should be an empty list
    [Documentation]    Verify response is empty list
    ${books}=    Set Variable    ${API_RESPONSE.json()}
    ${count}=    Get Length    ${books}
    Should Be Equal As Numbers    ${count}    0

The response status should indicate validation error
    [Documentation]    Verify validation error status
    Should Be True    ${API_RESPONSE.status_code} >= 400
    Should Be True    ${API_RESPONSE.status_code} < 500

The response time should be less than "${seconds}" seconds
    [Documentation]    Verify response time is acceptable
    Should Be True    ${RESPONSE_TIME} < ${seconds}
    Log    Response time: ${RESPONSE_TIME} seconds

The updated book should have new data
    [Documentation]    Verify updated book has new data
    ${book}=    Book Should Exist In Database    ${UPDATED_BOOK_ID}
    Should Be Equal    ${book}[title]    Updated Book
    Should Be Equal    ${book}[author]    Updated Author

Other books should remain unchanged
    [Documentation]    Verify other books are not affected
    FOR    ${book_id}    IN    @{CREATED_BOOK_IDS}
        IF    ${book_id} != ${UPDATED_BOOK_ID}
            ${book}=    Book Should Exist In Database    ${book_id}
            Should Not Be Equal    ${book}[title]    Updated Book
        END
    END
