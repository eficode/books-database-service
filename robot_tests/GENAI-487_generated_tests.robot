*** Settings ***
Documentation    This test suite verifies the book price display functionality on the book listing page.
Library          Browser

*** Variables ***
${BOOK_LISTING_URL}    https://example.com/books
${AMAZON_API_URL}      https://api.amazon.com/prices

*** Test Cases ***
View book prices on the webpage - successful scenario
    [Documentation]    Verify that book prices from Amazon.com are displayed alongside each book on the listing page.
    [Tags]    req-GENAI-485    type-ok
    Given I am a visitor on the book listing page
    When I view the list of books
    Then I should see the prices from Amazon.com displayed alongside each book

View book prices on the webpage with API failure - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when the Amazon API is down.
    [Tags]    req-GENAI-485    type-nok
    Given I am a visitor on the book listing page
    When I view the list of books
    And the Amazon API is down
    Then I should see an error message indicating that prices cannot be displayed at the moment

*** Keywords ***
I am a visitor on the book listing page
    New Page    ${BOOK_LISTING_URL}
    Wait For Elements State    //div[@class='book']    visible

I view the list of books
    Wait For Elements State    //div[@class='book']    visible

I should see the prices from Amazon.com displayed alongside each book
    Wait For Elements State    //div[@class='book']//span[@class='price']    visible
    Get Text    //div[@class='book']//span[@class='price']

The Amazon API is down
    Mock Response    ${AMAZON_API_URL}    500    {"error": "Service Unavailable"}

I should see an error message indicating that prices cannot be displayed at the moment
    Wait For Elements State    //div[@class='error-message']    visible
    Get Text    //div[@class='error-message']
