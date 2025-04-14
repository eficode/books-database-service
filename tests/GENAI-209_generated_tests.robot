*** Settings ***
Documentation    This test suite verifies the functionality of sending a book and Mother's Day gift through BookBridge.
Library          Browser

*** Variables ***
${URL}           https://bookbridge.example.com
${USERNAME}      testuser
${PASSWORD}      password123

*** Test Cases ***
Select book and gift - successful scenario
    [Documentation]    Verify that a logged-in user can select a book and gift successfully.
    [Tags]    req-GENAI-207    type-ok
    I am a logged-in BookBridge user
    I navigate to the 'Send Gift' section
    I select a book to be sent as a Mother's Day gift
    I should be able to proceed to the delivery details page

Select book and gift - unsuccessful scenario
    [Documentation]    Verify that a blacklisted user cannot proceed to the delivery details page.
    [Tags]    req-GENAI-207    type-nok
    I am a logged-in BookBridge user
    User is listed in black list because of unpaid purchases
    I navigate to the 'Send Gift' section
    I should not be able to proceed to the delivery details page

Enter delivery details - successful scenario
    [Documentation]    Verify that entering valid delivery details shows a confirmation message.
    [Tags]    req-GENAI-207    type-ok
    I have selected a book and a Mother's Day gift
    I enter the recipient's address in another city
    I confirm the delivery details
    I should see a confirmation message that the gift will be sent

Enter delivery details - unsuccessful scenario
    [Documentation]    Verify that entering incomplete delivery details shows an error message.
    [Tags]    req-GENAI-207    type-nok
    I have selected a book and a Mother's Day gift
    I enter an incomplete recipient's address
    I confirm the delivery details
    I should see an error message indicating that the address is incomplete

Confirm delivery - successful scenario
    [Documentation]    Verify that the recipient receives the gift at the specified address after dispatch.
    [Tags]    req-GENAI-207    type-ok
    I have confirmed the delivery details
    The gift is dispatched
    The recipient should receive the book and Mother's Day gift at the specified address

*** Keywords ***
I am a logged-in BookBridge user
    New Browser    chromium
    New Page    ${URL}
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    id=login
    Wait For Elements State    id=logged-in    visible

I navigate to the 'Send Gift' section
    Click    id=send-gift
    Wait For Elements State    id=gift-selection    visible

I select a book to be sent as a Mother's Day gift
    Click    id=select-book
    Click    id=select-mothers-day-gift
    Wait For Elements State    id=delivery-details    visible

I should be able to proceed to the delivery details page
    Wait For Elements State    id=delivery-details    visible

User is listed in black list because of unpaid purchases
    # Simulate the user being blacklisted
    Set Test Variable    ${BLACKLISTED}    True

I should not be able to proceed to the delivery details page
    Wait For Elements State    id=delivery-details    hidden

I have selected a book and a Mother's Day gift
    I am a logged-in BookBridge user
    I navigate to the 'Send Gift' section
    I select a book to be sent as a Mother's Day gift

I enter the recipient's address in another city
    Fill Text    id=address    123 Another City

I confirm the delivery details
    Click    id=confirm-delivery
    Wait For Elements State    id=confirmation-message    visible

I should see a confirmation message that the gift will be sent
    Wait For Elements State    id=confirmation-message    visible

I enter an incomplete recipient's address
    Fill Text    id=address    Incomplete Address

I should see an error message indicating that the address is incomplete
    Wait For Elements State    id=error-message    visible

I have confirmed the delivery details
    I have selected a book and a Mother's Day gift
    I enter the recipient's address in another city
    I confirm the delivery details

The gift is dispatched
    # Simulate the dispatch process
    Set Test Variable    ${DISPATCHED}    True

The recipient should receive the book and Mother's Day gift at the specified address
    Wait For Elements State    id=delivery-confirmation    visible
