*** Settings ***
Documentation    Test suite for BookBridge search functionality
Library          Browser

*** Variables ***
${BOOKBRIDGE_URL}    https://bookbridge.example.com

*** Test Cases ***
Search for similar books based on user preferences - successful scenario
    [Documentation]    Given I am a logged-in BookBridge customer
    ...                When I search for books similar to the ones I have loved
    ...                Then I should see a list of books that match my preferences
    [Tags]    req-GENAI-33    type-ok
    I am a logged-in BookBridge customer
    I search for books similar to the ones I have loved
    I should see a list of books that match my preferences

Search for similar books based on user preferences - unsuccessful scenario
    [Documentation]    Given I am a logged-in BookBridge customer
    ...                When I search for books similar to the ones I have loved
    ...                And the search query is invalid
    ...                Then I should see an error message indicating the search failed
    [Tags]    req-GENAI-33    type-nok
    I am a logged-in BookBridge customer
    I search for books similar to the ones I have loved
    The search query is invalid
    I should see an error message indicating the search failed

No similar books found - successful scenario
    [Documentation]    Given I am a logged-in BookBridge customer
    ...                When I search for books similar to the ones I have loved
    ...                And no similar books are found
    ...                Then I should see a message indicating no similar books are available
    [Tags]    req-GENAI-33    type-ok
    I am a logged-in BookBridge customer
    I search for books similar to the ones I have loved
    No similar books are found
    I should see a message indicating no similar books are available

No similar books found - unsuccessful scenario
    [Documentation]    Given I am a logged-in BookBridge customer
    ...                When I search for books similar to the ones I have loved
    ...                And no similar books are found
    ...                And there is a system error
    ...                Then I should see an error message indicating the search failed
    [Tags]    req-GENAI-33    type-nok
    I am a logged-in BookBridge customer
    I search for books similar to the ones I have loved
    No similar books are found
    There is a system error
    I should see an error message indicating the search failed

*** Keywords ***
I am a logged-in BookBridge customer
    New Page    ${BOOKBRIDGE_URL}
    Click    text=Login
    Fill Text    id=username    my_username
    Fill Text    id=password    my_password
    Click    id=loginButton
    Wait For Elements State    id=profileIcon    visible

I search for books similar to the ones I have loved
    Click    text=Search
    Fill Text    id=searchBox    books I have loved
    Click    id=searchButton
    Wait For Elements State    id=searchResults    visible

The search query is invalid
    Fill Text    id=searchBox    invalid_query
    Click    id=searchButton
    Wait For Elements State    id=searchResults    visible

I should see a list of books that match my preferences
    Wait For Elements State    css=.book-item    visible
    Browser.Get Element States    css=.book-item

I should see an error message indicating the search failed
    Wait For Elements State    css=.error-message    visible
    Browser.Get Element States    css=.error-message

No similar books are found
    Wait For Elements State    css=.no-results-message    visible
    Browser.Get Element States    css=.no-results-message

I should see a message indicating no similar books are available
    Wait For Elements State    css=.no-results-message    visible
    Browser.Get Element States    css=.no-results-message

There is a system error
    # Simulate a system error, e.g., by causing a timeout or server error
    Wait For Elements State    css=.system-error-message    visible
    Browser.Get Element States    css=.system-error-message
