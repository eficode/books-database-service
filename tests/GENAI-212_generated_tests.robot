*** Settings ***
Documentation    This test suite verifies the checkout process for sending a book to a recipient.
Library          Browser

*** Variables ***
${URL}           http://example.com/checkout

*** Test Cases ***
Select recipient during checkout - successful scenario
    [Documentation]    Verify that the option to enter recipient details is available at checkout.
    [Tags]    req-GENAI-210    type-ok
    Given I am an end customer
    When I am at the checkout page
    Then I should see an option to enter recipient details

Select recipient during checkout - unsuccessful scenario
    [Documentation]    Verify that the option to enter recipient details is not available at checkout.
    [Tags]    req-GENAI-210    type-nok
    Given I am an end customer
    When I am at the checkout page
    And the option to enter recipient details is missing
    Then I should not be able to proceed with entering recipient details

Enter recipient details - successful scenario
    [Documentation]    Verify that the system validates and saves recipient details.
    [Tags]    req-GENAI-210    type-ok
    Given I have selected to send the book to a recipient
    When I enter the recipient's name and address
    Then the system should validate the address
    And the recipient details should be saved for the order

Enter recipient details - unsuccessful scenario
    [Documentation]    Verify that the system fails to validate invalid recipient details.
    [Tags]    req-GENAI-210    type-nok
    Given I have selected to send the book to a recipient
    When I enter an invalid recipient's name and address
    Then the system should fail to validate the address
    And the recipient details should not be saved for the order

Confirm order with recipient details - successful scenario
    [Documentation]    Verify that the order is confirmed and sent to the recipient's address.
    [Tags]    req-GENAI-210    type-ok
    Given I have entered valid recipient details
    When I confirm the order
    Then the book should be sent to the recipient's address
    And I should receive a confirmation of the order

Confirm order with recipient details - unsuccessful scenario
    [Documentation]    Verify that the order is not confirmed with invalid recipient details.
    [Tags]    req-GENAI-210    type-nok
    Given I have entered invalid recipient details
    When I confirm the order
    Then the book should not be sent to the recipient's address
    And I should receive an error message

*** Keywords ***
I am an end customer
    New Page    ${URL}

I am at the checkout page
    Wait For Elements State    //form[@id='checkout-form']    visible

I should see an option to enter recipient details
    Wait For Elements State    //input[@id='recipient-details']    visible

The option to enter recipient details is missing
    Wait For Elements State    //input[@id='recipient-details']    hidden

I should not be able to proceed with entering recipient details
    Wait For Elements State    //button[@id='proceed-button']    hidden

I have selected to send the book to a recipient
    Click    //input[@id='send-to-recipient']

I enter the recipient's name and address
    Fill Text    //input[@id='recipient-name']    John Doe
    Fill Text    //input[@id='recipient-address']    123 Main St, Anytown, AT 12345

The system should validate the address
    Wait For Elements State    //div[@id='address-validation']    visible

The recipient details should be saved for the order
    Wait For Elements State    //div[@id='recipient-details-saved']    visible

I enter an invalid recipient's name and address
    Fill Text    //input[@id='recipient-name']    Invalid Name
    Fill Text    //input[@id='recipient-address']    Invalid Address

The system should fail to validate the address
    Wait For Elements State    //div[@id='address-validation-error']    visible

The recipient details should not be saved for the order
    Wait For Elements State    //div[@id='recipient-details-saved']    hidden

I have entered valid recipient details
    Fill Text    //input[@id='recipient-name']    John Doe
    Fill Text    //input[@id='recipient-address']    123 Main St, Anytown, AT 12345
    Click    //button[@id='save-recipient-details']

I confirm the order
    Click    //button[@id='confirm-order']

The book should be sent to the recipient's address
    Wait For Elements State    //div[@id='order-confirmation']    visible

I should receive a confirmation of the order
    Wait For Elements State    //div[@id='order-confirmation']    visible

I have entered invalid recipient details
    Fill Text    //input[@id='recipient-name']    Invalid Name
    Fill Text    //input[@id='recipient-address']    Invalid Address
    Click    //button[@id='save-recipient-details']

The book should not be sent to the recipient's address
    Wait For Elements State    //div[@id='order-error']    visible

I should receive an error message
    Wait For Elements State    //div[@id='order-error']    visible
