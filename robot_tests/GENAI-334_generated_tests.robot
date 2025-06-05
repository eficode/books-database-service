*** Settings ***
Documentation    This test suite verifies the functionality of viewing and filtering least sold books.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
View least sold books - successful scenario
    [Documentation]    Verify that a sales manager can view a list of least sold books sorted by the least number of sales.
    [Tags]    req-GENAI-332    type-ok
    I am a sales manager
    access the search functionality for least sold books
    should see a list of books sorted by the least number of sales

View least sold books with no results - unsuccessful scenario
    [Documentation]    Verify that a sales manager sees a message indicating no results found when there are no books with sales data.
    [Tags]    req-GENAI-332    type-nok
    I am a sales manager
    access the search functionality for least sold books
    there are no books with sales data
    should see a message indicating no results found

Filter least sold books by date range - successful scenario
    [Documentation]    Verify that a sales manager can filter least sold books by a valid date range.
    [Tags]    req-GENAI-332    type-ok
    I am a sales manager
    apply a date range filter
    should see a list of least sold books within that date range

Filter least sold books by invalid date range - unsuccessful scenario
    [Documentation]    Verify that a sales manager sees an error message when applying an invalid date range filter.
    [Tags]    req-GENAI-332    type-nok
    I am a sales manager
    apply a date range filter invalid
    should see an error message indicating the date range is invalid

*** Keywords ***
I am a sales manager
    New Browser    headless=False
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    sales_manager
    Fill Text    id=password    password123
    Click    text=Submit

access the search functionality for least sold books
    Click    text=Least Sold Books

should see a list of books sorted by the least number of sales
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list
    Should Contain    ${text}    Least Sold Books

there are no books with sales data
    # Simulate no data scenario
    Evaluate    document.querySelector('.book-list').innerHTML = ''

should see a message indicating no results found
    Wait For Elements State    css=.no-results    visible
    Get Text    css=.no-results
    Should Contain    ${text}    No results found

apply a date range filter
    Click    text=Date Range
    Fill Text    id=start_date    2023-01-01
    Fill Text    id=end_date    2023-12-31
    Click    text=Apply

should see a list of least sold books within that date range
    Wait For Elements State    css=.book-list    visible
    Get Text    css=.book-list
    Should Contain    ${text}    Least Sold Books

apply a date range filter invalid
    Click    text=Date Range
    Fill Text    id=start_date    invalid-date
    Fill Text    id=end_date    invalid-date
    Click    text=Apply

should see an error message indicating the date range is invalid
    Wait For Elements State    css=.error-message    visible
    Get Text    css=.error-message
    Should Contain    ${text}    Invalid date range
