*** Settings ***
Documentation    This test suite verifies the functionality of viewing all available books in the store.
Library          Browser

*** Variables ***
${URL}           http://bookstore.example.com

*** Test Cases ***
View all available books - successful scenario
    [Documentation]    Verify that an end customer can see a list of all available books with title, author, and price.
    [Tags]    req-GENAI-441    type-ok
    Given I am an end customer
    When I navigate to the books listing page
    Then I should see a list of all available books in the store
    And each book should display its title, author, and price

View all available books with no books in the store - unsuccessful scenario
    [Documentation]    Verify that an end customer sees a message indicating no books are available when there are no books in the store.
    [Tags]    req-GENAI-441    type-nok
    Given I am an end customer
    When I navigate to the books listing page
    And there are no books in database
    Then I should see a message indicating that no books are available

View all available books with backend API failure - unsuccessful scenario
    [Documentation]    Verify that an end customer sees an error message when the backend API fails to fetch book data.
    [Tags]    req-GENAI-441    type-nok
    Given I am an end customer
    When I navigate to the books listing page
    And the backend API fails to fetch book data
    Then I should see an error message indicating that the books could not be loaded

View all available books with incomplete book data - unsuccessful scenario
    [Documentation]    Verify that an end customer sees a message indicating missing book information when the book data fetched is incomplete.
    [Tags]    req-GENAI-441    type-nok
    Given I am an end customer
    When I navigate to the books listing page
    And the book data fetched is incomplete
    Then I should see a message indicating that some book information is missing

*** Keywords ***
I am an end customer
    New Browser    headless=False
    New Context
    New Page    ${URL}

I navigate to the books listing page
    Go To    ${URL}/books
    Wait For Elements State    //div[@class='book-list']    visible

I should see a list of all available books in the store
    ${books}=    Get Elements    //div[@class='book-item']
    Should Be True    ${books}    msg=No books found

Each book should display its title, author, and price
    ${books}=    Get Elements    //div[@class='book-item']
    FOR    ${book}    IN    @{books}
        ${title}=    Get Text    ${book}//h2[@class='title']
        ${author}=    Get Text    ${book}//p[@class='author']
        ${price}=    Get Text    ${book}//span[@class='price']
        Should Not Be Empty    ${title}
        Should Not Be Empty    ${author}
        Should Not Be Empty    ${price}
    END

There are no books in database
    # Simulate no books in the database by clearing the book list
    Evaluate    document.querySelector('.book-list').innerHTML = '';

I should see a message indicating that no books are available
    ${message}=    Get Text    //div[@class='no-books-message']
    Should Be Equal    ${message}    No books available

The backend API fails to fetch book data
    # Simulate backend API failure by throwing an error
    Evaluate    throw new Error('Backend API failure');

I should see an error message indicating that the books could not be loaded
    ${error_message}=    Get Text    //div[@class='error-message']
    Should Be Equal    ${error_message}    Books could not be loaded

The book data fetched is incomplete
    # Simulate incomplete book data by removing some fields
    Evaluate    document.querySelectorAll('.book-item').forEach(book => { book.querySelector('.author').remove(); });

I should see a message indicating that some book information is missing
    ${message}=    Get Text    //div[@class='incomplete-data-message']
    Should Be Equal    ${message}    Some book information is missing
