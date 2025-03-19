*** Settings ***
Documentation    Test suite verifying book synopsis visibility and length.
Library          Browser

*** Variables ***
${BOOK_DETAILS_URL}    https://example.com/book-details

*** Test Cases ***
View book synopsis - successful scenario
    [Documentation]    Verify that the book synopsis is visible on the book details page.
    [Tags]    req-GENAI-150    type-ok
    Given I am on the book details page
    When I look at the book information
    Then I should see a synopsis of the book

View book synopsis - unsuccessful scenario
    [Documentation]    Verify that no synopsis is shown when book information is unavailable.
    [Tags]    req-GENAI-150    type-nok
    Given I am on the book details page
    And the book information is not available
    When I look at the book information
    Then I should not see a synopsis of the book

Synopsis length - successful scenario
    [Documentation]    Verify that the book synopsis is concise and informative, not exceeding 500 words.
    [Tags]    req-GENAI-150    type-ok
    Given I am viewing a book synopsis
    When the synopsis is displayed
    Then it should be concise and informative, not exceeding 500 words

Synopsis length - unsuccessful scenario
    [Documentation]    Verify that a synopsis exceeding 500 words is not considered concise and informative.
    [Tags]    req-GENAI-150    type-nok
    Given I am viewing a book synopsis
    And the synopsis exceeds 500 words
    When the synopsis is displayed
    Then it should not be considered concise and informative

*** Keywords ***
I am on the book details page
    New Page    ${BOOK_DETAILS_URL}

I look at the book information
    Wait For Elements State    //div[@class='book-info']    visible

I should see a synopsis of the book
    Wait For Elements State    //div[@class='synopsis']    visible

The book information is not available
    Evaluate    document.querySelector("div.book-info").remove()

I should not see a synopsis of the book
    Wait For Elements State    //div[@class='synopsis']    hidden

I am viewing a book synopsis
    Wait For Elements State    //div[@class='synopsis']    visible

The synopsis is displayed
    Wait For Elements State    //div[@class='synopsis']    visible

It should be concise and informative, not exceeding 500 words
    ${text}=    Get Text    //div[@class='synopsis']
    Length Should Be    ${text}    500    maximum

The synopsis exceeds 500 words
    Evaluate    document.querySelector("div.synopsis").innerText = "${LONG_TEXT}"

It should not be considered concise and informative
    ${text}=    Get Text    //div[@class='synopsis']
    Length Should Be    ${text}    500    minimum
