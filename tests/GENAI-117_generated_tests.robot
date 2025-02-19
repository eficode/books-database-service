*** Settings ***
Documentation    This test suite verifies the functionality of purchasing a book as a gift, including selecting the gift option, entering recipient details, choosing gift wrapping, and confirming the purchase.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USER}          testuser
${PASSWORD}      password123

*** Test Cases ***
Select book as a gift - successful scenario
    [Documentation]    Verify that a logged-in user can select a book as a gift and enter recipient details.
    [Tags]    req-GENAI-115    type-ok
    Given I am a logged-in user
    When I select a book to purchase
    And I choose the 'Buy as a gift' option
    Then I should be prompted to enter the recipient's details and a personalized message

Select book as a gift - unsuccessful scenario
    [Documentation]    Verify that a logged-in user selecting a book as a gift for another person is not prompted to enter their own logistic details.
    [Tags]    req-GENAI-115    type-nok
    Given I am a logged-in user
    When I select a book to purchase
    And I choose the 'Buy as a gift' option for other person than me
    Then I should not be prompted to enter my own logistic details and a personalized message

Gift wrapping option - successful scenario
    [Documentation]    Verify that a user can see and select from at least 5 different gift wrapping styles during checkout.
    [Tags]    req-GENAI-115    type-ok
    Given I have chosen to buy a book as a gift
    When I proceed to checkout
    Then I should see an option to add gift wrapping
    And I should be able to select one from at least 5 different wrapping styles

Confirm gift purchase - successful scenario
    [Documentation]    Verify that a book is wrapped and sent to the recipient's address and a confirmation email is received after confirming the purchase.
    [Tags]    req-GENAI-115    type-ok
    Given I have entered the recipient's details and selected gift wrapping
    When I confirm the purchase
    Then the book should be wrapped and sent to the recipient's address
    And I should receive a confirmation email with the gift details

*** Keywords ***
I am a logged-in user
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USER}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit

I select a book to purchase
    Click    text=Books
    Click    text=Some Book Title
    Click    text=Add to Cart

I choose the 'Buy as a gift' option
    Click    text=Buy as a gift

I should be prompted to enter the recipient's details and a personalized message
    Wait For Elements State    id=recipient-details    visible
    Wait For Elements State    id=personal-message    visible

I choose the 'Buy as a gift' option for other person than me
    Click    text=Buy as a gift

I should not be prompted to enter my own logistic details and a personalized message
    Wait For Elements State    id=recipient-details    hidden
    Wait For Elements State    id=personal-message    hidden

I have chosen to buy a book as a gift
    I am a logged-in user
    I select a book to purchase
    I choose the 'Buy as a gift' option

I proceed to checkout
    Click    text=Proceed to Checkout

I should see an option to add gift wrapping
    Wait For Elements State    id=gift-wrapping    visible

I should be able to select one from at least 5 different wrapping styles
    ${styles}=    Get Elements    css=.wrapping-style
    Length Should Be    ${styles}    5

I have entered the recipient's details and selected gift wrapping
    I have chosen to buy a book as a gift
    Fill Text    id=recipient-details    John Doe
    Fill Text    id=personal-message    Happy Birthday!
    Click    id=gift-wrapping
    Click    text=Style 1

I confirm the purchase
    Click    text=Confirm Purchase

The book should be wrapped and sent to the recipient's address
    Wait For Elements State    id=order-confirmation    visible

I should receive a confirmation email with the gift details
    # This step would typically involve checking an email inbox, which is beyond the scope of this example.
