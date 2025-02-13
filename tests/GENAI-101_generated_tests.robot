*** Settings ***
Documentation    This test suite verifies the generation and delivery of sales reports for Bookbridge Sales Managers.
Library          Browser

*** Variables ***
${EMAIL}         sales.manager@bookbridge.com
${REPORT_TIME}   08:00 AM
${WEB_PORTAL}    https://bookbridge.com/portal

*** Test Cases ***
Generate and send report - successful scenario
    [Documentation]    Verify that the report is generated and sent successfully.
    [Tags]    req-GENAI-99    type-ok
    I am a Bookbridge Sales Manager
    system generates the report of the top 10 least sold books at 8.00 AM
    report should be sent to my email
    report should include the book titles, authors, and sales numbers

Generate and send report - unsuccessful scenario
    [Documentation]    Verify that the report is not sent when the email service is down.
    [Tags]    req-GENAI-99    type-nok
    I am a Bookbridge Sales Manager
    system generates the report of the top 10 least sold books at 8.00 AM
    email service is down
    report should not be sent to my email
    should receive a notification about the failure

Verify email receipt - successful scenario
    [Documentation]    Verify that the report is received and readable.
    [Tags]    req-GENAI-99    type-ok
    I am a Bookbridge Sales Manager
    check my email
    should see the report of the top 10 least sold books
    report should be in a readable format
    can identify the least sold author from the report

Verify email receipt - unsuccessful scenario
    [Documentation]    Verify that the report is available in the web portal when not received via email.
    [Tags]    req-GENAI-99    type-nok
    I am a Bookbridge Sales Manager
    check my email
    email is not received
    should see the report of the top 10 least sold books in web portal
    should receive a notification about the missing report

*** Keywords ***
I am a Bookbridge Sales Manager
    New Page    ${WEB_PORTAL}
    Login    sales.manager@bookbridge.com    password

system generates the report of the top 10 least sold books at 8.00 AM
    Wait Until    ${REPORT_TIME}
    Generate Report

report should be sent to my email
    Wait Until Email Received    ${EMAIL}    subject=Top 10 Least Sold Books Report

report should include the book titles, authors, and sales numbers
    Check Email Content    ${EMAIL}    subject=Top 10 Least Sold Books Report    body=includes book titles, authors, sales numbers

email service is down
    Simulate Email Service Down

report should not be sent to my email
    Wait Until Email Not Received    ${EMAIL}    subject=Top 10 Least Sold Books Report

should receive a notification about the failure
    Check Notification    ${EMAIL}    subject=Report Generation Failure

check my email
    Open Email Client    ${EMAIL}

should see the report of the top 10 least sold books
    Check Email Content    ${EMAIL}    subject=Top 10 Least Sold Books Report

report should be in a readable format
    Validate Report Format    ${EMAIL}    subject=Top 10 Least Sold Books Report

can identify the least sold author from the report
    Identify Least Sold Author    ${EMAIL}    subject=Top 10 Least Sold Books Report

email is not received
    Wait Until Email Not Received    ${EMAIL}    subject=Top 10 Least Sold Books Report

should see the report of the top 10 least sold books in web portal
    New Page    ${WEB_PORTAL}
    Login    sales.manager@bookbridge.com    password
    Navigate to Reports Section
    Check Report Availability    Top 10 Least Sold Books

should receive a notification about the missing report
    Check Notification    ${EMAIL}    subject=Missing Report Notification
