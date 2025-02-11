*** Settings ***
Documentation    This test suite verifies the daily email report functionality for BookBridge Sales Managers.
Library           Browser

*** Variables ***
${EMAIL_SERVICE_URL}    http://emailservice.bookbridge.com
${REPORT_TIME}          08:00 AM

*** Test Cases ***
Receive daily email report - successful scenario
    [Documentation]    Verify that the sales manager receives the daily email report at 8:00 AM
    [Tags]    req-GENAI-84    type-ok
    Given I am a BookBridge Sales Manager
    When it is 8:00 AM
    Then I should receive an email report of the most sold books categorized by genre

Receive daily email report - unsuccessful scenario
    [Documentation]    Verify that the sales manager does not receive the daily email report when the email service is down
    [Tags]    req-GENAI-84    type-nok
    Given I am a BookBridge Sales Manager
    When it is 8:00 AM
    And the email service is down
    Then I should not receive an email report of the most sold books categorized by genre

Email report content - successful scenario
    [Documentation]    Verify that the received email report lists the most sold books categorized by genre and includes sales volumes
    [Tags]    req-GENAI-84    type-ok
    Given I have received the daily email report
    Then the report should list the most sold books categorized by genre
    And the report should include sales volumes for each category

Email report content - unsuccessful scenario
    [Documentation]    Verify that the received email report does not list the most sold books or sales volumes when the sales data is incomplete
    [Tags]    req-GENAI-84    type-nok
    Given I have received the daily email report
    And the sales data is incomplete
    Then the report should not list the most sold books categorized by genre
    And the report should not include sales volumes for each category

*** Keywords ***
I am a BookBridge Sales Manager
    # Simulate login or identification as a BookBridge Sales Manager
    Open Browser    ${EMAIL_SERVICE_URL}    chromium
    Log In As Sales Manager

it is 8:00 AM
    # Simulate the time being 8:00 AM
    Wait Until Time Is    ${REPORT_TIME}

I should receive an email report of the most sold books categorized by genre
    # Verify that the email report is received
    Email Should Be Received    subject=Daily Sales Report

I should not receive an email report of the most sold books categorized by genre
    # Verify that the email report is not received
    Email Should Not Be Received    subject=Daily Sales Report

email service is down
    # Simulate the email service being down
    Simulate Email Service Down

I have received the daily email report
    # Verify that the email report is received
    Email Should Be Received    subject=Daily Sales Report

report should list the most sold books categorized by genre
    # Verify the report lists the most sold books by genre
    Report Should List Most Sold Books By Genre

report should include sales volumes for each category
    # Verify the report includes sales volumes for each category
    Report Should Include Sales Volumes

sales data is incomplete
    # Simulate incomplete sales data
    Simulate Incomplete Sales Data

report should not list the most sold books categorized by genre
    # Verify the report does not list the most sold books by genre
    Report Should Not List Most Sold Books By Genre

report should not include sales volumes for each category
    # Verify the report does not include sales volumes
    Report Should Not Include Sales Volumes
