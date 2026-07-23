*** Settings ***
Documentation    This test suite verifies the book catalog functionality with Amazon prices.
Library          Browser

*** Variables ***
${BOOK_CATALOG_URL}    https://example.com/book-catalog

*** Test Cases ***
View book catalog with Amazon prices - successful scenario
    [Documentation]    Verify that the price of the book is displayed if purchased from Amazon.
    [Tags]    req-GENAI-497    type-ok
    Given I am browsing the book catalog
    When I view the details of a book
    Then I should see the price of the book if purchased from Amazon

View book catalog with Amazon prices - unsuccessful scenario
    [Documentation]    Verify that a message is displayed if the Amazon price is not available.
    [Tags]    req-GENAI-497    type-nok
    Given I am browsing the book catalog
    When I view the details of a book
    And the Amazon price is not available
    Then I should see a message indicating that the price is not available

Amazon price not available - successful scenario
    [Documentation]    Verify that a message is displayed if the Amazon price is not available.
    [Tags]    req-GENAI-497    type-ok
    Given I am browsing the book catalog
    When I view the details of a book
    And the Amazon price is not available
    Then I should see a message indicating that the price is not available

Amazon price not available - unsuccessful scenario
    [Documentation]    Verify that the price of the book is displayed if purchased from Amazon.
    [Tags]    req-GENAI-497    type-nok
    Given I am browsing the book catalog
    When I view the details of a book
    And the Amazon price is available
    Then I should see the price of the book if purchased from Amazon

*** Keywords ***
I am browsing the book catalog
    New Page    ${BOOK_CATALOG_URL}

I view the details of a book
    Click    //a[contains(@href, 'book-details')]

I should see the price of the book if purchased from Amazon
    Wait For Elements State    //span[@class='amazon-price']    visible
    Get Text    //span[@class='amazon-price']

I should see a message indicating that the price is not available
    Wait For Elements State    //div[@class='price-not-available']    visible
    Get Text    //div[@class='price-not-available']

The Amazon price is not available
    ${is_price_available}=    Run Keyword And Return Status    Get Text    //span[@class='amazon-price']
    Run Keyword If    ${is_price_available}==False    Log    Amazon price is not available

The Amazon price is available
    ${is_price_available}=    Run Keyword And Return Status    Get Text    //span[@class='amazon-price']
    Run Keyword If    ${is_price_available}==True    Log    Amazon price is available
