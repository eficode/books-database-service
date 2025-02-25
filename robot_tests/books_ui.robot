*** Settings ***
Documentation     UI Tests for Books Database Service
Resource          resources/common.resource
Suite Setup       Setup Test Environment
Suite Teardown    Teardown Test Environment
Test Tags         ui    browser

*** Variables ***
${TEST_BOOK_TITLE}        Robot Test Book
${TEST_BOOK_AUTHOR}       Robot Framework
${TEST_BOOK_PAGES}        123
${TEST_BOOK_CATEGORY}     Science Fiction

*** Test Cases ***
User Can Open Books UI
    [Documentation]    Verify that the Books UI loads correctly
    [Tags]             smoke
    
    Given I Open The Books Application
    Then I Should See The Books Library Title
    And I Should See The Add Book Button
    And I Should See The Books List Section

User Can Add A New Book
    [Documentation]    Verify that user can add a new book
    [Tags]             crud
    ${random_suffix}=    Generate Random String    8    [NUMBERS]
    ${title}=    Set Variable    Robot Test Book ${random_suffix}
    ${author}=    Set Variable    Test Author ${random_suffix}
    ${pages}=    Set Variable    123
    ${category}=    Set Variable    Fiction
    
    Given I Have Book Details To Add
    When I Fill The Add Book Form    ${title}    ${author}    ${pages}    ${category}
    And I Submit The Add Book Form
    Then I Should See A Success Notification
    When I Search For Book By Title    ${title}
    Then I Should See Book Details    ${title}    ${author}

User Can Search For Books
    [Documentation]    Verify that user can search for books
    [Tags]             search
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    
    Given I Have Created A Book    ${title}    ${author}    ${pages}    ${category}
    When I Search For Book By Title    ${title}
    Then I Should See Book With Title    ${title}
    When I Search For Nonexistent Book
    Then I Should See No Books Found Message
    When I Clear The Search
    Then I Should See All Books

User Can Filter Books By Category
    [Documentation]    Verify that user can filter books by category
    [Tags]             filter
    ${random_suffix}=    Generate Random String    6    [NUMBERS]
    ${fiction_title}=    Set Variable    TestFiction${random_suffix}
    
    Given I Can See The Category Filter
    When I Select Fiction Category Filter
    And I Add A Fiction Book    ${fiction_title}
    And I Search For Book By Title    ${fiction_title}
    Then I Should See Book With Title    ${fiction_title}
    When I Reset The Category Filter
    Then I Should See All Categories Option

User Can Edit A Book
    [Documentation]    Verify that user can edit a book
    [Tags]             crud
    ${random_suffix}=    Generate Random String    8    [NUMBERS]
    ${original_title}=    Set Variable    Editable Book ${random_suffix}
    ${original_author}=    Set Variable    Original Author
    ${original_pages}=    Set Variable    100
    ${original_category}=    Set Variable    Fiction
    ${new_title}=    Set Variable    Edited Book ${random_suffix}
    ${new_author}=    Set Variable    Edited Author
    ${new_pages}=    Set Variable    200
    ${new_category}=    Set Variable    Mystery
    
    Given I Create A Book For Editing    ${original_title}    ${original_author}    ${original_pages}    ${original_category}
    When I Clear Filters And Search    ${original_title}
    Then I Should See Book With Title    ${original_title}
    When I Edit The Book    ${original_title}    ${new_title}    ${new_author}    ${new_pages}    ${new_category}
    And I Search For Book By Title    ${new_title}
    Then I Should See Book With Title    ${new_title}

User Can Delete A Book
    [Documentation]    Verify that user can delete a book
    [Tags]             crud
    ${random_suffix}=    Generate Random String    8    [NUMBERS]
    ${title}=    Set Variable    Deletable Book ${random_suffix}
    ${author}=    Set Variable    Delete Author
    ${pages}=    Set Variable    100
    ${category}=    Set Variable    Fiction
    
    Given I Create A Book For Deletion    ${title}    ${author}    ${pages}    ${category}
    When I Clear Filters And Search    ${title}
    Then I Should See Book With Title    ${title}
    When I Delete Book With Title    ${title}
    And I Search For Book By Title    ${title}
    Then I Should See No Books Found Message

User Can Sort Books
    [Documentation]    Verify that user can sort books
    [Tags]             sort
    ${random_suffix}=    Generate Random String    8    [NUMBERS]
    ${title_a}=    Set Variable    A Test Book Sort ${random_suffix}
    ${title_b}=    Set Variable    B Test Book Sort ${random_suffix}
    ${title_c}=    Set Variable    C Test Book Sort ${random_suffix}
    
    Given I Create Multiple Books For Sorting    ${title_a}    ${title_b}    ${title_c}
    When I Filter And Search For Books    ${random_suffix}
    And I Sort By Title Ascending
    Then I Should See First Book With Title    ${title_a}

