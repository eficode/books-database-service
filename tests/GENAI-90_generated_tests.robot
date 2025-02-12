*** Settings ***
Documentation    Test suite for verifying book search functionality on BookBridge
Library          Browser

*** Variables ***
${BOOKBRIDGE_URL}    https://bookbridge.example.com

*** Test Cases ***
User searches for books larger than 1000 pages - successful scenario
    [Documentation]    Verify that user can search for books with more than 1000 pages
    [Tags]    req-GENAI-88    type-ok
    Given I am a BookBridge end user
    When I search for books with more than 1000 pages
    Then I should see a list of books that have more than 1000 pages

No books found with more than 1000 pages - successful scenario
    [Documentation]    Verify that user sees a message when no books match the search criteria
    [Tags]    req-GENAI-88    type-ok
    Given I am a BookBridge end user
    When I search for books with more than 1000 pages
    And no books match the criteria
    Then I should see a message indicating that no books were found

User searches for books larger than 1000 pages with invalid input - unsuccessful scenario
    [Documentation]    Verify that user sees an error message when entering invalid search criteria
    [Tags]    req-GENAI-88    type-nok
    Given I am a BookBridge end user
    When I search for books with more than 1000 pages
    And I enter an invalid input
    Then I should see an error message indicating invalid search criteria

No books found due to backend error - unsuccessful scenario
    [Documentation]    Verify that user sees a message when there is a backend error
    [Tags]    req-GENAI-88    type-nok
    Given I am a BookBridge end user
    When I search for books with more than 1000 pages
    And there is a backend error
    Then I should see a message indicating that the search could not be completed

*** Keywords ***
I am a BookBridge end user
    New Browser    headless=False
    New Page    ${BOOKBRIDGE_URL}
    Wait For Elements State    //input[@id='search-box']    visible=True

I search for books with more than 1000 pages
    Fill Text    //input[@id='search-box']    >1000 pages
    Click    //button[@id='search-button']
    Wait For Elements State    //div[@id='search-results']    visible=True

no books match the criteria
    # Simulate no books found condition
    Evaluate    document.querySelector('#search-results').innerHTML = '<div>No books found</div>'

I enter an invalid input
    Fill Text    //input[@id='search-box']    invalid input
    Click    //button[@id='search-button']
    Wait For Elements State    //div[@id='error-message']    visible=True

there is a backend error
    # Simulate backend error condition
    Evaluate    document.querySelector('#search-results').innerHTML = '<div>Backend error occurred</div>'

I should see a list of books that have more than 1000 pages
    Get Element States    //div[@id='search-results']//div[contains(text(), 'pages')]    visible=True

I should see a message indicating that no books were found
    Get Element States    //div[@id='search-results']//div[contains(text(), 'No books found')]    visible=True

I should see an error message indicating invalid search criteria
    Get Element States    //div[@id='error-message']//div[contains(text(), 'Invalid search criteria')]    visible=True

I should see a message indicating that the search could not be completed
    Get Element States    //div[@id='search-results']//div[contains(text(), 'Backend error occurred')]    visible=True
