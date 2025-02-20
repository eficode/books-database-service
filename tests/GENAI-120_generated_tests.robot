*** Settings ***
Documentation    This test suite verifies the search functionality for best-selling books in different languages on the BookBridge Solution.
Library          Browser

*** Variables ***
${URL}           https://bookbridge.example.com
${SUPPORTED_LANGUAGE}    English
${NON_SUPPORTED_LANGUAGE}    Klingon

*** Test Cases ***
Search for best-selling books in a specific language
    [Documentation]    Verify that the user can search for best-selling books in a supported language.
    [Tags]    req-GENAI-118    type-ok
    Given I am a BookBridge Solution end user
    When I search for best-selling books in my preferred language
    Then I should see a list of best-selling books available in that language

Search for best-selling books in a non-supported language
    [Documentation]    Verify that the user receives an error message when searching for best-selling books in a non-supported language.
    [Tags]    req-GENAI-118    type-nok
    Given I am a BookBridge Solution end user
    When I search for best-selling books in a non-supported language
    Then I should see a message indicating that the language is not supported

*** Keywords ***
I am a BookBridge Solution end user
    New Browser    headless=False
    New Page    ${URL}

I search for best-selling books in my preferred language
    Click    text=Search
    Fill Text    input[name="language"]    ${SUPPORTED_LANGUAGE}
    Click    text=Submit

I search for best-selling books in a non-supported language
    Click    text=Search
    Fill Text    input[name="language"]    ${NON_SUPPORTED_LANGUAGE}
    Click    text=Submit

I should see a list of best-selling books available in that language
    Wait For Elements State    text=Best-Selling Books    visible

I should see a message indicating that the language is not supported
    Wait For Elements State    text=Language not supported    visible
