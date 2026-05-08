*** Settings ***
Library    Browser

*** Variables ***
${URL}    http://example.com

*** Test Cases ***
Search for a book - successful scenario
    [Documentation]    Verify that a book can be successfully searched
    [Tags]    req-GENAI-479    type-ok
    Given I am on the homepage
    When I enter the book title in the search bar
    And I click on the search button
    Then I should see the book in the search results

Search for a book - unsuccessful scenario
    [Documentation]    Verify that searching for a non-existent book shows no results
    [Tags]    req-GENAI-479    type-nok
    Given I am on the homepage
    When I enter a non-existent book title in the search bar
    And I click on the search button
    Then I should see a 'No results found' message

Add a book review - successful scenario
    [Documentation]    Verify that a review can be successfully added to a book
    [Tags]    req-GENAI-479    type-ok
    Given I am on the book details page
    When I enter a review in the review text area
    And I click on the 'Submit Review' button
    Then the review should be added to the book's reviews section

Add a book review - unsuccessful scenario
    [Documentation]    Verify that a review cannot be added when the review text area is disabled
    [Tags]    req-GENAI-479    type-nok
    Given I am on the book details page
    And the review text area is disabled
    When I enter a review in the review text area
    And I click on the 'Submit Review' button
    Then the review should not be added to the book's reviews section

*** Keywords ***
I am on the homepage
    New Page    ${URL}

I enter the book title in the search bar
    Type Text    id=search-bar    The Great Gatsby

I enter a non-existent book title in the search bar
    Type Text    id=search-bar    NonExistentBookTitle

I click on the search button
    Click    id=search-button

I should see the book in the search results
    Wait For Elements State    id=search-results    visible
    Get Text    id=search-results
    Should Contain    ${text}    The Great Gatsby

I should see a 'No results found' message
    Wait For Elements State    id=no-results-message    visible
    Get Text    id=no-results-message
    Should Contain    ${text}    No results found

I am on the book details page
    New Page    ${URL}/book-details

I enter a review in the review text area
    Type Text    id=review-text-area    This is a great book!

I click on the 'Submit Review' button
    Click    id=submit-review-button

The review should be added to the book's reviews section
    Wait For Elements State    id=reviews-section    visible
    Get Text    id=reviews-section
    Should Contain    ${text}    This is a great book!

The review text area is disabled
    Set Attribute    id=review-text-area    disabled

The review should not be added to the book's reviews section
    Wait For Elements State    id=reviews-section    visible
    Get Text    id=reviews-section
    Should Not Contain    ${text}    This is a great book!
