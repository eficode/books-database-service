*** Settings ***
Documentation    This test suite verifies the functionality of sending a book as a gift to a friend.
Library          Browser

*** Variables ***
${URL}           https://bookstore.example.com
${USERNAME}      testuser
${PASSWORD}      password123
${BOOK_TITLE}    Example Book
${FRIEND_ADDRESS} 123 Friend St, Friend City, FC 12345
${INVALID_ADDRESS} Invalid Address

*** Test Cases ***
Send book as gift to a friend - successful scenario
    [Documentation]    Verify that a logged-in customer can successfully send a book as a gift to a friend.
    [Tags]    req-GENAI-346    type-ok
    Given I am a logged-in customer
    When I select a book to send as a gift
    And I provide my friend's shipping address
    And I complete the purchase
    Then the book should be shipped directly to my friend's address
    And I should receive a confirmation of the gift order

Send book as gift with invalid address - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot send a book as a gift with an invalid address.
    [Tags]    req-GENAI-346    type-nok
    Given I am a logged-in customer
    When I select a book to send as a gift
    And I provide invalid shipping address as my friend's address
    And I complete the purchase
    Then the book should not be shipped
    And I should receive an error message indicating an invalid address

Send book as gift without completing purchase - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot send a book as a gift without completing the purchase.
    [Tags]    req-GENAI-346    type-nok
    Given I am a logged-in customer
    When I select a book to send as a gift
    And I provide my friend's shipping address
    And I don't complete the purchase
    Then the book should not be shipped
    And I should not receive a confirmation of the gift order

*** Keywords ***
I am a logged-in customer
    Open Browser    ${URL}    chromium
    Click    text=Login
    Fill Text    input[name="username"]    ${USERNAME}
    Fill Text    input[name="password"]    ${PASSWORD}
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I select a book to send as a gift
    Click    text=${BOOK_TITLE}
    Click    text=Add to Cart

I provide my friend's shipping address
    Fill Text    input[name="shipping_address"]    ${FRIEND_ADDRESS}

I provide invalid shipping address as my friend's address
    Fill Text    input[name="shipping_address"]    ${INVALID_ADDRESS}

I complete the purchase
    Click    text=Checkout
    Click    text=Confirm Purchase

I don't complete the purchase
    Click    text=Checkout
    Click    text=Cancel

The book should be shipped directly to my friend's address
    Wait For Elements State    text=Order Shipped    visible

I should receive a confirmation of the gift order
    Wait For Elements State    text=Order Confirmation    visible

The book should not be shipped
    Wait For Elements State    text=Order Shipped    hidden

I should receive an error message indicating an invalid address
    Wait For Elements State    text=Invalid Address    visible

I should not receive a confirmation of the gift order
    Wait For Elements State    text=Order Confirmation    hidden
