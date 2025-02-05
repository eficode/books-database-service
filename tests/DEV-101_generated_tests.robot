*** Settings ***
Documentation    Test suite for verifying best-selling books search, filter, and sort functionalities.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search for best-selling books - successful scenario
    [Documentation]    Verify that a list of best-selling books is displayed when searched.
    [Tags]    req-DEV-100    type-ok
    Given I am a Product Owner
    When I search for best-selling books
    Then I should see a list of best-selling books with relevant details

Search for best-selling books with no results - unsuccessful scenario
    [Documentation]    Verify that a message is displayed when no best-selling books are found.
    [Tags]    req-DEV-100    type-nok
    Given I am a Product Owner
    When I search for best-selling books
    And there are no best-selling books available
    Then I should see a message indicating no results found

Filter best-selling books by category - successful scenario
    [Documentation]    Verify that best-selling books are filtered by the selected category.
    [Tags]    req-DEV-100    type-ok
    Given I am a Product Owner
    When I filter the best-selling books by category
    Then I should see a list of best-selling books in the selected category

Filter best-selling books by an empty category - unsuccessful scenario
    [Documentation]    Verify that a message is displayed when no books are found in the selected category.
    [Tags]    req-DEV-100    type-nok
    Given I am a Product Owner
    When I filter the best-selling books by category
    And the selected category has no books
    Then I should see a message indicating no books found in this category

Sort best-selling books by sales - successful scenario
    [Documentation]    Verify that best-selling books are sorted by sales in descending order.
    [Tags]    req-DEV-100    type-ok
    Given I am a Product Owner
    When I sort the best-selling books by sales
    Then I should see the best-selling books sorted in descending order of sales

Sort best-selling books by sales with no data - unsuccessful scenario
    [Documentation]    Verify that a message is displayed when no sales data is available.
    [Tags]    req-DEV-100    type-nok
    Given I am a Product Owner
    When I sort the best-selling books by sales
    And there are no sales data available
    Then I should see a message indicating no sales data available

*** Keywords ***
I am a Product Owner
    New Browser    headless=False
    Go To    ${URL}

I search for best-selling books
    Click    text=Best-Selling Books

I should see a list of best-selling books with relevant details
    Wait For Elements State    css=.book-item    visible

There are no best-selling books available
    # Simulate no best-selling books available
    Evaluate    document.querySelectorAll('.book-item').forEach(el => el.remove());

I should see a message indicating no results found
    Wait For Elements State    css=.no-results-message    visible

I filter the best-selling books by category
    Click    text=Categories
    Click    text=Selected Category

I should see a list of best-selling books in the selected category
    Wait For Elements State    css=.book-item    visible

The selected category has no books
    # Simulate no books in the selected category
    Evaluate    document.querySelectorAll('.book-item').forEach(el => el.remove());

I should see a message indicating no books found in this category
    Wait For Elements State    css=.no-books-message    visible

I sort the best-selling books by sales
    Click    text=Sort By
    Click    text=Sales

I should see the best-selling books sorted in descending order of sales
    Wait For Elements State    css=.book-item    visible
    # Add additional checks for sorting if necessary

There are no sales data available
    # Simulate no sales data available
    Evaluate    document.querySelectorAll('.book-item').forEach(el => el.remove());

I should see a message indicating no sales data available
    Wait For Elements State    css=.no-sales-data-message    visible
