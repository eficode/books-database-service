*** Settings ***
Documentation    This test suite verifies the functionality of sending books as gifts via the BookBridge platform.
Library          Browser

*** Variables ***
${URL}           https://bookbridge.example.com

*** Test Cases ***
Select book and recipient - successful scenario
    [Documentation]    Verify that a logged-in customer can select a book and specify a recipient's address in the UK.
    [Tags]    req-GENAI-244    type-ok
    I am a logged-in BookBridge customer
    I choose a book to send as a gift
    I select 'Send as Mother's Day gift'
    I should be prompted to enter the recipient's details
    I should be able to specify the recipient's address in the UK

Select book and recipient - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot specify a recipient's address outside the UK.
    [Tags]    req-GENAI-244    type-nok
    I am a logged-in BookBridge customer
    I choose a book to send as a gift
    I select 'Send as Mother's Day gift'
    I should be prompted to enter the recipient's details
    I should not be able to specify the recipient's address outside the UK

Confirm gift details - successful scenario
    [Documentation]    Verify that the customer can review and confirm the gift details.
    [Tags]    req-GENAI-244    type-ok
    I have entered the recipient's details
    I review the gift details
    I should see a confirmation screen with the recipient's address and the selected book
    I should be able to confirm or edit the details

Confirm gift details - unsuccessful scenario
    [Documentation]    Verify that the customer cannot proceed if the gift details are incomplete.
    [Tags]    req-GENAI-244    type-nok
    I have entered the recipient's details
    I review the gift details
    I should see a confirmation screen with the recipient's address and the selected book
    I should not be able to proceed if the details are incomplete

Send gift - successful scenario
    [Documentation]    Verify that the book is sent to the recipient's address in the UK upon successful payment.
    [Tags]    req-GENAI-244    type-ok
    I have confirmed the gift details
    I proceed to payment
    The book should be sent to the recipient's address in the UK
    I should receive a confirmation email

Send gift - unsuccessful scenario
    [Documentation]    Verify that the book is not sent if the payment fails and an error message is received.
    [Tags]    req-GENAI-244    type-nok
    I have confirmed the gift details
    I proceed to payment
    The book should not be sent if the payment fails
    I should receive an error message

*** Keywords ***
I am a logged-in BookBridge customer
    New Browser    chromium
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    testuser
    Fill Text    id=password    password123
    Click    id=loginButton
    Wait For Elements State    id=logoutButton    visible

I choose a book to send as a gift
    Click    text=Books
    Click    text=The Great Gatsby
    Click    id=addToCartButton

I select 'Send as Mother's Day gift'
    Click    id=sendAsGiftCheckbox
    Select Options By    id=occasionDropdown    text    Mother's Day

I should be prompted to enter the recipient's details
    Wait For Elements State    id=recipientDetailsForm    visible

I should be able to specify the recipient's address in the UK
    Fill Text    id=recipientAddress    123 London Street, London, UK
    Click    id=saveRecipientDetailsButton
    Wait For Elements State    id=addressSavedMessage    visible

I should not be able to specify the recipient's address outside the UK
    Fill Text    id=recipientAddress    123 Paris Street, Paris, France
    Click    id=saveRecipientDetailsButton
    Wait For Elements State    id=addressErrorMessage    visible

I have entered the recipient's details
    Fill Text    id=recipientName    Jane Doe
    Fill Text    id=recipientAddress    123 London Street, London, UK
    Click    id=saveRecipientDetailsButton
    Wait For Elements State    id=addressSavedMessage    visible

I review the gift details
    Click    id=reviewGiftDetailsButton

I should see a confirmation screen with the recipient's address and the selected book
    Wait For Elements State    id=confirmationScreen    visible
    Get Text    id=confirmationRecipientAddress    ==    123 London Street, London, UK
    Get Text    id=confirmationBookTitle    ==    The Great Gatsby

I should be able to confirm or edit the details
    Click    id=confirmGiftDetailsButton
    Wait For Elements State    id=paymentScreen    visible

I should not be able to proceed if the details are incomplete
    Click    id=confirmGiftDetailsButton
    Wait For Elements State    id=errorIncompleteDetails    visible

I have confirmed the gift details
    Click    id=confirmGiftDetailsButton
    Wait For Elements State    id=paymentScreen    visible

I proceed to payment
    Fill Text    id=creditCardNumber    4111111111111111
    Fill Text    id=creditCardExpiry    12/23
    Fill Text    id=creditCardCVC    123
    Click    id=payButton

The book should be sent to the recipient's address in the UK
    Wait For Elements State    id=paymentSuccessMessage    visible
    Get Text    id=deliveryAddress    ==    123 London Street, London, UK

I should receive a confirmation email
    Wait For Elements State    id=emailConfirmationMessage    visible

The book should not be sent if the payment fails
    Fill Text    id=creditCardNumber    4111111111111112
    Fill Text    id=creditCardExpiry    12/23
    Fill Text    id=creditCardCVC    123
    Click    id=payButton
    Wait For Elements State    id=paymentErrorMessage    visible

I should receive an error message
    Wait For Elements State    id=paymentErrorMessage    visible
