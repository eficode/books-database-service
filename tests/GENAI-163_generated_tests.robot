*** Settings ***
Documentation    This test suite verifies the functionality of viewing top-selling books by category.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
View top-selling books by category - successful scenario
    [Documentation]    Verify that a registered user can view top-selling books by category.
    [Tags]    req-GENAI-161    type-ok
    I am a registered user
    I navigate to the 'Top-Selling Books' section
    I select a specific category
    I should see a list of top-selling books in that category
    The list should include the book title, author, and sales rank

View top-selling books by category with invalid category - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when an invalid category is selected.
    [Tags]    req-GENAI-161    type-nok
    I am a registered user
    I navigate to the 'Top-Selling Books' section
    I select an invalid category
    I should see an error message indicating that the category is invalid
    No list of top-selling books should be displayed

View top-selling books by category without authentication - unsuccessful scenario
    [Documentation]    Verify that a non-registered user is redirected to the login page.
    [Tags]    req-GENAI-161    type-nok
    I am not a registered user
    I navigate to the 'Top-Selling Books' section
    I should be redirected to the login page
    I should not see the 'Top-Selling Books' section

View top-selling books by category with API failure - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when the sales data API is down.
    [Tags]    req-GENAI-161    type-nok
    I am a registered user
    I navigate to the 'Top-Selling Books' section
    I select a specific category
    The sales data API is down
    I should see an error message indicating that the service is unavailable
    No list of top-selling books should be displayed

View top-selling books by category with slow response - unsuccessful scenario
    [Documentation]    Verify that a message is displayed when the response time exceeds 2 seconds.
    [Tags]    req-GENAI-161    type-nok
    I am a registered user
    I navigate to the 'Top-Selling Books' section
    I select a specific category
    The response time exceeds 2 seconds
    I should see a message indicating that the request is taking longer than expected
    The list of top-selling books should eventually be displayed

*** Keywords ***
I am a registered user
    New Page    ${URL}/login
    Fill Text    username    user
    Fill Text    password    pass
    Click    login_button
    Wait For Elements State    top_selling_books_section    visible

I am not a registered user
    New Page    ${URL}/logout
    Wait For Elements State    login_page    visible

I navigate to the 'Top-Selling Books' section
    Click    top_selling_books_link
    Wait For Elements State    top_selling_books_section    visible

I select a specific category
    Click    category_dropdown
    Click    specific_category_option
    Wait For Elements State    books_list    visible

I select an invalid category
    Click    category_dropdown
    Click    invalid_category_option
    Wait For Elements State    error_message    visible

I should see a list of top-selling books in that category
    Wait For Elements State    books_list    visible

The list should include the book title, author, and sales rank
    Get Text    book_title    ${book_title}
    Get Text    book_author    ${book_author}
    Get Text    book_sales_rank    ${book_sales_rank}
    Should Be Equal    ${book_title}    expected_title
    Should Be Equal    ${book_author}    expected_author
    Should Be Equal    ${book_sales_rank}    expected_sales_rank

I should see an error message indicating that the category is invalid
    Wait For Elements State    error_message    visible

No list of top-selling books should be displayed
    Wait For Elements State    books_list    hidden

I should be redirected to the login page
    Wait For Elements State    login_page    visible

I should not see the 'Top-Selling Books' section
    Wait For Elements State    top_selling_books_section    hidden

The sales data API is down
    # Simulate API down condition
    Set Offline

I should see an error message indicating that the service is unavailable
    Wait For Elements State    service_unavailable_message    visible

The response time exceeds 2 seconds
    # Simulate slow response
    Emulate Network Conditions    offline    1000    2000

I should see a message indicating that the request is taking longer than expected
    Wait For Elements State    slow_response_message    visible

The list of top-selling books should eventually be displayed
    Wait For Elements State    books_list    visible
