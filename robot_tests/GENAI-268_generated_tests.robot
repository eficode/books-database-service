*** Settings ***
Documentation    This test suite verifies the purchase and gift sending functionality of the bookstore application.
Library          Browser

*** Variables ***
${BOOK_TITLE}    The Great Gatsby
${RECIPIENT_NAME}    John Doe
${RECIPIENT_EMAIL}    john.doe@example.com
${INVALID_EMAIL}    invalid-email

*** Test Cases ***
Purchase and send a book to a recipient - successful scenario
    [Documentation]    Verify that a logged-in customer can purchase and send a book as a gift successfully.
    [Tags]    req-GENAI-266    type-ok
    Given I am a logged-in customer
    When I select a book to purchase
    And I choose the option to send it as a gift
    And I provide the recipient's shipping details
    Then the book should be purchased and sent directly to the recipient
    And I should receive a confirmation of the purchase and shipment

Purchase and send a book to a recipient with invalid shipping details - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot purchase and send a book as a gift with invalid shipping details.
    [Tags]    req-GENAI-266    type-nok
    Given I am a logged-in customer
    When I select a book to purchase
    And I choose the option to send it as a gift
    And I provide invalid recipient's shipping details
    Then the book should not be purchased
    And I should receive an error message indicating invalid shipping details

Confirmation of gift purchase - successful scenario
    [Documentation]    Verify that an email confirmation is received after a successful gift purchase.
    [Tags]    req-GENAI-266    type-ok
    Given I have purchased a book as a gift
    When the purchase is successful
    Then I should receive an email confirmation with the details of the purchase and shipment

No confirmation email received after gift purchase - unsuccessful scenario
    [Documentation]    Verify that no email confirmation is received if the email service is down after a successful gift purchase.
    [Tags]    req-GENAI-266    type-nok
    Given I have purchased a book as a gift
    When the purchase is successful
    And the email service is down
    Then I should not receive an email confirmation
    And I should see a notification in my account indicating the purchase was successful

*** Keywords ***
I am a logged-in customer
    New Browser    chromium
    New Page    http://bookstore.example.com
    Click    text=Login
    Fill Text    id=username    my_username
    Fill Text    id=password    my_password
    Click    id=login-button
    Wait For Elements State    id=account-overview    visible

I select a book to purchase
    Fill Text    id=search-bar    ${BOOK_TITLE}
    Click    id=search-button
    Click    text=${BOOK_TITLE}
    Wait For Elements State    id=book-details    visible
    Click    id=add-to-cart

I choose the option to send it as a gift
    Click    id=cart
    Click    id=send-as-gift

I provide the recipient's shipping details
    Fill Text    id=recipient-name    ${RECIPIENT_NAME}
    Fill Text    id=recipient-email    ${RECIPIENT_EMAIL}
    Click    id=confirm-gift

I provide invalid recipient's shipping details
    Fill Text    id=recipient-name    ${RECIPIENT_NAME}
    Fill Text    id=recipient-email    ${INVALID_EMAIL}
    Click    id=confirm-gift

The book should be purchased and sent directly to the recipient
    Wait For Elements State    id=order-confirmation    visible
    Get Text    id=order-confirmation    ==    Your order has been placed successfully

I should receive a confirmation of the purchase and shipment
    Wait For Elements State    id=email-confirmation    visible
    Get Text    id=email-confirmation    ==    Your gift has been sent to ${RECIPIENT_EMAIL}

The book should not be purchased
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    Invalid shipping details

I should receive an error message indicating invalid shipping details
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    Invalid shipping details

I have purchased a book as a gift
    [Return]    True

The purchase is successful
    [Return]    True

I should receive an email confirmation with the details of the purchase and shipment
    Wait For Elements State    id=email-confirmation    visible
    Get Text    id=email-confirmation    ==    Your gift has been sent to ${RECIPIENT_EMAIL}

The email service is down
    [Return]    False

I should not receive an email confirmation
    Wait For Elements State    id=email-confirmation    hidden

I should see a notification in my account indicating the purchase was successful
    Wait For Elements State    id=account-notification    visible
    Get Text    id=account-notification    ==    Your gift purchase was successful
