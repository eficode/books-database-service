*** Settings ***
Documentation    This test suite verifies the logistical status of a book order under various conditions.
Library          Browser

*** Variables ***
${ORDER_ID}      12345
${INVALID_ORDER_ID}  99999
${ORDER_STATUS_URL}  https://example.com/order-status

*** Test Cases ***
User views the logistical status of their book order - successful scenario
    [Documentation]    Verify that the user can see the logistical status and estimated delivery date of their order.
    [Tags]    req-GENAI-92    type-ok
    Given I have placed a book order
    When I navigate to the order status page
    Then I should see the current logistical status of my order
    And I should see an estimated delivery date

User views the logistical status of their book order with invalid order ID - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the order ID is invalid.
    [Tags]    req-GENAI-92    type-nok
    Given I have placed a book order
    And the order ID is invalid
    When I navigate to the order status page
    Then I should see an error message indicating the order could not be found
    And I should not see any logistical status or estimated delivery date

User views the logistical status of their book order with API failure - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the logistics API is down.
    [Tags]    req-GENAI-92    type-nok
    Given I have placed a book order
    And the logistics API is down
    When I navigate to the order status page
    Then I should see an error message indicating the service is currently unavailable
    And I should not see any logistical status or estimated delivery date

User views the logistical status of their book order without authentication - unsuccessful scenario
    [Documentation]    Verify that the user is redirected to the login page when not authenticated.
    [Tags]    req-GENAI-92    type-nok
    Given I have placed a book order
    And I am not logged in
    When I navigate to the order status page
    Then I should be redirected to the login page
    And I should not see any logistical status or estimated delivery date

*** Keywords ***
I have placed a book order
    # Code to simulate placing a book order
    Log    Placed a book order with ID ${ORDER_ID}

I navigate to the order status page
    New Page    ${ORDER_STATUS_URL}
    Wait For Elements State    //div[@id='order-status']    visible

I should see the current logistical status of my order
    Wait For Elements State    //div[@id='logistical-status']    visible

I should see an estimated delivery date
    Wait For Elements State    //div[@id='estimated-delivery-date']    visible

The order ID is invalid
    # Code to simulate an invalid order ID
    Set Variable    ${ORDER_ID}    ${INVALID_ORDER_ID}

I should see an error message indicating the order could not be found
    Wait For Elements State    //div[@id='error-message']    visible
    Get Text    //div[@id='error-message']    ==    Order could not be found

The logistics API is down
    # Code to simulate the logistics API being down
    Log    Logistics API is down

I should see an error message indicating the service is currently unavailable
    Wait For Elements State    //div[@id='error-message']    visible
    Get Text    //div[@id='error-message']    ==    Service is currently unavailable

I am not logged in
    # Code to simulate the user not being logged in
    Log    User is not logged in

I should be redirected to the login page
    Wait For Elements State    //div[@id='login-page']    visible

I should not see any logistical status or estimated delivery date
    Wait For Elements State    //div[@id='logistical-status']    hidden
    Wait For Elements State    //div[@id='estimated-delivery-date']    hidden
