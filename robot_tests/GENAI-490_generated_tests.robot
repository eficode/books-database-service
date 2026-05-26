*** Settings ***
Library           Browser
Documentation    This test suite verifies the book listing and price display functionality on the website.

*** Variables ***
${URL}           https://example.com/book-listing

*** Test Cases ***
View Book Listing With Prices
    [Documentation]    Verify that book prices from Amazon.com are displayed next to their titles.
    [Tags]    req-GENAI-488    type-ok
    Given I am a website visitor
    When I view the book listing
    Then I should see the prices of the books from Amazon.com next to their titles

View Book Listing With Prices Unavailable
    [Documentation]    Verify that an error message is displayed when prices fail to load from Amazon.com.
    [Tags]    req-GENAI-488    type-nok
    Given I am a website visitor
    When I view the book listing
    And the prices fail to load from Amazon.com
    Then I should see an error message indicating that prices are unavailable

Refresh Book Listing With Updated Prices
    [Documentation]    Verify that the updated price is displayed next to the book title when the book listing is refreshed.
    [Tags]    req-GENAI-488    type-ok
    Given the price of a book changes on Amazon.com
    When the book listing is refreshed
    Then the updated price should be displayed next to the book title

Refresh Book Listing With Failed Price Update
    [Documentation]    Verify that the old price is still displayed next to the book title when the updated price fails to load.
    [Tags]    req-GENAI-488    type-nok
    Given the price of a book changes on Amazon.com
    When the book listing is refreshed
    And the updated price fails to load
    Then the old price should still be displayed next to the book title

*** Keywords ***
I am a website visitor
    New Browser    headless=False
    New Context
    New Page    ${URL}

I view the book listing
    Wait For Elements State    //div[@class='book-listing']    visible

I should see the prices of the books from Amazon.com next to their titles
    Wait For Elements State    //div[@class='book-price']    visible
    Get Text    //div[@class='book-price']

The prices fail to load from Amazon.com
    # Simulate price load failure
    Evaluate    document.querySelectorAll('.book-price').forEach(el => el.remove());

I should see an error message indicating that prices are unavailable
    Wait For Elements State    //div[@class='error-message']    visible
    Get Text    //div[@class='error-message']

The price of a book changes on Amazon.com
    # Simulate price change
    Evaluate    document.querySelector('.book-price').innerText = '$19.99';

The book listing is refreshed
    Reload
    Wait For Elements State    //div[@class='book-listing']    visible

The updated price should be displayed next to the book title
    Wait For Elements State    //div[@class='book-price']    visible
    Get Text    //div[@class='book-price']

The updated price fails to load
    # Simulate updated price load failure
    Evaluate    document.querySelector('.book-price').innerText = '';

The old price should still be displayed next to the book title
    Wait For Elements State    //div[@class='book-price']    visible
    Get Text    //div[@class='book-price']
