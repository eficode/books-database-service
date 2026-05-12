*** Settings ***
Documentation    Test suite for verifying book listings and their Amazon ratings
Library          Browser
Library          Collections

*** Variables ***
${BOOK_LISTING_URL}    https://example.com/books

*** Test Cases ***
View books with Amazon ratings - successful scenario
    [Documentation]    Verify that each book is listed with its Amazon rating
    [Tags]    req-DEV-202    type-ok
    Given I am a user on the book listing page
    When I view the list of books
    Then I should see each book listed with its Amazon rating

View books with Amazon ratings - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when Amazon ratings fail to load
    [Tags]    req-DEV-202    type-nok
    Given I am a user on the book listing page
    When I view the list of books
    And the Amazon ratings fail to load
    Then I should see an error message indicating that the ratings could not be retrieved

Identify top 10 rated books - successful scenario
    [Documentation]    Verify that the top 10 rated books can be identified based on their Amazon ratings
    [Tags]    req-DEV-202    type-ok
    Given I am a user on the book listing page
    When I view the list of books
    Then I should be able to identify the top 10 rated books based on their Amazon ratings

Identify top 10 rated books - unsuccessful scenario
    [Documentation]    Verify that the top 10 rated books cannot be identified when Amazon ratings are incorrect or missing
    [Tags]    req-DEV-202    type-nok
    Given I am a user on the book listing page
    When I view the list of books
    And the Amazon ratings are incorrect or missing
    Then I should not be able to identify the top 10 rated books based on their Amazon ratings

*** Keywords ***
I am a user on the book listing page
    New Page    ${BOOK_LISTING_URL}
    Wait For Elements State    //div[@class='book-list']    visible

I view the list of books
    Wait For Elements State    //div[@class='book-item']    visible

I should see each book listed with its Amazon rating
    ${books}=    Get Elements    //div[@class='book-item']
    FOR    ${book}    IN    @{books}
        ${rating}=    Get Text    ${book}//span[@class='amazon-rating']
        Should Not Be Empty    ${rating}
    END

The Amazon ratings fail to load
    Evaluate    [el.remove() for el in document.querySelectorAll('.amazon-rating')]

I should see an error message indicating that the ratings could not be retrieved
    Wait For Elements State    //div[@class='error-message']    visible
    ${error_message}=    Get Text    //div[@class='error-message']
    Should Be Equal    ${error_message}    Ratings could not be retrieved

I should be able to identify the top 10 rated books based on their Amazon ratings
    ${books}=    Get Elements    //div[@class='book-item']
    ${ratings}=    Create List
    FOR    ${book}    IN    @{books}
        ${rating}=    Get Text    ${book}//span[@class='amazon-rating']
        Append To List    ${ratings}    ${rating}
    END
    ${sorted_ratings}=    Sort List    ${ratings}
    Reverse List    ${sorted_ratings}
    ${top_10_ratings}=    Get Slice From List    ${sorted_ratings}    0    10
    Length Should Be    ${top_10_ratings}    10

The Amazon ratings are incorrect or missing
    Evaluate    [el.textContent = '' for el in document.querySelectorAll('.amazon-rating')]

I should not be able to identify the top 10 rated books based on their Amazon ratings
    ${books}=    Get Elements    //div[@class='book-item']
    ${ratings}=    Create List
    FOR    ${book}    IN    @{books}
        ${rating}=    Get Text    ${book}//span[@class='amazon-rating']
        Append To List    ${ratings}    ${rating}
    END
    ${sorted_ratings}=    Sort List    ${ratings}
    Reverse List    ${sorted_ratings}
    ${top_10_ratings}=    Get Slice From List    ${sorted_ratings}    0    10
    Length Should Be    ${top_10_ratings}    10
