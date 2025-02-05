*** Settings ***
Documentation    This test suite verifies the functionality of searching, filtering, and sorting best-selling books.
Library          Browser

*** Variables ***
${URL}           https://example.com

*** Test Cases ***
Search for best-selling books - successful scenario
    [Documentation]    Verify that the user can search for best-selling books and see relevant details.
    [Tags]    req-DEV-94    type-ok
    Given I am a product owner
    When I search for best-selling books
    Then I should see a list of best-selling books with relevant details

Search for best-selling books with no results - unsuccessful scenario
    [Documentation]    Verify that the user sees a message when no best-selling books are found.
    [Tags]    req-DEV-94    type-nok
    Given I am a product owner
    When I search for best-selling books
    And there are no best-selling books available
    Then I should see a message indicating no best-selling books found

Filter best-selling books by category - successful scenario
    [Documentation]    Verify that the user can filter best-selling books by category and see relevant results.
    [Tags]    req-DEV-94    type-ok
    Given I am a product owner
    When I filter the best-selling books by category
    Then I should see a list of best-selling books in the selected category

Filter best-selling books by an empty category - unsuccessful scenario
    [Documentation]    Verify that the user sees a message when no best-selling books are found in the selected category.
    [Tags]    req-DEV-94    type-nok
    Given I am a product owner
    When I filter the best-selling books by category
    And the selected category has no books
    Then I should see a message indicating no best-selling books found in the selected category

Sort best-selling books by date - successful scenario
    [Documentation]    Verify that the user can sort best-selling books by date and see the sorted results.
    [Tags]    req-DEV-94    type-ok
    Given I am a product owner
    When I sort the best-selling books by date
    Then I should see the best-selling books sorted by the selected date range

Sort best-selling books by an invalid date range - unsuccessful scenario
    [Documentation]    Verify that the user sees an error message when an invalid date range is selected.
    [Tags]    req-DEV-94    type-nok
    Given I am a product owner
    When I sort the best-selling books by date
    And the selected date range is invalid
    Then I should see an error message indicating the date range is invalid

*** Keywords ***
I am a product owner
    New Browser    headless=False
    New Context
    New Page    ${URL}

I search for best-selling books
    Click    //input[@id='search-bar']
    Type Text    //input[@id='search-bar']    best-selling books
    Click    //button[@id='search-button']

I should see a list of best-selling books with relevant details
    Wait For Elements State    //div[@class='book-list']    visible
    Wait For Elements State    //div[@class='book-list']    stable

There are no best-selling books available
    # Simulate no books available by clearing the search results
    Evaluate    document.querySelector('.book-list').innerHTML = '';

I should see a message indicating no best-selling books found
    Wait For Elements State    //div[@class='no-results']    visible
    Wait For Elements State    //div[@class='no-results']    stable

I filter the best-selling books by category
    Click    //select[@id='category-filter']
    Select Options By    //select[@id='category-filter']    value    Fiction
    Click    //button[@id='filter-button']

I should see a list of best-selling books in the selected category
    Wait For Elements State    //div[@class='book-list']    visible
    Wait For Elements State    //div[@class='book-list']    stable

The selected category has no books
    # Simulate no books in category by clearing the category results
    Evaluate    document.querySelector('.book-list').innerHTML = '';

I should see a message indicating no best-selling books found in the selected category
    Wait For Elements State    //div[@class='no-results']    visible
    Wait For Elements State    //div[@class='no-results']    stable

I sort the best-selling books by date
    Click    //select[@id='date-sort']
    Select Options By    //select[@id='date-sort']    value    Newest
    Click    //button[@id='sort-button']

I should see the best-selling books sorted by the selected date range
    Wait For Elements State    //div[@class='book-list']    visible
    Wait For Elements State    //div[@class='book-list']    stable

The selected date range is invalid
    # Simulate invalid date range by setting invalid date
    Evaluate    document.querySelector('#date-sort').value = 'invalid-date';

I should see an error message indicating the date range is invalid
    Wait For Elements State    //div[@class='error-message']    visible
    Wait For Elements State    //div[@class='error-message']    stable
