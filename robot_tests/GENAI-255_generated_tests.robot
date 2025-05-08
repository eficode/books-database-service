*** Settings ***
Documentation    This test suite verifies the direct delivery process for Mother's Day gifts.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      password123
${INVALID_ADDRESS} 123 Fake St

*** Test Cases ***
Select gift for Mother's Day - successful scenario
    [Documentation]    Verify that a logged-in customer can select a gift and add it to the cart.
    [Tags]    req-GENAI-253    type-ok
    Given I am a logged-in customer
    When I browse the Mother's Day gift selection
    Then I should be able to select a gift and add it to my cart

Select gift for Mother's Day - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when attempting to add an out-of-stock gift to the cart.
    [Tags]    req-GENAI-253    type-nok
    Given I am a logged-in customer
    And I browse the Mother's Day gift selection
    When I attempt to add an out-of-stock gift to my cart
    Then I should receive an error message indicating the item is out of stock

Enter recipient's address - successful scenario
    [Documentation]    Verify that the customer is prompted to enter the recipient's address during checkout.
    [Tags]    req-GENAI-253    type-ok
    Given I have added a Mother's Day gift to my cart
    When I proceed to checkout
    Then I should be prompted to enter the recipient's (mother's) address

Enter recipient's address - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when entering an invalid recipient's address.
    [Tags]    req-GENAI-253    type-nok
    Given I have added a Mother's Day gift to my cart
    And I proceed to checkout
    When I enter an invalid recipient's address
    Then I should receive an error message indicating the address is invalid

Confirm delivery details - successful scenario
    [Documentation]    Verify that the customer can review and confirm the order with the correct delivery details.
    [Tags]    req-GENAI-253    type-ok
    Given I have entered the recipient's address
    When I review the order summary
    Then I should see the recipient's address and delivery date
    And I should be able to confirm the order

Confirm delivery details - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the recipient's address is missing or incorrect.
    [Tags]    req-GENAI-253    type-nok
    Given I have entered the recipient's address
    And I review the order summary
    When the recipient's address is missing or incorrect
    Then I should receive an error message indicating the issue

Order confirmation - successful scenario
    [Documentation]    Verify that the customer receives an order confirmation email and the gift is delivered.
    [Tags]    req-GENAI-253    type-ok
    Given I have confirmed the order
    When the order is processed
    Then I should receive an order confirmation email
    And the gift should be delivered to the recipient's address

Order confirmation - unsuccessful scenario
    [Documentation]    Verify that a notification is shown when the order confirmation email fails to send.
    [Tags]    req-GENAI-253    type-nok
    Given I have confirmed the order
    And the order is processed
    When the order confirmation email fails to send
    Then I should receive a notification about the email failure

*** Keywords ***
I am a logged-in customer
    Browser.Open Browser    ${URL}    chromium
    Browser.Fill Text    id=username    ${USERNAME}
    Browser.Fill Text    id=password    ${PASSWORD}
    Browser.Click    id=login
    Browser.Wait For Elements State    id=logged-in    visible

I browse the Mother's Day gift selection
    Browser.Click    text=Mother's Day Gifts
    Browser.Wait For Elements State    id=gift-selection    visible

I should be able to select a gift and add it to my cart
    Browser.Click    id=select-gift
    Browser.Wait For Elements State    id=cart    visible

I attempt to add an out-of-stock gift to my cart
    Browser.Click    id=out-of-stock-gift

I should receive an error message indicating the item is out of stock
    Browser.Wait For Elements State    id=error-message    visible
    Browser.Get Text    id=error-message    ==    This item is out of stock

I have added a Mother's Day gift to my cart
    Browser.Click    id=add-to-cart
    Browser.Wait For Elements State    id=cart    visible

I proceed to checkout
    Browser.Click    id=checkout
    Browser.Wait For Elements State    id=checkout-page    visible

I should be prompted to enter the recipient's (mother's) address
    Browser.Wait For Elements State    id=recipient-address    visible

I enter an invalid recipient's address
    Browser.Fill Text    id=address    ${INVALID_ADDRESS}
    Browser.Click    id=submit-address

I should receive an error message indicating the address is invalid
    Browser.Wait For Elements State    id=error-message    visible
    Browser.Get Text    id=error-message    ==    The address you entered is invalid

I have entered the recipient's address
    Browser.Fill Text    id=address    123 Real St
    Browser.Click    id=submit-address
    Browser.Wait For Elements State    id=order-summary    visible

I review the order summary
    Browser.Click    id=review-order
    Browser.Wait For Elements State    id=order-summary    visible

I should see the recipient's address and delivery date
    Browser.Get Text    id=recipient-address    ==    123 Real St
    Browser.Get Text    id=delivery-date    ==    2023-05-14

I should be able to confirm the order
    Browser.Click    id=confirm-order
    Browser.Wait For Elements State    id=order-confirmation    visible

The recipient's address is missing or incorrect
    Browser.Fill Text    id=address    
    Browser.Click    id=submit-address

I should receive an error message indicating the issue
    Browser.Wait For Elements State    id=error-message    visible
    Browser.Get Text    id=error-message    ==    The address is missing or incorrect

I have confirmed the order
    Browser.Click    id=confirm-order
    Browser.Wait For Elements State    id=order-confirmation    visible

The order is processed
    Browser.Wait For Elements State    id=processing    visible
    Browser.Wait For Elements State    id=processing    hidden

I should receive an order confirmation email
    # Assuming a custom keyword for email verification
    Email Should Be Received    testuser@example.com    Order Confirmation

The gift should be delivered to the recipient's address
    Browser.Wait For Elements State    id=delivery-confirmation    visible
    Browser.Get Text    id=delivery-confirmation    ==    Delivered

The order confirmation email fails to send
    # Assuming a custom keyword for simulating email failure
    Simulate Email Failure    testuser@example.com    Order Confirmation

I should receive a notification about the email failure
    Browser.Wait For Elements State    id=email-failure-notification    visible
    Browser.Get Text    id=email-failure-notification    ==    Failed to send order confirmation email
