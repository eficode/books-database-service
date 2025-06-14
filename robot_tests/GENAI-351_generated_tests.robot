*** Settings ***
Documentation    This test suite verifies the functionality of sending a book as a gift in the BookBridge application.
Library          Browser

*** Variables ***
${BOOKBRIDGE_URL}    https://bookbridge.example.com
${EMAIL}             testuser@example.com
${PASSWORD}          password123

*** Test Cases ***
Select book to send as gift - successful scenario
    [Documentation]    Verify that a logged-in customer can select a book to send as a gift.
    [Tags]    req-GENAI-349    type-ok
    I am a logged-in BookBridge customer
    I browse the book catalog
    I select a book
    I choose the option to send it as a gift
    I should be prompted to enter the recipient's details

Enter recipient details - successful scenario
    [Documentation]    Verify that entering recipient details is successful.
    [Tags]    req-GENAI-349    type-ok
    I have selected a book to send as a gift
    I enter the recipient's name, address, and country    John Doe    123 Main St    Wonderland
    I confirm the details
    I should see a confirmation message that the book will be sent as a gift

Enter recipient details - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when recipient details are incomplete.
    [Tags]    req-GENAI-349    type-nok
    I have selected a book to send as a gift
    I enter the recipient's name, address, and country    John Doe    123 Main St    Wonderland
    I do not confirm the details
    I should see an error message indicating that the details are incomplete

Confirm gift order - successful scenario
    [Documentation]    Verify that confirming the gift order is successful.
    [Tags]    req-GENAI-349    type-ok
    I have entered the recipient's details    John Doe    123 Main St    Wonderland
    I confirm the gift order
    The book should be added to the gift orders queue
    I should receive an email confirmation of the gift order

Confirm gift order - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when the book is out of stock.
    [Tags]    req-GENAI-349    type-nok
    I have entered the recipient's details    John Doe    123 Main St    Wonderland
    I confirm the gift order
    The book is not in stock anymore
    I should see an error message indicating that the order could not be processed because book is out of stock

*** Keywords ***
I am a logged-in BookBridge customer
    New Browser    headless=False
    New Context
    New Page    ${BOOKBRIDGE_URL}
    Click    text=Login
    Fill Text    input[name="email"]    ${EMAIL}
    Fill Text    input[name="password"]    ${PASSWORD}
    Click    text=Submit

I browse the book catalog
    Click    text=Catalog

I select a book
    Click    text=Some Book Title

I choose the option to send it as a gift
    Click    text=Send as Gift

I should be prompted to enter the recipient's details
    Wait For Elements State    input[name="recipient_name"]    visible

I have selected a book to send as a gift
    I browse the book catalog
    I select a book
    I choose the option to send it as a gift

I enter the recipient's name, address, and country
    [Arguments]    ${name}    ${address}    ${country}
    Fill Text    input[name="recipient_name"]    ${name}
    Fill Text    input[name="recipient_address"]    ${address}
    Fill Text    input[name="recipient_country"]    ${country}

I confirm the details
    Click    text=Confirm

I should see a confirmation message that the book will be sent as a gift
    Wait For Elements State    text=Your gift order has been confirmed    visible

I do not confirm the details
    Click    text=Cancel

I should see an error message indicating that the details are incomplete
    Wait For Elements State    text=Please complete all required fields    visible

I have entered the recipient's details
    [Arguments]    ${name}    ${address}    ${country}
    I enter the recipient's name, address, and country    ${name}    ${address}    ${country}
    I confirm the details

I confirm the gift order
    Click    text=Confirm Order

The book should be added to the gift orders queue
    Wait For Elements State    text=Your order has been added to the queue    visible

I should receive an email confirmation of the gift order
    # This step would typically involve checking the email inbox, which is not covered in this example.

The book is not in stock anymore
    # This step would typically involve setting the book's stock status in the application, which is not covered in this example.

I should see an error message indicating that the order could not be processed because book is out of stock
    Wait For Elements State    text=The book is out of stock    visible
