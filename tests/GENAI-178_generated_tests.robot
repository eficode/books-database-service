*** Settings ***
Documentation    This test suite verifies the functionality of selecting and purchasing gift books.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      password123
${BOOK_TITLE}    Example Book
${RECIPIENT_ADDRESS} 123 Example St, Example City, EX 12345
${INVALID_PAYMENT_DETAILS} 1234 5678 9012 3456

*** Test Cases ***
Select and purchase gift books - successful scenario
    [Documentation]    Verify that an authenticated user can successfully purchase a book as a gift.
    [Tags]    req-GENAI-176    type-ok
    Given I am an authenticated user
    When I browse the book catalog
    And I select a book to purchase as a gift
    And I provide the recipient's delivery address
    And I complete the payment process
    Then the book should be marked as a gift purchase
    And the recipient's address should be saved for delivery

Select and purchase gift books with invalid payment - unsuccessful scenario
    [Documentation]    Verify that an authenticated user cannot purchase a book as a gift with invalid payment details.
    [Tags]    req-GENAI-176    type-nok
    Given I am an authenticated user
    When I browse the book catalog
    And I select a book to purchase as a gift
    And I provide the recipient's delivery address
    And I complete the payment process with invalid payment details
    Then the book should not be marked as a gift purchase
    And the recipient's address should not be saved for delivery

Select and purchase gift books with missing delivery address - unsuccessful scenario
    [Documentation]    Verify that an authenticated user cannot purchase a book as a gift without providing the recipient's delivery address.
    [Tags]    req-GENAI-176    type-nok
    Given I am an authenticated user
    When I browse the book catalog
    And I select a book to purchase as a gift
    And I do not provide the recipient's delivery address
    And I complete the payment process
    Then the book should not be marked as a gift purchase
    And the recipient's address should not be saved for delivery

*** Keywords ***
I am an authenticated user
    New Browser    chromium
    New Page    ${URL}
    Click    text=Login
    Fill Text    input[name="username"]    ${USERNAME}
    Fill Text    input[name="password"]    ${PASSWORD}
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I browse the book catalog
    Click    text=Books
    Wait For Elements State    text=${BOOK_TITLE}    visible

I select a book to purchase as a gift
    Click    text=${BOOK_TITLE}
    Click    text=Buy as Gift

I provide the recipient's delivery address
    Fill Text    input[name="recipient_address"]    ${RECIPIENT_ADDRESS}

I complete the payment process
    Click    text=Proceed to Payment
    Fill Text    input[name="card_number"]    4111 1111 1111 1111
    Fill Text    input[name="expiry_date"]    12/23
    Fill Text    input[name="cvv"]    123
    Click    text=Pay Now
    Wait For Elements State    text=Thank you for your purchase!    visible

I complete the payment process with invalid payment details
    Click    text=Proceed to Payment
    Fill Text    input[name="card_number"]    ${INVALID_PAYMENT_DETAILS}
    Fill Text    input[name="expiry_date"]    12/23
    Fill Text    input[name="cvv"]    123
    Click    text=Pay Now
    Wait For Elements State    text=Payment failed!    visible

I do not provide the recipient's delivery address
    [Arguments]    ${address}=
    Fill Text    input[name="recipient_address"]    ${address}

The book should be marked as a gift purchase
    Wait For Elements State    text=Gift Purchase    visible

The recipient's address should be saved for delivery
    Wait For Elements State    text=${RECIPIENT_ADDRESS}    visible

The book should not be marked as a gift purchase
    Wait For Elements State    text=Gift Purchase    hidden

The recipient's address should not be saved for delivery
    Wait For Elements State    text=${RECIPIENT_ADDRESS}    hidden
