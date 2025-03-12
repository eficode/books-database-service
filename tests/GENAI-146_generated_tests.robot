*** Settings ***
Documentation    Test suite for verifying BookBridge B2B customer functionalities
Library          Browser

*** Variables ***
${URL}           https://bookbridge.example.com

*** Test Cases ***
Display top-selling sports books - successful scenario
    [Documentation]    Verify that a B2B customer can see top-selling sports books in the Mother's Day gift section
    [Tags]    req-GENAI-144    type-ok
    Given I am a BookBridge B2B customer
    When I access the Mother's Day gift section
    Then I should see a list of top-selling sports books

Display top-selling sports books - unsuccessful scenario
    [Documentation]    Verify that a B2B customer does not see top-selling sports books if the Mother's Day gift section is not available
    [Tags]    req-GENAI-144    type-nok
    Given I am a BookBridge B2B customer
    When I access the Mother's Day gift section
    And the section is not available
    Then I should not see a list of top-selling sports books

Quick purchase of a sports book - successful scenario
    [Documentation]    Verify that a B2B customer can quickly purchase a sports book from the top-selling list
    [Tags]    req-GENAI-144    type-ok
    Given I am viewing the list of top-selling sports books
    When I select a book to purchase
    And I confirm the purchase
    Then the book should be added to my cart
    And I should be able to complete the purchase quickly

Quick purchase of a sports book - unsuccessful scenario
    [Documentation]    Verify that a B2B customer cannot purchase a sports book if it is out of stock
    [Tags]    req-GENAI-144    type-nok
    Given I am viewing the list of top-selling sports books
    When I select a book to purchase
    And I confirm the purchase
    And the book is out of stock
    Then the book should not be added to my cart
    And I should not be able to complete the purchase quickly

*** Keywords ***
I am a BookBridge B2B customer
    New Browser    headless=False
    New Context
    New Page    ${URL}
    Click    text=B2B Login
    Fill Text    id=username    b2b_customer
    Fill Text    id=password    password123
    Click    id=loginButton

I access the Mother's Day gift section
    Click    text=Mother's Day Gifts

The section is not available
    Evaluate    document.querySelector('text=Mother\'s Day Gifts').remove()

I should see a list of top-selling sports books
    Wait For Elements State    css=.top-selling-sports-books    visible

I should not see a list of top-selling sports books
    Wait For Elements State    css=.top-selling-sports-books    hidden

I am viewing the list of top-selling sports books
    I am a BookBridge B2B customer
    I access the Mother's Day gift section
    I should see a list of top-selling sports books

I select a book to purchase
    Click    css=.top-selling-sports-books .book-item:first-child

I confirm the purchase
    Click    id=confirmPurchaseButton

The book should be added to my cart
    Wait For Elements State    css=.cart-item    visible

I should be able to complete the purchase quickly
    Click    id=checkoutButton
    Wait For Elements State    css=.order-confirmation    visible

The book is out of stock
    Evaluate    document.querySelector('.top-selling-sports-books .book-item:first-child').setAttribute('data-stock', '0')

The book should not be added to my cart
    Wait For Elements State    css=.cart-item    hidden

I should not be able to complete the purchase quickly
    Wait For Elements State    css=.order-confirmation    hidden
