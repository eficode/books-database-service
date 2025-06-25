*** Settings ***
Documentation    This test suite verifies the functionality of displaying and ranking books by author on the webpage.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Display Books By Author - Successful Scenario
    [Documentation]    Verify that a book enthusiast can see a list of books categorized by author.
    [Tags]    req-GENAI-358    type-ok
    Given I am a book enthusiast
    When I visit the webpage
    Then I should see a list of books categorized by author

Display Books By Author - Unsuccessful Scenario
    [Documentation]    Verify that an error message is shown when the backend API is down.
    [Tags]    req-GENAI-358    type-nok
    Given I am a book enthusiast
    When I visit the webpage
    And the backend API is down
    Then I should see an error message indicating that books cannot be fetched

Rank Books By Author - Successful Scenario
    [Documentation]    Verify that books can be ranked within each author category.
    [Tags]    req-GENAI-358    type-ok
    Given I am viewing books categorized by author
    When I choose to rank the books
    Then I should be able to rank the books within each author category

Rank Books By Author - Unsuccessful Scenario
    [Documentation]    Verify that an error message is shown when the ranking feature is disabled.
    [Tags]    req-GENAI-358    type-nok
    Given I am viewing books categorized by author
    When I choose to rank the books
    And the ranking feature is disabled
    Then I should see an error message indicating that ranking is not available

*** Keywords ***
I am a book enthusiast
    New Page    ${URL}

I visit the webpage
    Go To    ${URL}

I should see a list of books categorized by author
    Wait For Elements State    //div[@class='book-list']    visible
    Get Text    //div[@class='book-list']

The backend API is down
    # Simulate backend API down scenario
    Evaluate    window.apiDown = true;

I should see an error message indicating that books cannot be fetched
    Wait For Elements State    //div[@class='error-message']    visible
    Get Text    //div[@class='error-message']

I am viewing books categorized by author
    Go To    ${URL}
    Wait For Elements State    //div[@class='book-list']    visible

I choose to rank the books
    Click    //button[@id='rank-books']

I should be able to rank the books within each author category
    Wait For Elements State    //div[@class='ranking']    visible
    Get Text    //div[@class='ranking']

The ranking feature is disabled
    # Simulate ranking feature disabled scenario
    Evaluate    window.rankingDisabled = true;

I should see an error message indicating that ranking is not available
    Wait For Elements State    //div[@class='error-message']    visible
    Get Text    //div[@class='error-message']
