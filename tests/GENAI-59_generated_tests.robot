*** Settings ***
Documentation    Test suite for searching books by color
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search books by a specific color - successful scenario
    [Documentation]    Search books by a specific color - successful scenario
    [Tags]    req-GENAI-57    type-ok
    Given I am a book seller
    When I search for books by the color 'red'
    Then I should see a list of books that have the color 'red' in their attributes

Search books by a specific color - unsuccessful scenario
    [Documentation]    Search books by a specific color - unsuccessful scenario
    [Tags]    req-GENAI-57    type-nok
    Given I am a book seller
    And I am not connected to the internet
    When I search for books by the color 'red'
    Then I should see an error message indicating that the search could not be completed

No books found for a specific color - successful scenario
    [Documentation]    No books found for a specific color - successful scenario
    [Tags]    req-GENAI-57    type-ok
    Given I am a book seller
    When I search for books by the color 'purple'
    Then I should see a message indicating that no books were found with the color 'purple'

No books found for a specific color - unsuccessful scenario
    [Documentation]    No books found for a specific color - unsuccessful scenario
    [Tags]    req-GENAI-57    type-nok
    Given I am a book seller
    And the backend API is down
    When I search for books by the color 'purple'
    Then I should see an error message indicating that the search could not be completed

*** Keywords ***
I am a book seller
    New Browser    headless=False
    New Page
    Go To    ${URL}

I am not connected to the internet
    Set Offline

I search for books by the color ${color}
    Click    id=search-bar
    Fill Text    id=search-bar    ${color}
    Click    id=search-button

I should see a list of books that have the color ${color} in their attributes
    Wait For Elements State    css=.book-item    visible
    ${book_items}=    Get Text    css=.book-item
    Should Contain    ${book_items}    ${color}

I should see an error message indicating that the search could not be completed
    Wait For Elements State    css=.error-message    visible
    ${error_message}=    Get Text    css=.error-message
    Should Be Equal    ${error_message}    Search could not be completed

I should see a message indicating that no books were found with the color ${color}
    Wait For Elements State    css=.no-results-message    visible
    ${no_results_message}=    Get Text    css=.no-results-message
    Should Be Equal    ${no_results_message}    No books found with the color ${color}

The backend API is down
    Set Offline
