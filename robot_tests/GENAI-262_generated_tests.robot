*** Settings ***
Documentation    This test suite verifies the gift selection and delivery confirmation process for Mother's Day gifts.
Library          Browser

*** Variables ***
${GIFT_SELECTION_URL}    https://example.com/gift-selection
${VALID_ADDRESS}         123 Happy St, Joytown
${INVALID_ADDRESS}       Invalid Address

*** Test Cases ***
Select gift and provide recipient details - successful scenario
    [Documentation]    Verify that a customer can select a gift and provide a valid delivery address successfully.
    [Tags]    req-GENAI-260    type-ok
    Given I am a customer on the gift selection page
    When I choose a Mother's Day gift
    And I provide my mother's delivery address
    Then I should see a confirmation that the gift will be sent directly to my mother

Select gift and provide recipient details - unsuccessful scenario
    [Documentation]    Verify that a customer receives an error message when providing an invalid delivery address.
    [Tags]    req-GENAI-260    type-nok
    Given I am a customer on the gift selection page
    When I choose a Mother's Day gift
    And I provide an invalid delivery address
    Then I should see an error message indicating that the address is invalid

Confirm gift delivery - successful scenario
    [Documentation]    Verify that a customer receives a notification when the gift is delivered successfully.
    [Tags]    req-GENAI-260    type-ok
    Given I have sent a Mother's Day gift
    When the gift is delivered to my mother
    Then I should receive a notification confirming the delivery

Confirm gift delivery - unsuccessful scenario
    [Documentation]    Verify that a customer receives a notification when the gift delivery fails.
    [Tags]    req-GENAI-260    type-nok
    Given I have sent a Mother's Day gift
    When the gift is not delivered to my mother due to an issue
    Then I should receive a notification indicating the delivery failure

*** Keywords ***
I am a customer on the gift selection page
    New Browser    headless=False
    New Page    ${GIFT_SELECTION_URL}

I choose a Mother's Day gift
    Click    text=Mother's Day Gifts
    Click    text=Select Gift

I provide my mother's delivery address
    Fill Text    id=address    ${VALID_ADDRESS}
    Click    id=submit

I provide an invalid delivery address
    Fill Text    id=address    ${INVALID_ADDRESS}
    Click    id=submit

I should see a confirmation that the gift will be sent directly to my mother
    Wait For Elements State    text=Your gift will be sent directly to your mother    visible

I should see an error message indicating that the address is invalid
    Wait For Elements State    text=The address you provided is invalid    visible

I have sent a Mother's Day gift
    # Assuming the gift sending process is already tested in previous steps
    Log    Mother's Day gift has been sent

The gift is delivered to my mother
    # Simulate the delivery process
    Log    The gift has been delivered

I should receive a notification confirming the delivery
    Wait For Elements State    text=Your gift has been delivered    visible

The gift is not delivered to my mother due to an issue
    # Simulate the delivery failure process
    Log    The gift delivery has failed

I should receive a notification indicating the delivery failure
    Wait For Elements State    text=There was an issue delivering your gift    visible
