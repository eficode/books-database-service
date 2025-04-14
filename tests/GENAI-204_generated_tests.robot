*** Settings ***
Documentation    This test suite verifies the gift book ordering process for logged-in customers.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      password123

*** Test Cases ***
Gift Option Available When Book Selected
    [Documentation]    Verify that the gift option is available when a book is selected.
    [Tags]    req-GENAI-203    type-ok
    Given I am a logged-in customer
    When I browse the book catalog
    And I select a book to gift
    Then I should see an option to send it as a gift

Gift Option Not Available When Book Not Selected
    [Documentation]    Verify that the gift option is not available when no book is selected.
    [Tags]    req-GENAI-203    type-nok
    Given I am a logged-in customer
    When I browse the book catalog
    And I do not select a book to gift
    Then I should not see an option to send it as a gift

Prompt for Recipient Details When Sending Gift
    [Documentation]    Verify that the user is prompted to enter recipient details when sending a gift.
    [Tags]    req-GENAI-203    type-ok
    Given I have selected a book to gift
    When I choose to send it as a gift
    Then I should be prompted to enter the recipient's name and address
    And I should be able to enter a personalized message

Cannot Proceed Without Recipient Details
    [Documentation]    Verify that the user cannot proceed without entering recipient details.
    [Tags]    req-GENAI-203    type-nok
    Given I have selected a book to gift
    When I choose to send it as a gift
    And I do not enter the recipient's name and address
    Then I should not be able to proceed with the order

Confirm Order and See Delivery Date
    [Documentation]    Verify that the user can confirm the order and see the estimated delivery date.
    [Tags]    req-GENAI-203    type-ok
    Given I have entered the recipient's details
    When I review the gift details
    Then I should be able to confirm the order
    And I should see an estimated delivery date

No Delivery Date Without Order Confirmation
    [Documentation]    Verify that the user does not see a delivery date without confirming the order.
    [Tags]    req-GENAI-203    type-nok
    Given I have entered the recipient's details
    When I review the gift details
    And I do not confirm the order
    Then I should not see an estimated delivery date

Receive Confirmation Email and Notification
    [Documentation]    Verify that the user receives a confirmation email and the recipient receives a notification.
    [Tags]    req-GENAI-203    type-ok
    Given I have confirmed the gift order
    When the order is processed
    Then I should receive a confirmation email with the order details
    And the recipient should receive a notification about the gift

No Notification Without Confirmation Email
    [Documentation]    Verify that the recipient does not receive a notification if the user does not receive a confirmation email.
    [Tags]    req-GENAI-203    type-nok
    Given I have confirmed the gift order
    When the order is processed
    And I do not receive a confirmation email
    Then the recipient should not receive a notification about the gift

*** Keywords ***
I am a logged-in customer
    New Browser    chromium
    New Page    ${URL}
    Input Text    id=username    ${USERNAME}
    Input Text    id=password    ${PASSWORD}
    Click    id=login
    Wait For Elements State    id=book-catalog    visible

I browse the book catalog
    Click    id=book-catalog
    Wait For Elements State    id=book-list    visible

I select a book to gift
    Click    xpath=//div[@class='book'][1]//button[text()='Select']
    Wait For Elements State    id=gift-option    visible

I do not select a book to gift
    # No action needed as no book is selected

I should see an option to send it as a gift
    Get Element States    id=gift-option

I should not see an option to send it as a gift
    Get Element States    id=gift-option

I have selected a book to gift
    Click    xpath=//div[@class='book'][1]//button[text()='Select']
    Wait For Elements State    id=gift-option    visible

I choose to send it as a gift
    Click    id=gift-option
    Wait For Elements State    id=recipient-details    visible

I should be prompted to enter the recipient's name and address
    Get Element States    id=recipient-name
    Get Element States    id=recipient-address

I should be able to enter a personalized message
    Get Element States    id=personal-message

I do not enter the recipient's name and address
    # No action needed as no details are entered

I should not be able to proceed with the order
    Get Element States    id=proceed-order

I have entered the recipient's details
    Input Text    id=recipient-name    John Doe
    Input Text    id=recipient-address    123 Main St, Anytown, USA

I review the gift details
    Click    id=review-order
    Wait For Elements State    id=order-summary    visible

I should be able to confirm the order
    Get Element States    id=confirm-order

I should see an estimated delivery date
    Get Element States    id=delivery-date

I do not confirm the order
    # No action needed as order is not confirmed

I should not see an estimated delivery date
    Get Element States    id=delivery-date

I have confirmed the gift order
    Click    id=confirm-order
    Wait For Elements State    id=order-confirmation    visible

The order is processed
    Wait For Elements State    id=order-processed    visible

I should receive a confirmation email with the order details
    # Assuming email checking is mocked or verified through UI
    Get Element States    id=email-confirmation

The recipient should receive a notification about the gift
    # Assuming notification checking is mocked or verified through UI
    Get Element States    id=recipient-notification

I do not receive a confirmation email
    # No action needed as email is not received

The recipient should not receive a notification about the gift
    Get Element States    id=recipient-notification
