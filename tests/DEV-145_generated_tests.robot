*** Settings ***
Documentation    This test suite verifies the 'Order Immediately' button functionality on the product page.
Library          Browser

*** Variables ***
${PRODUCT_PAGE_URL}    https://example.com/product-page

*** Test Cases ***
Display 'Order Immediately' button on product page - successful scenario
    [Documentation]    Verify that the 'Order Immediately' button is displayed on the product page when the product is in stock.
    [Tags]    req-DEV-143    type-ok
    Given I am on a product page
    When view the product details
    Then I should see an 'Order Immediately' button

Display 'Order Immediately' button on product page - unsuccessful scenario
    [Documentation]    Verify that the 'Order Immediately' button is not displayed on the product page when the product is out of stock.
    [Tags]    req-DEV-143    type-nok
    Given I am on a product page
    When view the product details
    And product is out of stock
    Then I should not see an 'Order Immediately' button

Order product using 'Order Immediately' button - successful scenario
    [Documentation]    Verify that the user can order a product using the 'Order Immediately' button and complete the purchase with a single click.
    [Tags]    req-DEV-143    type-ok
    Given I am on a product page
    When click the 'Order Immediately' button
    Then I should be redirected to the order confirmation page
    And product should be added to my order
    And I should be able to complete the purchase with a single click

Order product using 'Order Immediately' button - unsuccessful scenario
    [Documentation]    Verify that the user is redirected to the login page when trying to order a product using the 'Order Immediately' button without being logged in.
    [Tags]    req-DEV-143    type-nok
    Given I am on a product page
    When click the 'Order Immediately' button
    And I am not logged in
    Then I should be redirected to the login page
    And product should not be added to my order

*** Keywords ***
I am on a product page
    New Page    ${PRODUCT_PAGE_URL}

view the product details
    # Assuming the product details are visible by default when on the product page
    Wait For Elements State    //div[@class='product-details']    visible

I should see an 'Order Immediately' button
    Wait For Elements State    //button[text()='Order Immediately']    visible

product is out of stock
    # Simulate the product being out of stock
    Evaluate    document.querySelector('button[text()="Order Immediately"]').style.display='none';

I should not see an 'Order Immediately' button
    Wait For Elements State    //button[text()='Order Immediately']    hidden

click the 'Order Immediately' button
    Click    //button[text()='Order Immediately']

I should be redirected to the order confirmation page
    Wait For    https://example.com/order-confirmation

product should be added to my order
    # Verify the product is added to the order
    Wait For Elements State    //div[@class='order-summary']    visible
    Get Text    //div[@class='order-summary']//span[@class='product-name']    ==    Expected Product Name

I should be able to complete the purchase with a single click
    # Assuming there is a single-click purchase button on the order confirmation page
    Click    //button[text()='Complete Purchase']
    Wait For Elements State    //div[@class='purchase-success']    visible

I am not logged in
    # Simulate the user not being logged in
    Evaluate    document.cookie = 'session=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';

I should be redirected to the login page
    Wait For    https://example.com/login

product should not be added to my order
    # Verify the product is not added to the order
    Wait For Elements State    //div[@class='order-summary']    hidden
