*** Settings ***
Documentation    Test suite for verifying SciFi book subscription service
Library          Browser

*** Variables ***
${URL}           https://scifi-book-subscription.com

*** Test Cases ***
Subscribe to SciFi book subscription - successful scenario
    [Documentation]    Verify successful subscription to SciFi book service
    [Tags]    req-GENAI-288    type-ok
    Given I am a SciFi enthusiast
    When I choose to subscribe to the recurring SciFi book subscription
    Then I should be able to enter my delivery details and payment information
    And I should receive a confirmation of my subscription

Subscribe to SciFi book subscription with invalid payment information - unsuccessful scenario
    [Documentation]    Verify subscription fails with invalid payment information
    [Tags]    req-GENAI-288    type-nok
    Given I am a SciFi enthusiast
    When I choose to subscribe to the recurring SciFi book subscription
    And I enter invalid payment information
    Then I should not be able to complete the subscription
    And I should receive an error message indicating payment failure

Receive monthly SciFi book - successful scenario
    [Documentation]    Verify monthly SciFi book delivery
    [Tags]    req-GENAI-288    type-ok
    Given I am subscribed to the recurring SciFi book subscription
    When a new week begins
    Then a top-selling SciFi book should be automatically delivered to my doorstep
    And I should receive a notification of the shipment

Receive monthly SciFi book with delivery issue - unsuccessful scenario
    [Documentation]    Verify notification of delivery delay when there is an issue
    [Tags]    req-GENAI-288    type-nok
    Given I am subscribed to the recurring SciFi book subscription
    When a new week begins
    And there is an issue with the delivery service
    Then I should not receive the book on time
    And I should receive a notification about the delivery delay

*** Keywords ***
I am a SciFi enthusiast
    New Browser    chromium
    New Page    ${URL}
    Click    text=Subscribe

I choose to subscribe to the recurring SciFi book subscription
    Click    text=Recurring Subscription

I should be able to enter my delivery details and payment information
    Fill Text    id=delivery-details    John Doe, 123 SciFi St, Booktown
    Fill Text    id=payment-info    4111 1111 1111 1111, 12/23, 123
    Click    text=Submit

I should receive a confirmation of my subscription
    Wait For Elements State    text=Subscription Confirmed    visible
    Get Text    text=Subscription Confirmed

I enter invalid payment information
    Fill Text    id=payment-info    0000 0000 0000 0000, 12/23, 123
    Click    text=Submit

I should not be able to complete the subscription
    Wait For Elements State    text=Payment Failed    visible
    Get Text    text=Payment Failed

I should receive an error message indicating payment failure
    Get Text    text=Invalid payment information

I am subscribed to the recurring SciFi book subscription
    New Browser    chromium
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    johndoe
    Fill Text    id=password    password123
    Click    text=Login
    Click    text=My Subscriptions
    Get Text    text=Active Subscription

A new week begins
    # This step would be simulated in a real test environment
    Log    Simulating new week

A top-selling SciFi book should be automatically delivered to my doorstep
    Wait For Elements State    text=Book Delivered    visible
    Get Text    text=Book Delivered

I should receive a notification of the shipment
    Get Text    text=Shipment Notification

There is an issue with the delivery service
    # This step would be simulated in a real test environment
    Log    Simulating delivery issue

I should not receive the book on time
    Wait For Elements State    text=Delivery Delayed    visible
    Get Text    text=Delivery Delayed

I should receive a notification about the delivery delay
    Get Text    text=Delivery Delay Notification
