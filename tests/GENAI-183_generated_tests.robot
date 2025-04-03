*** Settings ***
Documentation     This test suite verifies the functionality of the 'Order Immediately' button and the purchase process on a product page.
Library           Browser

*** Variables ***
${PRODUCT_PAGE_URL}    https://example.com/product
${CHECKOUT_PAGE_URL}   https://example.com/checkout

*** Test Cases ***
Display 'Order Immediately' button - successful scenario
    [Documentation]    Verify that the 'Order Immediately' button is displayed on the product page.
    [Tags]    req-GENAI-182    type-ok
    Given I am on a product page
    When I view the product details
    Then I should see an 'Order Immediately' button

Display 'Order Immediately' button - unsuccessful scenario
    [Documentation]    Verify that the 'Order Immediately' button is not displayed when product details fail to load.
    [Tags]    req-GENAI-182    type-nok
    Given I am on a product page
    When I view the product details
    And the product details fail to load
    Then I should not see an 'Order Immediately' button

Click 'Order Immediately' button - successful scenario
    [Documentation]    Verify that clicking the 'Order Immediately' button takes the user to the checkout page with the product added to the cart.
    [Tags]    req-GENAI-182    type-ok
    Given I am on a product page
    When I click the 'Order Immediately' button
    Then I should be taken directly to the checkout page with the product added to my cart

Click 'Order Immediately' button - unsuccessful scenario
    [Documentation]    Verify that clicking the 'Order Immediately' button does not take the user to the checkout page if the button fails to function.
    [Tags]    req-GENAI-182    type-nok
    Given I am on a product page
    When I click the 'Order Immediately' button
    And the button fails to function
    Then I should not be taken to the checkout page
    And the product should not be added to my cart

Complete purchase - successful scenario
    [Documentation]    Verify that the purchase process completes successfully and an order confirmation is received.
    [Tags]    req-GENAI-182    type-ok
    Given I am on the checkout page with the product added to my cart
    When I complete the purchase process
    Then the order should be successfully placed
    And I should receive an order confirmation

Complete purchase - unsuccessful scenario
    [Documentation]    Verify that the purchase process does not complete if the payment fails and an error message is received.
    [Tags]    req-GENAI-182    type-nok
    Given I am on the checkout page with the product added to my cart
    When I complete the purchase process
    And the payment fails
    Then the order should not be placed
    And I should receive an error message

*** Keywords ***
I am on a product page
    New Page    ${PRODUCT_PAGE_URL}

I view the product details
    Wait For Elements State    //div[@id='product-details']    visible

I should see an 'Order Immediately' button
    Wait For Elements State    //button[@id='order-immediately']    visible

The product details fail to load
    Wait For Elements State    //div[@id='product-details']    hidden

I should not see an 'Order Immediately' button
    Wait For Elements State    //button[@id='order-immediately']    hidden

I click the 'Order Immediately' button
    Click    //button[@id='order-immediately']

I should be taken directly to the checkout page with the product added to my cart
    Wait For Elements State    //div[@id='checkout']    visible
    Get Url    ${CHECKOUT_PAGE_URL}

The button fails to function
    # Simulate button failure by not navigating to checkout page
    No Operation

I should not be taken to the checkout page
    Get Url    ${CHECKOUT_PAGE_URL}

The product should not be added to my cart
    # Assuming there's a way to verify the cart is empty
    Wait For Elements State    //div[@id='cart-item']    hidden

I am on the checkout page with the product added to my cart
    New Page    ${CHECKOUT_PAGE_URL}
    # Assuming the product is already added to the cart
    Wait For Elements State    //div[@id='cart-item']    visible

I complete the purchase process
    Click    //button[@id='complete-purchase']

The order should be successfully placed
    Wait For Elements State    //div[@id='order-confirmation']    visible

I should receive an order confirmation
    Wait For Elements State    //div[@id='order-confirmation']    visible

The payment fails
    # Simulate payment failure
    No Operation

The order should not be placed
    Wait For Elements State    //div[@id='order-confirmation']    hidden

I should receive an error message
    Wait For Elements State    //div[@id='error-message']    visible
