*** Settings ***
Documentation    This test suite verifies the functionality of viewing book listings with prices and handling price updates.
Library          Browser

*** Variables ***
${BOOK_LISTINGS_URL}    https://example.com/book-listings

*** Test Cases ***
View book listings with prices - successful scenario
    [Documentation]    Verify that a visitor can see a list of books with their current prices from Amazon.com
    [Tags]    req-GENAI-473    type-ok
    Given I am a website visitor
    When I navigate to the book listings page
    Then I should see a list of books with their current prices from Amazon.com

View book listings with prices - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when there is an error fetching prices from Amazon.com
    [Tags]    req-GENAI-473    type-nok
    Given I am a website visitor
    When I navigate to the book listings page
    And there is an error fetching prices from Amazon.com
    Then I should see an error message indicating the issue

Price update - successful scenario
    [Documentation]    Verify that the updated price is shown when a book's price has changed on Amazon.com
    [Tags]    req-GENAI-473    type-ok
    Given a book's price has changed on Amazon.com
    When I refresh the book listings page
    Then I should see the updated price for the book

Price update - unsuccessful scenario
    [Documentation]    Verify that a message is shown indicating that the price update is in progress when there is a delay in fetching the updated price from Amazon.com
    [Tags]    req-GENAI-473    type-nok
    Given a book's price has changed on Amazon.com
    When I refresh the book listings page
    And there is a delay in fetching the updated price from Amazon.com
    Then I should see a message indicating that the price update is in progress

*** Keywords ***
I am a website visitor
    New Browser    headless=False
    New Page    ${BOOK_LISTINGS_URL}

I navigate to the book listings page
    Go To    ${BOOK_LISTINGS_URL}

I should see a list of books with their current prices from Amazon.com
    Wait For Elements State    //div[@class='book-listing']    visible
    Get Text    //div[@class='book-listing']
    Should Contain    ${text}    Amazon.com

There is an error fetching prices from Amazon.com
    # Simulate an error in fetching prices
    Evaluate    window.simulateErrorFetchingPrices()    window

I should see an error message indicating the issue
    Wait For Elements State    //div[@class='error-message']    visible
    Get Text    //div[@class='error-message']
    Should Contain    ${text}    Error fetching prices

A book's price has changed on Amazon.com
    # Simulate a price change on Amazon.com
    Evaluate    window.simulatePriceChange()    window

I refresh the book listings page
    Reload

I should see the updated price for the book
    Wait For Elements State    //div[@class='book-listing']    visible
    Get Text    //div[@class='book-listing']
    Should Contain    ${text}    Updated Price

There is a delay in fetching the updated price from Amazon.com
    # Simulate a delay in fetching the updated price
    Evaluate    window.simulatePriceUpdateDelay()    window

I should see a message indicating that the price update is in progress
    Wait For Elements State    //div[@class='update-message']    visible
    Get Text    //div[@class='update-message']
    Should Contain    ${text}    Price update in progress
