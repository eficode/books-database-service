*** Settings ***
Library    Browser
Documentation    Test suite for verifying pricing information on the webpage.

*** Variables ***
${URL}    http://example.com/pricing

*** Test Cases ***
View pricing information on webpage - successful scenario
    [Documentation]    Verify that a user can see a list of books with their current prices.
    [Tags]    req-GENAI-469    type-ok
    Given I am a user
    When I navigate to the pricing information webpage
    Then I should see a list of books with their current prices

View pricing information on webpage with no internet connection - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when there is no internet connection.
    [Tags]    req-GENAI-469    type-nok
    Given I am a user
    And I have no internet connection
    When I navigate to the pricing information webpage
    Then I should see an error message indicating that the webpage cannot be loaded

No books in the database - successful scenario
    [Documentation]    Verify that a message is shown when there are no books in the database.
    [Tags]    req-GENAI-469    type-ok
    Given there are no books in the database
    When I navigate to the pricing information webpage
    Then I should see a message indicating that no pricing information is available

No books in the database with server error - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the server is down and there are no books in the database.
    [Tags]    req-GENAI-469    type-nok
    Given there are no books in the database
    And the server is down
    When I navigate to the pricing information webpage
    Then I should see an error message indicating that the server is unavailable

*** Keywords ***
I am a user
    New Browser    headless=False
    New Page    ${URL}

I have no internet connection
    Set Offline    True

I navigate to the pricing information webpage
    Go To    ${URL}

I should see a list of books with their current prices
    Wait For Elements State    //div[@class='book-list']    visible
    Get Element States    //div[@class='book-list']    ==    visible

I should see an error message indicating that the webpage cannot be loaded
    Wait For Elements State    //div[@class='error-message']    visible
    Get Element States    //div[@class='error-message']    ==    visible

There are no books in the database
    Log    Ensure the database is empty or mock the response

I should see a message indicating that no pricing information is available
    Wait For Elements State    //div[@class='no-books-message']    visible
    Get Element States    //div[@class='no-books-message']    ==    visible

The server is down
    Log    Simulate server down or mock the response

I should see an error message indicating that the server is unavailable
    Wait For Elements State    //div[@class='server-error-message']    visible
    Get Element States    //div[@class='server-error-message']    ==    visible
