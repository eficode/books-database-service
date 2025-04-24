*** Settings ***
Documentation    This test suite verifies the search functionality of the BookBridge application.
Library          Browser

*** Variables ***
${BASE_URL}      https://bookbridge.example.com

*** Test Cases ***
Search by author name - successful scenario
    [Documentation]    Verify that searching by author name returns a list of books by that author.
    [Tags]    req-GENAI-228    type-ok
    I am a BookBridge customer
    I search for 'Rick Riordan'
    I should see a list of books authored by Rick Riordan
    The list should include the title, publication date, and price of each book

Search by author name - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the search cannot be completed due to a slow internet connection.
    [Tags]    req-GENAI-228    type-nok
    I am a BookBridge customer
    I have a slow internet connection
    I search for 'Rick Riordan'
    I should see an error message indicating that the search could not be completed

Search results pagination - successful scenario
    [Documentation]    Verify that pagination controls are available when search results exceed the page limit.
    [Tags]    req-GENAI-228    type-ok
    I search for 'Rick Riordan'
    The number of results exceeds the page limit
    I should be able to navigate through the results using pagination controls

Search results pagination - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when pagination controls are unavailable.
    [Tags]    req-GENAI-228    type-nok
    I search for 'Rick Riordan'
    The pagination controls are not visible
    The number of results exceeds the page limit
    I should see an error message indicating that pagination controls are unavailable

No results found - successful scenario
    [Documentation]    Verify that a message is shown when no search results are found.
    [Tags]    req-GENAI-228    type-ok
    I search for 'Rick Riordan'
    No books by Rick Riordan are found
    I should see a message indicating that no results were found

No results found - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the search functionality is down.
    [Tags]    req-GENAI-228    type-nok
    I search for 'Rick Riordan'
    The search functionality is down
    No books by Rick Riordan are found
    I should see an error message indicating that the search functionality is currently unavailable

*** Keywords ***
I am a BookBridge customer
    New Browser    headless=False
    New Page    ${BASE_URL}

I search for 'Rick Riordan'
    Click    text=Search
    Fill Text    input[name="search"]    Rick Riordan
    Press Keys    input[name="search"]    ENTER

I should see a list of books authored by Rick Riordan
    Wait For Elements State    text=Rick Riordan    visible

The list should include the title, publication date, and price of each book
    Wait For Elements State    css=.book-title    visible
    Wait For Elements State    css=.publication-date    visible
    Wait For Elements State    css=.price    visible

I have a slow internet connection
    Set Network Conditions    offline=False    latency=5000    download_throughput=50000    upload_throughput=50000

I should see an error message indicating that the search could not be completed
    Wait For Elements State    text=Error    visible

The number of results exceeds the page limit
    Wait For Elements State    css=.pagination    visible

I should be able to navigate through the results using pagination controls
    Click    css=.pagination-next
    Wait For Elements State    css=.pagination-active    visible

The pagination controls are not visible
    Wait For Elements State    css=.pagination    hidden

I should see an error message indicating that pagination controls are unavailable
    Wait For Elements State    text=Pagination Unavailable    visible

No books by Rick Riordan are found
    Wait For Elements State    text=No results found    visible

I should see a message indicating that no results were found
    Wait For Elements State    text=No results found    visible

The search functionality is down
    Set Network Conditions    offline=True

I should see an error message indicating that the search functionality is currently unavailable
    Wait For Elements State    text=Service Unavailable    visible
