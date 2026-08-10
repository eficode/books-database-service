*** Settings ***
Library  Browser
Documentation  Test suite for verifying book star ratings and sorting on Amazon web page.

*** Variables ***
${URL}  https://www.amazon.com

*** Test Cases ***
View star rating for a book
    [Documentation]  Verify that the star rating for a book is displayed prominently.
    [Tags]  req-GENAI-503  type-ok
    Given I am browsing books on the Amazon web page
    When I view the details of a book
    Then I should see the star rating for that book displayed prominently

View star rating for a book with missing data
    [Documentation]  Verify that a message is shown when star rating data is missing.
    [Tags]  req-GENAI-503  type-nok
    Given I am browsing books on the Amazon web page
    When I view the details of a book
    And the star rating data is missing
    Then I should see a message indicating that the star rating is not available

Rank books by star rating
    [Documentation]  Verify that books are ranked from highest to lowest star rating.
    [Tags]  req-GENAI-503  type-ok
    Given I am browsing books on the Amazon web page
    When I sort books by star rating
    Then the books should be ranked from highest to lowest star rating

Rank books by star rating with no ratings available
    [Documentation]  Verify that a message is shown when no ratings are available to sort.
    [Tags]  req-GENAI-503  type-nok
    Given I am browsing books on the Amazon web page
    When I sort books by star rating
    And no books have star ratings
    Then I should see a message indicating that there are no ratings available to sort

*** Keywords ***
I am browsing books on the Amazon web page
    New Page  ${URL}
    Click  text=Books

I view the details of a book
    Click  css=.s-title-instructions-style

I should see the star rating for that book displayed prominently
    Wait For Elements State  css=.a-icon-alt  visible
    Get Element States  css=.a-icon-alt

The star rating data is missing
    # Simulate missing star rating data
    Evaluate  document.querySelector('.a-icon-alt').remove()  window.document

I should see a message indicating that the star rating is not available
    Wait For Elements State  text=Star rating not available  visible
    Get Element States  text=Star rating not available

I sort books by star rating
    Click  css=.a-dropdown-prompt
    Click  text=Avg. Customer Review

The books should be ranked from highest to lowest star rating
    Wait For Elements State  css=.s-main-slot .s-result-item  visible
    ${ratings}=  Get Text  css=.a-icon-alt
    Should Be True  ${ratings}[0] > ${ratings}[-1]

No books have star ratings
    # Simulate no books having star ratings
    Evaluate  document.querySelectorAll('.a-icon-alt').forEach(el => el.remove())  window.document

I should see a message indicating that there are no ratings available to sort
    Wait For Elements State  text=No ratings available to sort  visible
    Get Element States  text=No ratings available to sort
