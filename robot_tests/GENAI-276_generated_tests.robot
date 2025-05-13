*** Settings ***
Documentation    This test suite verifies the functionality of sending a book as a Mother's Day gift.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      testpass

*** Test Cases ***
Select book for Mother's Day gift - successful scenario
    [Documentation]    Verify that a logged-in customer can select a book and choose to send it as a Mother's Day gift.
    [Tags]    req-GENAI-274    type-ok
    Given I am a logged-in customer
    When I select a book to purchase
    And I choose the option to send it as a Mother's Day gift
    Then I should be prompted to enter my mother's shipping address
    And I should be able to add a personalized message

Select book for Mother's Day gift - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot proceed with the order if the mother's shipping address is not entered.
    [Tags]    req-GENAI-274    type-nok
    Given I am a logged-in customer
    When I select a book to purchase
    And I choose the option to send it as a Mother's Day gift
    And I do not enter my mother's shipping address
    Then I should not be able to proceed with the order
    And I should see an error message prompting me to enter the shipping address

Confirm and send gift - successful scenario
    [Documentation]    Verify that the book is sent to the mother's address and a confirmation email is received when the order is confirmed.
    [Tags]    req-GENAI-274    type-ok
    Given I have entered my mother's shipping address and a personalized message
    When I confirm the order
    Then the book should be sent to my mother's address
    And I should receive a confirmation email

Confirm and send gift - unsuccessful scenario
    [Documentation]    Verify that the book is not sent and an error message is received if the shipping address is invalid.
    [Tags]    req-GENAI-274    type-nok
    Given I have entered my mother's shipping address and a personalized message
    When I confirm the order
    And the shipping address is invalid
    Then the book should not be sent
    And I should receive an error message indicating the invalid address

*** Keywords ***
I am a logged-in customer
    New Browser    chromium
    New Page    ${URL}
    Get Element    [name="username"]
    Fill Text    [name="username"]    ${USERNAME}
    Get Element    [name="password"]
    Fill Text    [name="password"]    ${PASSWORD}
    Get Element    [name="loginButton"]
    Click    [name="loginButton"]
    Get Element    [name="loggedInUser"]
    Wait For Elements State    [name="loggedInUser"]    visible

I select a book to purchase
    Get Element    [name="bookCategory"]
    Click    [name="bookCategory"]
    Get Element    [name="selectBook"]
    Click    [name="selectBook"]

I choose the option to send it as a Mother's Day gift
    Get Element    [name="sendAsGift"]
    Click    [name="sendAsGift"]
    Get Element    [name="mothersDayOption"]
    Click    [name="mothersDayOption"]

I should be prompted to enter my mother's shipping address
    Get Element    [name="shippingAddressForm"]
    Wait For Elements State    [name="shippingAddressForm"]    visible

I should be able to add a personalized message
    Get Element    [name="personalMessageForm"]
    Wait For Elements State    [name="personalMessageForm"]    visible

I do not enter my mother's shipping address
    # Intentionally left blank to simulate not entering the address

I should not be able to proceed with the order
    Get Element    [name="proceedButton"]
    Wait For Elements State    [name="proceedButton"]    disabled

I should see an error message prompting me to enter the shipping address
    Get Element    [name="errorMessage"]
    Wait For Elements State    [name="errorMessage"]    visible

I have entered my mother's shipping address and a personalized message
    Get Element    [name="shippingAddress"]
    Fill Text    [name="shippingAddress"]    123 Mother St, Momtown, MT
    Get Element    [name="personalMessage"]
    Fill Text    [name="personalMessage"]    Happy Mother's Day!

I confirm the order
    Get Element    [name="confirmOrder"]
    Click    [name="confirmOrder"]

The book should be sent to my mother's address
    Get Element    [name="orderConfirmation"]
    Wait For Elements State    [name="orderConfirmation"]    visible

I should receive a confirmation email
    # Placeholder for email verification logic

The shipping address is invalid
    Get Element    [name="shippingAddress"]
    Fill Text    [name="shippingAddress"]    Invalid Address

The book should not be sent
    Get Element    [name="orderError"]
    Wait For Elements State    [name="orderError"]    visible

I should receive an error message indicating the invalid address
    Get Element    [name="errorMessage"]
    Wait For Elements State    [name="errorMessage"]    visible
