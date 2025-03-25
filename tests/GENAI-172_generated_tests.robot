*** Settings ***
Documentation    Test suite for verifying the search functionality for top-selling Sci-Fi books.
Library          Browser

*** Variables ***
${URL}           http://bookbridge.com

*** Test Cases ***
Search for top-selling Sci-Fi books - successful scenario
    [Documentation]    Verify that a list of top-selling Sci-Fi books is displayed and sorted by sales figures.
    [Tags]    req-GENAI-170    type-ok
    Given I am a BookBridge Sales Person
    When I search for top-selling Sci-Fi books
    Then I should see a list of the top-selling Sci-Fi books
    And the list should be sorted by sales figures

Search for top-selling Sci-Fi books with no results - unsuccessful scenario
    [Documentation]    Verify that a message is displayed when no top-selling Sci-Fi books are available.
    [Tags]    req-GENAI-170    type-nok
    Given I am a BookBridge Sales Person
    When I search for top-selling Sci-Fi books
    And there are no top-selling Sci-Fi books available
    Then I should see a message indicating that no top-selling Sci-Fi books are available

Search for top-selling Sci-Fi books with API failure - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when the API endpoint is down.
    [Tags]    req-GENAI-170    type-nok
    Given I am a BookBridge Sales Person
    When I search for top-selling Sci-Fi books
    And the API endpoint is down
    Then I should see an error message indicating that the search could not be completed

Search for top-selling Sci-Fi books with slow response - unsuccessful scenario
    [Documentation]    Verify that a message is displayed when the search takes longer than expected.
    [Tags]    req-GENAI-170    type-nok
    Given I am a BookBridge Sales Person
    When I search for top-selling Sci-Fi books
    And the search results take longer than 2 seconds to load
    Then I should see a message indicating that the search is taking longer than expected

*** Keywords ***
I am a BookBridge Sales Person
    New Browser    headless=False
    New Page    ${URL}
    Wait For Elements State    css=selector-for-login-button    visible
    Click    css=selector-for-login-button
    Fill Text    css=selector-for-username-field    my_username
    Fill Text    css=selector-for-password-field    my_password
    Click    css=selector-for-submit-button
    Wait For Elements State    css=selector-for-dashboard    visible

I search for top-selling Sci-Fi books
    Click    css=selector-for-search-bar
    Fill Text    css=selector-for-search-bar    top-selling Sci-Fi books
    Click    css=selector-for-search-button

I should see a list of the top-selling Sci-Fi books
    Wait For Elements State    css=selector-for-results-list    visible
    ${results}=    Get Elements    css=selector-for-results-list-item
    Should Be True    ${results} != []

The list should be sorted by sales figures
    ${results}=    Get Elements    css=selector-for-results-list-item
    ${sales_figures}=    Evaluate    [result.get_attribute('data-sales') for result in ${results}]
    ${sorted_sales_figures}=    Evaluate    sorted(${sales_figures}, reverse=True)
    Should Be Equal    ${sales_figures}    ${sorted_sales_figures}

There are no top-selling Sci-Fi books available
    Focus    css=selector-for-search-bar
    Press Keys    css=selector-for-search-bar    CONTROL + a
    Press Keys    css=selector-for-search-bar    BACKSPACE
    Fill Text    css=selector-for-search-bar    no-results-query
    Click    css=selector-for-search-button
    Wait For Elements State    css=selector-for-no-results-message    visible

I should see a message indicating that no top-selling Sci-Fi books are available
    Wait For Elements State    css=selector-for-no-results-message    visible
    ${message}=    Get Text    css=selector-for-no-results-message
    Should Be Equal    ${message}    No top-selling Sci-Fi books are available.

The API endpoint is down
    # Simulate API failure by navigating to a mock failure page or using a mock server
    Go To    ${URL}/mock-api-failure

I should see an error message indicating that the search could not be completed
    Wait For Elements State    css=selector-for-error-message    visible
    ${message}=    Get Text    css=selector-for-error-message
    Should Be Equal    ${message}    The search could not be completed. Please try again later.

The search results take longer than 2 seconds to load
    # Simulate slow response by adding a delay in the search results
    Evaluate    window.setTimeout(function(){}, 3000)

I should see a message indicating that the search is taking longer than expected
    Wait For Elements State    css=selector-for-slow-response-message    visible
    ${message}=    Get Text    css=selector-for-slow-response-message
    Should Be Equal    ${message}    The search is taking longer than expected. Please wait.
