*** Settings ***
Documentation    Integration tests combining UI and API interactions for Books Library
Resource         resources/common.resource
Resource         keywords/ui_keywords.resource
Resource         keywords/api_keywords.resource

Suite Setup      Setup Integration Test Suite
Suite Teardown   Teardown Integration Test Suite
Test Setup       Setup Integration Test Case
Test Teardown    Teardown Integration Test Case

Test Tags        integration    ui-api

*** Keywords ***
Setup Integration Test Suite
    [Documentation]    Suite-level setup for integration tests
    Setup API Session

Teardown Integration Test Suite
    [Documentation]    Suite-level teardown for integration tests
    Clean Up Test Books
    Teardown API Session

Setup Integration Test Case
    [Documentation]    Test case setup for integration tests
    Setup Browser Session
    Clear All Books Via API

Teardown Integration Test Case
    [Documentation]    Test case teardown for integration tests
    Run Keyword If Test Failed    Take Screenshot On Failure
    Run Keyword If Test Failed    Log Browser Console
    Teardown Browser Session

*** Test Cases ***
Scenario: Books Created Via API Appear In UI
    [Documentation]    Verify that books created through API are visible in the UI
    [Tags]    smoke    api-to-ui    data-sync
    Given The Books API Is Available
    When I Send A POST Request To Create A Book    {"title": "API Created Book", "author": "API Author", "pages": 275, "category": "Science Fiction", "favorite": false}
    Then The Response Status Should Be    200
    When I Am On The Books Library Homepage
    Then I Should See The Book In The List    API Created Book    API Author    275    Science Fiction
    And I Should See The Book Count    1

Scenario: Books Created Via UI Are Accessible Through API
    [Documentation]    Verify that books created through UI can be retrieved via API
    [Tags]    smoke    ui-to-api    data-sync
    Given I Am On The Books Library Homepage
    When I Add A New Book    UI Created Book    UI Author    225    Fantasy
    Then I Should See The Book In The List    UI Created Book    UI Author    225    Fantasy
    When I Send A GET Request To Get All Books
    Then The Response Status Should Be    200
    And The Books List Should Contain    1
    ${books}=    Set Variable    ${API_RESPONSE.json()}
    ${book}=    Set Variable    ${books}[0]
    Should Be Equal As Strings    ${book}[title]    UI Created Book
    Should Be Equal As Strings    ${book}[author]    UI Author
    Should Be Equal As Integers    ${book}[pages]    225
    Should Be Equal As Strings    ${book}[category]    Fantasy

Scenario: UI Reflects API Changes In Real-Time
    [Documentation]    Verify that UI updates when data is changed via API
    [Tags]    real-time    api-to-ui    synchronization
    Given I Am On The Books Library Homepage
    And I Have A Book In The Database    Original Book    Original Author    200    Fiction
    When I Am On The Books Library Homepage
    Then I Should See The Book In The List    Original Book    Original Author    200    Fiction
    When I Send A PUT Request To Update A Book    ${TEST_BOOK_ID}    {"title": "API Updated Book", "author": "API Updated Author", "pages": 300, "category": "Science", "favorite": false}
    And I Am On The Books Library Homepage
    Then I Should See The Book In The List    API Updated Book    API Updated Author    300    Science
    And I Should Not See The Book In The List    Original Book

Scenario: Favorite Status Synchronizes Between UI And API
    [Documentation]    Verify that favorite status changes are synchronized between UI and API
    [Tags]    favorites    synchronization    ui-api
    Given I Am On The Books Library Homepage
    And I Have A Book In The Database    Sync Test Book    Sync Author    250    Romance
    When I Am On The Books Library Homepage
    And I Toggle Favorite On Book    Sync Test Book
    Then The Book Should Be Marked As Favorite    Sync Test Book
    When I Send A GET Request To Get Book By ID    ${TEST_BOOK_ID}
    Then The Response Status Should Be    200
    And The Book Should Have Favorite Status    ${True}

Scenario: UI Handles API Errors Gracefully
    [Documentation]    Verify that UI displays appropriate error messages when API fails
    [Tags]    error-handling    ui-api    resilience
    Given I Am On The Books Library Homepage
    # Simulate API failure by using invalid data that would cause server error
    When I Fill In The Book Form    Valid Title    Valid Author    invalid_pages    Fiction
    And I Submit The Book Form
    Then I Should See An Error Message
    # Verify the form is still usable after error
    When I Clear Form Fields
    And I Add A New Book    Recovery Book    Recovery Author    200    Fiction
    Then I Should See The Book In The List    Recovery Book    Recovery Author    200    Fiction

Scenario: Concurrent UI And API Operations Maintain Data Integrity
    [Documentation]    Verify data integrity when UI and API operations happen concurrently
    [Tags]    concurrency    data-integrity    stress
    Given I Am On The Books Library Homepage
    And I Have Multiple Books In The Database    5
    When I Am On The Books Library Homepage
    Then I Should See The Book Count    5
    # Simulate concurrent operations
    When I Send A POST Request To Create A Book    {"title": "Concurrent API Book", "author": "API Author", "pages": 300, "category": "Science", "favorite": false}
    And I Add A New Book    Concurrent UI Book    UI Author    250    Fantasy
    Then I Should See The Book Count    7
    When I Send A GET Request To Get All Books
    Then The Response Status Should Be    200
    And The Books List Should Contain    7

