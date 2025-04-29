*** Settings ***
Documentation    This test suite verifies the functionality of viewing low-selling books report and adjusting book orders based on low-selling books.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
View Low-Selling Books Report - Successful Scenario
    [Documentation]    Verify that a bookstore owner can view a list of low-selling books and filter the report by date range and genre.
    [Tags]    req-DEV-162    type-ok
    Given I am a bookstore owner
    When I access the low-selling books report
    Then I should see a list of books that have low sales over a specified period
    And I should be able to filter the report by date range and genre

View Low-Selling Books Report With No Sales Data - Unsuccessful Scenario
    [Documentation]    Verify that a bookstore owner sees a message indicating no sales data is available when accessing the low-selling books report with no sales data.
    [Tags]    req-DEV-162    type-nok
    Given I am a bookstore owner
    When I access the low-selling books report
    And there is no sales data available
    Then I should see a message indicating that no sales data is available for the specified period

Adjust Book Orders Based on Low-Selling Books - Successful Scenario
    [Documentation]    Verify that a bookstore owner can adjust book orders based on identified low-selling books.
    [Tags]    req-DEV-162    type-ok
    Given I have identified low-selling books
    When I adjust my book orders
    Then I should be able to reduce or stop ordering the identified low-selling books

Adjust Book Orders With No Identified Low-Selling Books - Unsuccessful Scenario
    [Documentation]    Verify that a bookstore owner sees a message indicating no low-selling books to adjust orders for when no low-selling books have been identified.
    [Tags]    req-DEV-162    type-nok
    Given I have identified low-selling books
    When I adjust my book orders
    And no low-selling books have been identified
    Then I should see a message indicating that there are no low-selling books to adjust orders for

*** Keywords ***
I am a bookstore owner
    New Browser    ${URL}
    Go To    ${URL}
    Wait For Elements State    //h1[text()='Bookstore Owner Dashboard']    visible

I access the low-selling books report
    Click    //a[text()='Reports']
    Click    //a[text()='Low-Selling Books']
    Wait For Elements State    //h1[text()='Low-Selling Books Report']    visible

I should see a list of books that have low sales over a specified period
    Wait For Elements State    //table[@id='low-selling-books']    visible

I should be able to filter the report by date range and genre
    Wait For Elements State    //input[@id='date-range']    visible
    Wait For Elements State    //select[@id='genre']    visible

There is no sales data available
    # Simulate no sales data condition
    Evaluate    document.querySelector('#low-selling-books').innerHTML = '';

I should see a message indicating that no sales data is available for the specified period
    Wait For Elements State    //p[text()='No sales data available for the specified period.']    visible

I have identified low-selling books
    # Assume low-selling books are identified in the system
    Set Test Variable    ${LOW_SELLING_BOOKS_IDENTIFIED}    True

I adjust my book orders
    Click    //a[text()='Orders']
    Click    //button[text()='Adjust Orders']

I should be able to reduce or stop ordering the identified low-selling books
    Wait For Elements State    //p[text()='Orders adjusted successfully.']    visible

No low-selling books have been identified
    Set Test Variable    ${LOW_SELLING_BOOKS_IDENTIFIED}    False

I should see a message indicating that there are no low-selling books to adjust orders for
    Wait For Elements State    //p[text()='There are no low-selling books to adjust orders for.']    visible
