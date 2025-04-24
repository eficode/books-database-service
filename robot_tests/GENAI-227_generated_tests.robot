*** Settings ***
Documentation    This test suite verifies the functionality of sending a book as a Mother's Day gift on the Bookbridge platform.
Library           Browser

*** Variables ***
${BOOK_URL}    https://bookbridge.com

*** Test Cases ***
Select book and recipient - successful scenario
    [Documentation]    Verify that a logged-in user can select a book and enter recipient details successfully.
    [Tags]    req-GENAI-225    type-ok
    Given I am a logged-in Bookbridge end user
    When I select a book to send as a gift
    And I choose 'Send as Mother's Day Gift' option
    Then I should be prompted to enter the recipient's details
    And I should be able to confirm the delivery address

Select book and recipient with missing details - unsuccessful scenario
    [Documentation]    Verify that a logged-in user cannot proceed without entering recipient details.
    [Tags]    req-GENAI-225    type-nok
    Given I am a logged-in Bookbridge end user
    When I select a book to send as a gift
    And I choose 'Send as Mother's Day Gift' option
    And I do not enter the recipient's details
    Then I should not be able to confirm the delivery address
    And I should see an error message prompting me to enter the recipient's details

Confirm and send gift - successful scenario
    [Documentation]    Verify that a user can confirm the delivery address and proceed to checkout successfully.
    [Tags]    req-GENAI-225    type-ok
    Given I have entered the recipient's details
    When I confirm the delivery address
    And I proceed to checkout
    Then I should see a confirmation message that the book will be delivered directly to the recipient
    And the delivery should be initiated immediately

Confirm and send gift with invalid address - unsuccessful scenario
    [Documentation]    Verify that a user cannot proceed with an invalid delivery address.
    [Tags]    req-GENAI-225    type-nok
    Given I have entered the recipient's details
    When I confirm the delivery address
    And the address is invalid
    Then I should not be able to proceed to checkout
    And I should see an error message indicating the address is invalid

*** Keywords ***
I am a logged-in Bookbridge end user
    New Browser    chromium
    New Page    ${BOOK_URL}
    Click    text=Login
    Fill Text    id=username    myusername
    Fill Text    id=password    mypassword
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I select a book to send as a gift
    Click    text=Books
    Click    text=The Great Gatsby

I choose 'Send as Mother's Day Gift' option
    Click    text=Send as Mother's Day Gift

I should be prompted to enter the recipient's details
    Wait For Elements State    id=recipient-details    visible

I should be able to confirm the delivery address
    Fill Text    id=recipient-name    Jane Doe
    Fill Text    id=recipient-address    123 Main St, Springfield
    Click    text=Confirm Address
    Wait For Elements State    text=Address Confirmed    visible

I do not enter the recipient's details
    # Intentionally leave recipient details empty
    No Operation

I should not be able to confirm the delivery address
    Click    text=Confirm Address
    Wait For Elements State    text=Please enter recipient details    visible

I should see an error message prompting me to enter the recipient's details
    Wait For Elements State    text=Please enter recipient details    visible

I have entered the recipient's details
    Fill Text    id=recipient-name    Jane Doe
    Fill Text    id=recipient-address    123 Main St, Springfield

I confirm the delivery address
    Click    text=Confirm Address
    Wait For Elements State    text=Address Confirmed    visible

I proceed to checkout
    Click    text=Proceed to Checkout

I should see a confirmation message that the book will be delivered directly to the recipient
    Wait For Elements State    text=Your order has been placed    visible

The delivery should be initiated immediately
    Wait For Elements State    text=Delivery Initiated    visible

The address is invalid
    Fill Text    id=recipient-address    Invalid Address

I should not be able to proceed to checkout
    Click    text=Proceed to Checkout
    Wait For Elements State    text=Invalid Address    visible

I should see an error message indicating the address is invalid
    Wait For Elements State    text=Invalid Address    visible