Scenario: Search Functionality Works With API-Created Books
    [Documentation]    Verify that search works correctly with books created via API
    [Tags]    search    api-to-ui    functionality
    Given The Books API Is Available
    When I Send A POST Request To Create A Book    {"title": "Searchable API Book", "author": "Searchable Author", "pages": 280, "category": "Mystery", "favorite": false}
    And I Send A POST Request To Create A Book    {"title": "Another Book", "author": "Another Author", "pages": 180, "category": "Fiction", "favorite": false}
    And I Am On The Books Library Homepage
    When I Search For Books    Searchable
    Then I Should See The Book In The List    Searchable API Book    Searchable Author    280    Mystery
    And I Should Not See The Book In The List    Another Book

Scenario: Filtering Works With Mixed UI And API Created Books
    [Documentation]    Verify that filtering works correctly with books from different sources
    [Tags]    filter    mixed-sources    functionality
    Given I Am On The Books Library Homepage
    And I Send A POST Request To Create A Book    {"title": "API Science Book", "author": "API Author", "pages": 300, "category": "Science", "favorite": false}
    When I Add A New Book    UI Science Book    UI Author    250    Science
    And I Add A New Book    UI Fiction Book    UI Author    200    Fiction
    And I Filter Books By Category    Science
    Then I Should See The Book In The List    API Science Book    API Author    300    Science
    And I Should See The Book In The List    UI Science Book    UI Author    250    Science
    And I Should Not See The Book In The List    UI Fiction Book

Scenario: Sorting Works With Mixed Data Sources
    [Documentation]    Verify that sorting works correctly with books from UI and API
    [Tags]    sort    mixed-sources    functionality
    Given I Am On The Books Library Homepage
    And I Send A POST Request To Create A Book    {"title": "Zebra API Book", "author": "Z Author", "pages": 300, "category": "Fiction", "favorite": false}
    When I Add A New Book    Alpha UI Book    A Author    200    Fiction
    And I Add A New Book    Beta UI Book    B Author    250    Fiction
    And I Sort Books By    Title
    Then I Should See Books Sorted By    title    ascending

Scenario: Data Persistence Across Browser Sessions
    [Documentation]    Verify that data persists when browser is closed and reopened
    [Tags]    persistence    data-integrity    session
    Given I Am On The Books Library Homepage
    When I Add A New Book    Persistent Book    Persistent Author    300    Science Fiction
    Then I Should See The Book In The List    Persistent Book    Persistent Author    300    Science Fiction
    # Simulate browser restart
    When Teardown Browser Session
    And Setup Browser Session
    Then I Should See The Book In The List    Persistent Book    Persistent Author    300    Science Fiction

Scenario: Large Dataset Performance Integration
    [Documentation]    Verify UI performance with large datasets created via API
    [Tags]    performance    large-dataset    integration
    Given The Books API Is Available
    And I Have Multiple Books In The Database    50
    When I Am On The Books Library Homepage
    Then Wait For Books To Load
    And I Should See The Book Count    50
    # Test that UI operations still work with large dataset
    When I Add A New Book    Performance Test Book    Performance Author    200    Fiction
    Then I Should See The Book Count    51
    When I Search For Books    Performance Test
    Then I Should See The Book In The List    Performance Test Book    Performance Author    200    Fiction

Scenario: Error Recovery And State Consistency
    [Documentation]    Verify that system recovers gracefully from errors and maintains consistent state
    [Tags]    error-recovery    consistency    resilience
    Given I Am On The Books Library Homepage
    And I Have A Book In The Database    Test Book    Test Author    200    Fiction
    When I Am On The Books Library Homepage
    Then I Should See The Book In The List    Test Book    Test Author    200    Fiction
    # Delete book via API while UI is open
    When I Send A DELETE Request To Delete A Book    ${TEST_BOOK_ID}
    Then The Response Status Should Be    200
    # Refresh UI and verify consistency
    When I Am On The Books Library Homepage
    Then I Should Not See The Book In The List    Test Book
    And I Should See The Book Count    0

Scenario: Cross-Browser Data Consistency
    [Documentation]    Verify that data changes are consistent across different browser instances
    [Tags]    cross-browser    consistency    multi-session
    Given I Am On The Books Library Homepage
    When I Add A New Book    Cross Browser Book    Cross Author    250    Fantasy
    Then I Should See The Book In The List    Cross Browser Book    Cross Author    250    Fantasy
    # Verify via API that the book exists
    When I Send A GET Request To Get All Books
    Then The Response Status Should Be    200
    And The Books List Should Contain    1
    ${books}=    Set Variable    ${API_RESPONSE.json()}
    ${book}=    Set Variable    ${books}[0]
    Should Be Equal As Strings    ${book}[title]    Cross Browser Book