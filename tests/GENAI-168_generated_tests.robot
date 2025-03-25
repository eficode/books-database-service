*** Settings ***
Documentation    This test suite verifies the process of purchasing a book as a gift and ensuring the correct delivery details and payment process.
Library           Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      password123

*** Test Cases ***
Select a book as a gift - successful scenario
    [Documentation]    Verify that a logged-in customer can select a book as a gift and be prompted to enter recipient's delivery details.
    [Tags]    req-GENAI-167    type-ok
    Given I am a logged-in customer
    When I browse the book catalog
    And I select a book
    And I choose the option to buy it as a gift
    Then I should be prompted to enter the recipient's delivery details

Select a book as a gift - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot proceed with the purchase if recipient's delivery details are not entered.
    [Tags]    req-GENAI-167    type-nok
    Given I am a logged-in customer
    When I browse the book catalog
    And I select a book
    And I choose the option to buy it as a gift
    And I do not enter the recipient's delivery details
    Then I should not be able to proceed with the purchase

Enter recipient's delivery details - successful scenario
    [Documentation]    Verify that entering and confirming recipient's delivery details saves the details for the order.
    [Tags]    req-GENAI-167    type-ok
    Given I have selected a book as a gift
    When I enter the recipient's delivery details
    And I confirm the details
    Then the details should be saved for the order

Enter recipient's delivery details - unsuccessful scenario
    [Documentation]    Verify that not confirming recipient's delivery details does not save the details for the order.
    [Tags]    req-GENAI-167    type-nok
    Given I have selected a book as a gift
    When I enter the recipient's delivery details
    And I do not confirm the details
    Then the details should not be saved for the order

Complete the purchase - successful scenario
    [Documentation]    Verify that completing the payment marks the book for delivery and sends a confirmation of the order.
    [Tags]    req-GENAI-167    type-ok
    Given I have entered the recipient's delivery details
    When I proceed to checkout
    And I complete the payment
    Then the book should be marked for delivery to the recipient's address
    And I should receive a confirmation of the order

Complete the purchase - unsuccessful scenario
    [Documentation]    Verify that not completing the payment does not mark the book for delivery and does not send a confirmation of the order.
    [Tags]    req-GENAI-167    type-nok
    Given I have entered the recipient's delivery details
    When I proceed to checkout
    And I do not complete the payment
    Then the book should not be marked for delivery to the recipient's address
    And I should not receive a confirmation of the order

*** Keywords ***
I am a logged-in customer
    New Page    ${URL}
    Click    text=Login
    Fill Text    input[name="username"]    ${USERNAME}
    Fill Text    input[name="password"]    ${PASSWORD}
    Click    text=Submit

I browse the book catalog
    Click    text=Books

I select a book
    Click    css=.book-item:first-child

I choose the option to buy it as a gift
    Click    text=Buy as Gift

I should be prompted to enter the recipient's delivery details
    Wait For Elements State    css=.delivery-details-form    visible

I do not enter the recipient's delivery details
    # Intentionally left blank to simulate not entering details

I should not be able to proceed with the purchase
    ${state}=    Get Element States    css=.proceed-button
    Should Be True    "disabled" in ${state}

I have selected a book as a gift
    I am a logged-in customer
    I browse the book catalog
    I select a book
    I choose the option to buy it as a gift

I enter the recipient's delivery details
    Fill Text    input[name="recipient_name"]    John Doe
    Fill Text    input[name="recipient_address"]    123 Main St
    Fill Text    input[name="recipient_city"]    Anytown
    Fill Text    input[name="recipient_zip"]    12345

I confirm the details
    Click    text=Confirm

The details should be saved for the order
    ${state}=    Get Element States    css=.order-summary
    Should Be True    "visible" in ${state}

I do not confirm the details
    # Intentionally left blank to simulate not confirming details

The details should not be saved for the order
    ${state}=    Get Element States    css=.order-summary
    Should Not Contain    ${state}    visible

I proceed to checkout
    Click    text=Proceed to Checkout

I complete the payment
    Fill Text    input[name="card_number"]    4111111111111111
    Fill Text    input[name="expiry_date"]    12/23
    Fill Text    input[name="cvv"]    123
    Click    text=Pay Now

The book should be marked for delivery to the recipient's address
    ${state}=    Get Element States    css=.delivery-confirmation
    Should Be True    "visible" in ${state}

I should receive a confirmation of the order
    ${state}=    Get Element States    css=.order-confirmation
    Should Be True    "visible" in ${state}

I do not complete the payment
    # Intentionally left blank to simulate not completing payment

The book should not be marked for delivery to the recipient's address
    ${state}=    Get Element States    css=.delivery-confirmation
    Should Not Contain    ${state}    visible

I should not receive a confirmation of the order
    ${state}=    Get Element States    css=.order-confirmation
    Should Not Contain    ${state}    visible
