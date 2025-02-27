*** Settings ***
Documentation    This test suite verifies the daily sales report email functionality and the accuracy of the sales data within the email.
Library           Browser

*** Variables ***
${EMAIL_SERVICE_URL}    http://emailservice.example.com
${SALES_REPORT_EMAIL}   salesreport@example.com
${SALES_MANAGER}        salesmanager@example.com
${CURRENT_TIME}         08:00 AM EET

*** Test Cases ***
Receive Daily Sales Report Email - Successful Scenario
    [Documentation]    Verify that the Sales Manager receives the daily sales report email at 8:00 AM EET.
    [Tags]    req-GENAI-132    type-ok
    I am a Sales Manager
    it is 8:00 AM EET
    I should receive an email with a report of the most sold books

Receive Daily Sales Report Email - Unsuccessful Scenario
    [Documentation]    Verify that the Sales Manager does not receive the daily sales report email when the email service is down.
    [Tags]    req-GENAI-132    type-nok
    I am a Sales Manager
    it is 8:00 AM EET
    the email service is down
    I should not receive an email with a report of the most sold books

Email Contains Correct Sales Data - Successful Scenario
    [Documentation]    Verify that the sales report email contains accurate and up-to-date sales data.
    [Tags]    req-GENAI-132    type-ok
    I have received the sales report email
    I open the email
    the email should contain a list of the most and least sold books
    the data should be accurate and up-to-date

Email Contains Correct Sales Data - Unsuccessful Scenario
    [Documentation]    Verify that the sales report email does not contain outdated sales data.
    [Tags]    req-GENAI-132    type-nok
    I have received the sales report email
    I open the email
    the sales data is outdated
    the email should not contain a list of the most and least sold books
    the data should not be accurate and up-to-date

*** Keywords ***
I am a Sales Manager
    New Browser    chromium
    New Page    ${EMAIL_SERVICE_URL}
    Log In    ${SALES_MANAGER}

it is 8:00 AM EET
    Sleep Until Time    ${CURRENT_TIME}

I should receive an email with a report of the most sold books
    Wait For    Email To Be Received    ${SALES_REPORT_EMAIL}    subject=Daily Sales Report
    Email Should Be Received    ${SALES_REPORT_EMAIL}

I should not receive an email with a report of the most sold books
    Wait For    Email To Be Received    ${SALES_REPORT_EMAIL}    subject=Daily Sales Report    timeout=10s
    Email Should Not Be Received    ${SALES_REPORT_EMAIL}

the email service is down
    Simulate Service Down

I have received the sales report email
    Wait For    Email To Be Received    ${SALES_REPORT_EMAIL}    subject=Daily Sales Report
    Email Should Be Received    ${SALES_REPORT_EMAIL}

I open the email
    Open Email    ${SALES_REPORT_EMAIL}

the email should contain a list of the most and least sold books
    Email Should Contain Text    ${SALES_REPORT_EMAIL}    Most Sold Books
    Email Should Contain Text    ${SALES_REPORT_EMAIL}    Least Sold Books

the data should be accurate and up-to-date
    Verify Data Accuracy    ${SALES_REPORT_EMAIL}

the sales data is outdated
    Simulate Outdated Data    ${SALES_REPORT_EMAIL}

the email should not contain a list of the most and least sold books
    Email Should Not Contain Text    ${SALES_REPORT_EMAIL}    Most Sold Books
    Email Should Not Contain Text    ${SALES_REPORT_EMAIL}    Least Sold Books

the data should not be accurate and up-to-date
    Verify Data Inaccuracy    ${SALES_REPORT_EMAIL}
