*** Settings ***
Documentation    This test suite verifies the monthly book delivery feature for registered users.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Schedule monthly book delivery - successful scenario
    [Documentation]    Verify that a registered user can successfully opt-in for monthly book delivery.
    [Tags]    req-GENAI-303    type-ok
    I am a registered user with a curated favorites list
    I opt-in for monthly book delivery
    I should receive a confirmation of my subscription

Schedule monthly book delivery - unsuccessful scenario
    [Documentation]    Verify that a registered user cannot confirm subscription without opting-in for monthly book delivery.
    [Tags]    req-GENAI-303    type-nok
    I am a registered user with a curated favorites list
    I have not opted-in for monthly book delivery
    I try to confirm my subscription
    I should not receive a confirmation of my subscription

Receive monthly book delivery - successful scenario
    [Documentation]    Verify that a user receives a book and notification on the scheduled delivery date.
    [Tags]    req-GENAI-303    type-ok
    I have opted-in for monthly book delivery
    The scheduled delivery date arrives
    I should receive a book from my curated favorites list
    I should receive a notification of the delivery

Receive monthly book delivery - unsuccessful scenario
    [Documentation]    Verify that a user does not receive a book or notification before the scheduled delivery date.
    [Tags]    req-GENAI-303    type-nok
    I have opted-in for monthly book delivery
    The scheduled delivery date has not arrived
    I check for a delivery
    I should not receive a book from my curated favorites list
    I should not receive a notification of the delivery

Manage subscription - successful scenario
    [Documentation]    Verify that a user can manage their subscription (pause, resume, or cancel).
    [Tags]    req-GENAI-303    type-ok
    I am a registered user with an active monthly book delivery subscription
    I choose to manage my subscription
    I should be able to pause, resume, or cancel my subscription

Manage subscription - unsuccessful scenario
    [Documentation]    Verify that a user cannot manage their subscription without choosing to do so.
    [Tags]    req-GENAI-303    type-nok
    I am a registered user with an active monthly book delivery subscription
    I have not chosen to manage my subscription
    I try to pause, resume, or cancel my subscription
    I should not be able to manage my subscription

*** Keywords ***
I am a registered user with a curated favorites list
    New Browser    chromium
    New Page    ${URL}
    Login As Registered User
    Verify Curated Favorites List

I have not opted-in for monthly book delivery
    Verify Not Opted-In For Monthly Book Delivery

I opt-in for monthly book delivery
    Opt-In For Monthly Book Delivery

I try to confirm my subscription
    Try To Confirm My Subscription

I should receive a confirmation of my subscription
    Verify Subscription Confirmation

I should not receive a confirmation of my subscription
    Verify No Subscription Confirmation

I have opted-in for monthly book delivery
    Verify Opted-In For Monthly Book Delivery

The scheduled delivery date arrives
    Wait Until Scheduled Delivery Date

I check for a delivery
    Check For A Delivery

I should receive a book from my curated favorites list
    Verify Book Delivery

I should receive a notification of the delivery
    Verify Delivery Notification

I should not receive a book from my curated favorites list
    Verify No Book Delivery

I should not receive a notification of the delivery
    Verify No Delivery Notification

I am a registered user with an active monthly book delivery subscription
    New Browser    chromium
    New Page    ${URL}
    Login As Registered User
    Verify Active Monthly Book Delivery Subscription

I choose to manage my subscription
    Choose To Manage My Subscription

I should be able to pause, resume, or cancel my subscription
    Verify Manage Subscription Options

I have not chosen to manage my subscription
    Verify Not Chosen To Manage My Subscription

I try to pause, resume, or cancel my subscription
    Try To Manage My Subscription

I should not be able to manage my subscription
    Verify Cannot Manage Subscription
