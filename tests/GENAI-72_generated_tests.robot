*** Settings ***
Documentation    This test suite verifies the functionality of displaying top-selling books and reviewing/rating books on the Bookbridge platform.
Library          Browser

*** Variables ***
${BOOKBRIDGE_URL}    https://bookbridge.example.com

*** Test Cases ***
Display top-selling books - successful scenario
    [Documentation]    Verify that a customer can see a list of top-selling industry books.
    [Tags]    req-GENAI-70    type-ok
    Given I am a Bookbridge customer
    When I navigate to the top-selling books section
    And I can filter the search based on book categories
    Then I should see a list of top-selling industry books

Display top-selling books - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the backend API is down.
    [Tags]    req-GENAI-70    type-nok
    Given I am a Bookbridge customer
    When I navigate to the top-selling books section
    And I can filter the search based on book categories
    And the backend API is down
    Then I should see an error message indicating that the top-selling books cannot be retrieved

Review and rate a book - successful scenario
    [Documentation]    Verify that a customer can review and rate a book successfully.
    [Tags]    req-GENAI-70    type-ok
    Given I am viewing a top-selling book
    When I provide a review and rating
    Then my review and rating should be saved and displayed for the book

Review and rate a book - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the backend API fails to save the review.
    [Tags]    req-GENAI-70    type-nok
    Given I am viewing a top-selling book
    When I provide a review and rating
    And the backend API fails to save the review
    Then I should see an error message indicating that my review and rating could not be saved

*** Keywords ***
I am a Bookbridge customer
    New Page    ${BOOKBRIDGE_URL}
    Wait For Elements State    //div[@id='top-selling-books']    visible

I navigate to the top-selling books section
    Click    //a[@href='/top-selling-books']
    Wait For Elements State    //div[@id='top-selling-books-list']    visible

I can filter the search based on book categories
    Click    //select[@id='book-category-filter']
    Select Options By    //select[@id='book-category-filter']    text    Industry
    Wait For Elements State    //div[@id='filtered-books-list']    visible

I should see a list of top-selling industry books
    Wait For Elements State    //div[@id='filtered-books-list']/div[contains(@class, 'book-item')]    visible

The backend API is down
    # Simulate backend API down scenario
    Evaluate    window.apiDown = true;

I should see an error message indicating that the top-selling books cannot be retrieved
    Wait For Elements State    //div[@id='error-message']    visible
    Get Text    //div[@id='error-message']    ==    The top-selling books cannot be retrieved

I am viewing a top-selling book
    Click    //div[@id='filtered-books-list']/div[contains(@class, 'book-item')][1]
    Wait For Elements State    //div[@id='book-details']    visible

I provide a review and rating
    Fill Text    //textarea[@id='review-text']    Great book!
    Click    //input[@id='rating-5']
    Click    //button[@id='submit-review']

My review and rating should be saved and displayed for the book
    Wait For Elements State    //div[@id='reviews']/div[contains(@class, 'review-item')]    visible
    Get Text    //div[@id='reviews']/div[contains(@class, 'review-item')]/p    ==    Great book!

The backend API fails to save the review
    # Simulate backend API failure scenario
    Evaluate    window.apiFail = true;

I should see an error message indicating that my review and rating could not be saved
    Wait For Elements State    //div[@id='error-message']    visible
    Get Text    //div[@id='error-message']    ==    Your review and rating could not be saved
