*** Settings ***
Documentation    This test suite verifies the functionality of sending Mother's Day gifts and receiving confirmations.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      password123
${VALID_ADDRESS} 123 Valid St, Valid City, VC 12345
${INVALID_ADDRESS} Invalid Address

*** Test Cases ***
Select and send a gift - successful scenario
    [Documentation]    Verify that a logged-in user can select and send a gift successfully.
    [Tags]    req-GENAI-247    type-ok
    Given I am a logged-in user
    When I navigate to the Mother's Day gift section
    And I select a book as a gift
    And I provide my mother's delivery address
    And I confirm the delivery date
    Then the gift should be scheduled for delivery on the specified date
    And I should receive a confirmation of the order

Select and send a gift with invalid address - unsuccessful scenario
    [Documentation]    Verify that a logged-in user cannot send a gift with an invalid address.
    [Tags]    req-GENAI-247    type-nok
    Given I am a logged-in user
    When I navigate to the Mother's Day gift section
    And I select a book as a gift
    And I provide an invalid delivery address
    And I confirm the delivery date
    Then the gift should not be scheduled for delivery
    And I should receive an error message indicating the invalid address

Receive confirmation - successful scenario
    [Documentation]    Verify that a user receives an email confirmation after scheduling a gift delivery.
    [Tags]    req-GENAI-247    type-ok
    Given I have scheduled a Mother's Day gift delivery
    When the gift is successfully scheduled
    Then I should receive an email confirmation with the order details

Receive confirmation without scheduling - unsuccessful scenario
    [Documentation]    Verify that a user does not receive an email confirmation without scheduling a gift delivery.
    [Tags]    req-GENAI-247    type-nok
    Given I have not scheduled a Mother's Day gift delivery
    When I attempt to check for a confirmation email
    Then I should not receive an email confirmation
    And I should see a message indicating no scheduled deliveries

*** Keywords ***
I am a logged-in user
    New Browser    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit

I navigate to the Mother's Day gift section
    Click    text=Mother's Day Gifts

I select a book as a gift
    Click    text=Books
    Click    text=Select

I provide my mother's delivery address
    Fill Text    id=address    ${VALID_ADDRESS}

I provide an invalid delivery address
    Fill Text    id=address    ${INVALID_ADDRESS}

I confirm the delivery date
    Click    id=confirm-date

The gift should be scheduled for delivery on the specified date
    Wait For Elements State    text=Delivery Scheduled    visible

I should receive a confirmation of the order
    Wait For Elements State    text=Order Confirmation    visible

The gift should not be scheduled for delivery
    Wait For Elements State    text=Delivery Failed    visible

I should receive an error message indicating the invalid address
    Wait For Elements State    text=Invalid Address    visible

I have scheduled a Mother's Day gift delivery
    [Documentation]    This keyword assumes the user has already scheduled a gift delivery.
    No Operation

The gift is successfully scheduled
    [Documentation]    This keyword assumes the gift scheduling process was successful.
    No Operation

I should receive an email confirmation with the order details
    Wait For Elements State    text=Email Confirmation    visible

I have not scheduled a Mother's Day gift delivery
    [Documentation]    This keyword assumes the user has not scheduled any gift delivery.
    No Operation

I attempt to check for a confirmation email
    [Documentation]    This keyword simulates the user checking for a confirmation email.
    No Operation

I should not receive an email confirmation
    Wait For Elements State    text=No Email Confirmation    visible

I should see a message indicating no scheduled deliveries
    Wait For Elements State    text=No Scheduled Deliveries    visible
