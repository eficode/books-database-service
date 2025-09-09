*** Settings ***
Documentation    This test suite verifies the functionality of viewing, adding to cart, and purchasing bestsellers from a specific year.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
View Bestsellers from a Specific Year - successful scenario
    [Documentation]    Verify that an authenticated user can view bestsellers from a specific year.
    [Tags]    req-GENAI-420    type-ok
    Given I am an authenticated user
    When I select a specific year from the bestsellers section
    Then I should see a list of bestsellers from that year

View Bestsellers from a Specific Year - unsuccessful scenario
    [Documentation]    Verify that an authenticated user sees a message when no bestsellers are available for a selected year.
    [Tags]    req-GENAI-420    type-nok
    Given I am an authenticated user
    When I select a specific year from the bestsellers section
    And the year has no bestsellers
    Then I should see a message indicating no bestsellers are available for that year

Add Bestseller to Cart - successful scenario
    [Documentation]    Verify that a user can add a bestseller to the cart and see a confirmation message.
    [Tags]    req-GENAI-420    type-ok
    Given I am viewing bestsellers from a specific year
    When I select a bestseller to add to my cart
    Then the bestseller should be added to my cart
    And I should see a confirmation message

Add Bestseller to Cart - unsuccessful scenario
    [Documentation]    Verify that a user sees a message when trying to add an out-of-stock bestseller to the cart.
    [Tags]    req-GENAI-420    type-nok
    Given I am viewing bestsellers from a specific year
    When I select a bestseller to add to my cart
    And the bestseller is out of stock
    Then I should see a message indicating the bestseller is out of stock

Purchase Bestseller - successful scenario
    [Documentation]    Verify that a user can successfully purchase a bestseller and receive a confirmation.
    [Tags]    req-GENAI-420    type-ok
    Given I have a bestseller in my cart
    When I proceed to checkout and complete the purchase
    Then I should receive a confirmation of my purchase
    And the bestseller should be marked as purchased in my account

Purchase Bestseller - unsuccessful scenario
    [Documentation]    Verify that a user sees a message when payment fails during purchase and the item remains in the cart.
    [Tags]    req-GENAI-420    type-nok
    Given I have a bestseller in my cart
    When I proceed to checkout and complete the purchase
    And the payment fails
    Then I should see a message indicating the payment failed
    And the bestseller should remain in my cart

*** Keywords ***
I am an authenticated user
    New Browser    ${URL}
    Click    text=Login
    Fill Text    username    ${USERNAME}
    Fill Text    password    ${PASSWORD}
    Click    text=Submit

I select a specific year from the bestsellers section
    Click    text=Bestsellers
    Click    text=2023

I should see a list of bestsellers from that year
    Wait For Elements State    text=Bestseller 1    visible
    Wait For Elements State    text=Bestseller 2    visible

The year has no bestsellers
    Click    text=2024

I should see a message indicating no bestsellers are available for that year
    Wait For Elements State    text=No bestsellers available    visible

I am viewing bestsellers from a specific year
    I am an authenticated user
    I select a specific year from the bestsellers section

I select a bestseller to add to my cart
    Click    text=Add to Cart

The bestseller should be added to my cart
    Wait For Elements State    text=Item added to cart    visible

I should see a confirmation message
    Wait For Elements State    text=Item added to cart    visible

The bestseller is out of stock
    Click    text=Out of Stock

I should see a message indicating the bestseller is out of stock
    Wait For Elements State    text=Out of Stock    visible

I have a bestseller in my cart
    I am viewing bestsellers from a specific year
    I select a bestseller to add to my cart

I proceed to checkout and complete the purchase
    Click    text=Cart
    Click    text=Checkout
    Fill Text    card_number    4111111111111111
    Fill Text    expiry_date    12/23
    Fill Text    cvv    123
    Click    text=Submit

I should receive a confirmation of my purchase
    Wait For Elements State    text=Purchase confirmed    visible

The bestseller should be marked as purchased in my account
    Click    text=My Account
    Wait For Elements State    text=Purchased    visible

The payment fails
    Fill Text    card_number    0000000000000000
    Click    text=Submit

I should see a message indicating the payment failed
    Wait For Elements State    text=Payment failed    visible

The bestseller should remain in my cart
    Click    text=Cart
    Wait For Elements State    text=Bestseller 1    visible
