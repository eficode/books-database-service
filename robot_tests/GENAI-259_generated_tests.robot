*** Settings ***
Documentation    This test suite verifies the functionality of selecting and sending a Mother's Day present.
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      password123
${MOTHER_ADDRESS} 1234 Elm Street, Springfield
${INVALID_ADDRESS} invalid_address
${OUT_OF_STOCK_ITEM} out_of_stock_item

*** Test Cases ***
Select and send a Mother's Day present - successful scenario
    [Documentation]    Verify that a logged-in customer can successfully select and send a Mother's Day present to their mother.
    [Tags]    req-GENAI-257    type-ok
    Given I am a logged-in customer
    When I select a Mother's Day present
    And I choose the option to send it directly to my mother
    And I provide my mother's shipping address
    Then the present should be sent directly to my mother's address
    And I should receive a confirmation of the shipment

Select and send a Mother's Day present with invalid address - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot send a Mother's Day present if the provided address is invalid.
    [Tags]    req-GENAI-257    type-nok
    Given I am a logged-in customer
    When I select a Mother's Day present
    And I choose the option to send it directly to my mother
    And I provide an invalid shipping address
    Then the present should not be sent
    And I should receive an error message indicating the address is invalid

Select and send a Mother's Day present without address - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot send a Mother's Day present if no shipping address is provided.
    [Tags]    req-GENAI-257    type-nok
    Given I am a logged-in customer
    When I select a Mother's Day present
    And I choose the option to send it directly to my mother
    And I do not provide a shipping address
    Then the present should not be sent
    And I should receive an error message indicating the address is required

Select and send a Mother's Day present with API failure - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot send a Mother's Day present if the shipping service API is down.
    [Tags]    req-GENAI-257    type-nok
    Given I am a logged-in customer
    When I select a Mother's Day present
    And I choose the option to send it directly to my mother
    And I provide my mother's shipping address
    And the shipping service API is down
    Then the present should not be sent
    And I should receive an error message indicating the service is unavailable

Select and send a Mother's Day present with out-of-stock item - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer cannot send a Mother's Day present if the selected item is out of stock.
    [Tags]    req-GENAI-257    type-nok
    Given I am a logged-in customer
    When I select a Mother's Day present
    And I choose the option to send it directly to my mother
    And the selected present is out of stock
    Then the present should not be sent
    And I should receive an error message indicating the item is out of stock

*** Keywords ***
I am a logged-in customer
    Browser.New Context
    Browser.New Page    ${URL}
    Browser.Fill Text    id=username    ${USERNAME}
    Browser.Fill Text    id=password    ${PASSWORD}
    Browser.Click    id=login
    Browser.Wait For Elements State    text=Welcome, ${USERNAME}    state=visible

I select a Mother's Day present
    Browser.Click    text=Mother's Day Gifts
    Browser.Click    text=Select Gift

I choose the option to send it directly to my mother
    Browser.Click    id=send_directly

I provide my mother's shipping address
    Browser.Fill Text    id=shipping_address    ${MOTHER_ADDRESS}
    Browser.Click    id=confirm_address

I provide an invalid shipping address
    Browser.Fill Text    id=shipping_address    ${INVALID_ADDRESS}
    Browser.Click    id=confirm_address

I do not provide a shipping address
    Browser.Click    id=confirm_address

The present should be sent directly to my mother's address
    Browser.Wait For Elements State    text=Your gift has been sent to ${MOTHER_ADDRESS}    state=visible

I should receive a confirmation of the shipment
    Browser.Wait For Elements State    text=Confirmation of shipment    state=visible

The present should not be sent
    Browser.Wait For Elements State    text=Error    state=visible

I should receive an error message indicating the address is invalid
    Browser.Wait For Elements State    text=Invalid address    state=visible

I should receive an error message indicating the address is required
    Browser.Wait For Elements State    text=Address is required    state=visible

The shipping service API is down
    # Simulate API Failure
    Browser.Evaluate JavaScript    window.apiFailure = true;

I should receive an error message indicating the service is unavailable
    Browser.Wait For Elements State    text=Service is unavailable    state=visible

The selected present is out of stock
    # Simulate Out of Stock
    Browser.Evaluate JavaScript    window.outOfStock = true;

I should receive an error message indicating the item is out of stock
    Browser.Wait For Elements State    text=Item is out of stock    state=visible
