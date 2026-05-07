*** Settings ***
Library  Browser

Documentation  Test suite for verifying book price details and updates from Amazon.com

*** Variables ***
${BOOK_DETAIL_URL}  https://example.com/book-detail
${AMAZON_API_URL}  https://api.amazon.com/book-price

*** Test Cases ***
View book price on book detail page - successful scenario
    [Documentation]  Verify that the book price is displayed on the book detail page when the Amazon API is available.
    [Tags]  req-GENAI-476  type-ok
    Given I am a website visitor
    When I navigate to the book detail page
    Then I should see the price of the book from Amazon.com

View book price on book detail page - unsuccessful scenario
    [Documentation]  Verify that an error message is displayed when the Amazon API is down.
    [Tags]  req-GENAI-476  type-nok
    Given I am a website visitor
    When I navigate to the book detail page
    And the Amazon API is down
    Then I should see an error message indicating the price is unavailable

Update book price from Amazon - successful scenario
    [Documentation]  Verify that the updated book price is displayed on the book detail page when the price on Amazon.com changes.
    [Tags]  req-GENAI-476  type-ok
    Given the book price on Amazon.com has changed
    When the system fetches the latest price
    Then the updated price should be displayed on the book detail page

Update book price from Amazon - unsuccessful scenario
    [Documentation]  Verify that an error message is displayed when the fetched price from Amazon.com is incorrect.
    [Tags]  req-GENAI-476  type-nok
    Given the book price on Amazon.com has changed
    When the system fetches the latest price
    And the fetched price is incorrect
    Then an error message should be displayed indicating the price update failed

*** Keywords ***
I am a website visitor
    New Page  ${BOOK_DETAIL_URL}

I navigate to the book detail page
    Go To  ${BOOK_DETAIL_URL}

I should see the price of the book from Amazon.com
    Wait For Elements State  //span[@id='book-price']  visible
    ${price}=  Get Text  //span[@id='book-price']
    Should Not Be Empty  ${price}

The Amazon API is down
    Mock Response  ${AMAZON_API_URL}  500

I should see an error message indicating the price is unavailable
    Wait For Elements State  //div[@id='error-message']  visible
    ${error_message}=  Get Text  //div[@id='error-message']
    Should Be Equal  ${error_message}  Price is unavailable

The book price on Amazon.com has changed
    Set Variable  ${NEW_PRICE}  19.99
    Mock Response  ${AMAZON_API_URL}  {