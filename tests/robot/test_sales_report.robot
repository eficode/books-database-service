*** Settings ***
Library  Browser

*** Variables ***
${SALES_REPORT_URL}  https://example.com/sales-report

*** Test Cases ***
Display Most Sold Books
    [Documentation]  Verify that the most sold books are displayed in descending order of sales.
    [Tags]  req-GENAI-9  type-ok
    Given I am a Sales Manager
    When I access the sales report for the last week
    Then I should see a list of the most sold books in descending order of sales

Display Most Sold Books - Negative Case
    [Documentation]  Verify that the most sold books are not displayed when the sales report is not accessed correctly.
    [Tags]  req-GENAI-9  type-nok
    Given I am a Sales Manager
    And I do not access the sales report for the last week
    Then I should not see a list of the most sold books in descending order of sales

Display Least Sold Books
    [Documentation]  Verify that the least sold books are displayed in ascending order of sales.
    [Tags]  req-GENAI-9  type-ok
    Given I am a Sales Manager
    When I access the sales report for the last week
    Then I should see a list of the least sold books in ascending order of sales

Display Least Sold Books - Negative Case
    [Documentation]  Verify that the least sold books are not displayed when the sales report is not accessed correctly.
    [Tags]  req-GENAI-9  type-nok
    Given I am a Sales Manager
    And I do not access the sales report for the last week
    Then I should not see a list of the least sold books in ascending order of sales

*** Keywords ***
I am a Sales Manager
    New Browser  headless=False
    New Page  ${SALES_REPORT_URL}
    Wait For Elements State  css=div.login-form  visible
    Fill Text  css=input[name="username"]  sales_manager
    Fill Text  css=input[name="password"]  password123
    Click  css=button[type="submit"]
    Wait For Elements State  css=div.dashboard  visible

I access the sales report for the last week
    Click  css=a[href="/sales-report"]
    Wait For Elements State  css=div.sales-report  visible

I do not access the sales report for the last week
    Click  css=a[href="/home"]
    Wait For Elements State  css=div.homepage  visible

I should see a list of the most sold books in descending order of sales
    ${books}=  Get Elements  css=div.most-sold-books li
    ${sales}=  Create List
    FOR  ${book}  IN  @{books}
        ${sale}=  Get Text  ${book}  css=span.sales
        Append To List  ${sales}  ${sale}
    END
    ${sorted_sales}=  Evaluate  sorted(${sales}, reverse=True)
    Should Be True  ${sales} == ${sorted_sales}

I should not see a list of the most sold books in descending order of sales
    Wait For Elements State  css=div.most-sold-books  hidden

I should see a list of the least sold books in ascending order of sales
    ${books}=  Get Elements  css=div.least-sold-books li
    ${sales}=  Create List
    FOR  ${book}  IN  @{books}
        ${sale}=  Get Text  ${book}  css=span.sales
        Append To List  ${sales}  ${sale}
    END
    ${sorted_sales}=  Evaluate  sorted(${sales})
    Should Be True  ${sales} == ${sorted_sales}

I should not see a list of the least sold books in ascending order of sales
    Wait For Elements State  css=div.least-sold-books  hidden
