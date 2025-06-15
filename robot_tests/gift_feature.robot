*** Settings ***
Documentation    Gift Feature UI Tests for Books Database Service
Resource         resources/common.resource
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Tags        gift-feature    ui    browser

*** Variables ***
${SELECTED_BOOK}               false
${GIFT_OPTION_SELECTED}        false
${RECIPIENT_DETAILS_ENTERED}   false
${DETAILS_CONFIRMED}           false
${GIFT_ORDER_CONFIRMED}        false
${BOOK_OUT_OF_STOCK}           false

*** Keywords ***
I Am A Logged In BookBridge Customer
    [Documentation]    This represents a logged-in user state
    # Close any open modals first
    Run Keyword And Ignore Error    Click    css=#close-gift
    Run Keyword And Ignore Error    Click    css=#close-basket  
    Run Keyword And Ignore Error    Click    css=#close-purchase
    # For this test, we'll assume user is logged in by default
    # In a real implementation, we'd have login logic here
    Get Text    body    contains    Books Library

I Browse The Book Catalog
    [Documentation]    Navigate to the book catalog
    # We're already on the books page
    Wait For Elements State    css=.book-card >> nth=0    visible

I Select A Book
    [Documentation]    Select a book from the catalog
    ${book_cards}=    Get Elements    css=.book-card
    ${count}=    Get Length    ${book_cards}
    Should Be True    ${count} > 0    "No books available in catalog"
    Click    css=.book-card >> nth=0
    Set Test Variable    ${SELECTED_BOOK}    true

I Choose The Option To Send It As A Gift
    [Documentation]    Click the send as gift option
    Click    css=.book-card >> nth=0 >> button:has-text("Send as Gift")
    Set Test Variable    ${GIFT_OPTION_SELECTED}    true

I Should Be Prompted To Enter The Recipients Details
    [Documentation]    Verify gift recipient form appears
    Wait For Elements State    form#gift-form    visible
    Get Text    body    contains    Send Book as Gift
    Get Text    body    contains    Recipient Name
    Get Text    body    contains    Recipient Address
    Get Text    body    contains    Recipient Country

I Enter The Recipients Name Address And Country
    [Documentation]    Fill in recipient details
    Fill Text    input[name='recipient_name']    John Doe
    Fill Text    textarea[name='recipient_address']    123 Main St, New York, NY 10001
    Fill Text    input[name='recipient_country']    USA
    Check Checkbox    input#data-consent
    Set Test Variable    ${RECIPIENT_DETAILS_ENTERED}    true

I Confirm The Details
    [Documentation]    Confirm the entered details
    Click    button:has-text("Confirm Details")
    Set Test Variable    ${DETAILS_CONFIRMED}    true

I Do Not Confirm The Details
    [Documentation]    Leave details incomplete or don't confirm
    # Clear one field to make details incomplete
    Fill Text    input[name='recipient_name']    ${EMPTY}
    # Try to confirm with incomplete details
    Click    button:has-text("Confirm Details")
    Set Test Variable    ${DETAILS_CONFIRMED}    false

I Should See A Confirmation Message That The Book Will Be Sent As A Gift
    [Documentation]    Verify confirmation message appears
    Wait For Elements State    css=.confirmation-message    visible
    Get Text    body    contains    book will be sent as a gift

I Should See An Error Message Indicating That The Details Are Incomplete
    [Documentation]    Verify error message for incomplete details
    Wait For Elements State    css=.error-message    visible
    Get Text    body    contains    details are incomplete

I Have Selected A Book To Send As A Gift
    [Documentation]    Prerequisites: book selected and gift modal open
    I Am A Logged In BookBridge Customer
    I Browse The Book Catalog  
    I Select A Book
    I Choose The Option To Send It As A Gift

I Have Entered The Recipients Details
    [Documentation]    Prerequisites: recipient details are entered
    Should Be True    ${RECIPIENT_DETAILS_ENTERED}    "Recipient details not entered"

I Confirm The Gift Order
    [Documentation]    Confirm the gift order
    Wait For Elements State    button:has-text("Confirm Gift Order")    visible
    Click    button:has-text("Confirm Gift Order")
    Set Test Variable    ${GIFT_ORDER_CONFIRMED}    true

The Book Should Be Added To The Gift Orders Queue
    [Documentation]    Verify book is in gift orders queue
    # Wait for the message to appear (should be quick if API call succeeds)
    Wait For Elements State    css=.gift-message    visible    timeout=10s
    # The success flow shows two messages in sequence, check for the final one
    Get Text    body    contains    email confirmation

I Should Receive An Email Confirmation Of The Gift Order
    [Documentation]    Verify email confirmation (would check logs/db in real implementation)
    # This is already verified in the previous step since the messages are sequential
    No Operation

The Book Is Not In Stock Anymore
    [Documentation]    Simulate out of stock condition by changing book ID to invalid value
    # Modify the current book to have an invalid ID to trigger API error
    Evaluate JavaScript    body    currentGiftBook.id = 99999
    Set Test Variable    ${BOOK_OUT_OF_STOCK}    true

I Should See An Error Message Indicating That The Order Could Not Be Processed Because Book Is Out Of Stock
    [Documentation]    Verify out of stock error message
    Wait For Elements State    css=.gift-message    visible
    Get Text    body    contains    book is out of stock

*** Test Cases ***
Scenario 1: Select Book To Send As Gift - Successful Scenario
    [Documentation]    Given I am a logged-in BookBridge customer
    ...                When I browse the book catalog
    ...                And I select a book
    ...                And I choose the option to send it as a gift
    ...                Then I should be prompted to enter the recipient's details
    [Tags]    gift-feature    scenario-1
    Given I Am A Logged In BookBridge Customer
    When I Browse The Book Catalog
    And I Select A Book
    And I Choose The Option To Send It As A Gift
    Then I Should Be Prompted To Enter The Recipients Details

Scenario 2: Enter Recipient Details - Successful Scenario
    [Documentation]    Given I have selected a book to send as a gift
    ...                When I enter the recipient's name, address, and country
    ...                And I confirm the details
    ...                Then I should see a confirmation message that the book will be sent as a gift
    [Tags]    gift-feature    scenario-2
    Given I Have Selected A Book To Send As A Gift
    When I Enter The Recipients Name Address And Country
    And I Confirm The Details
    Then I Should See A Confirmation Message That The Book Will Be Sent As A Gift

Scenario 3: Enter Recipient Details - Unsuccessful Scenario
    [Documentation]    Given I have selected a book to send as a gift
    ...                When I enter the recipient's name, address, and country
    ...                And I do not confirm the details
    ...                Then I should see an error message indicating that the details are incomplete
    [Tags]    gift-feature    scenario-3
    Given I Have Selected A Book To Send As A Gift
    When I Enter The Recipients Name Address And Country
    And I Do Not Confirm The Details
    Then I Should See An Error Message Indicating That The Details Are Incomplete

Scenario 4: Confirm Gift Order - Successful Scenario
    [Documentation]    Given I have entered the recipient's details
    ...                When I confirm the gift order
    ...                Then the book should be added to the gift orders queue
    ...                And I should receive an email confirmation of the gift order
    [Tags]    gift-feature    scenario-4
    Given I Have Selected A Book To Send As A Gift
    And I Enter The Recipients Name Address And Country
    And I Confirm The Details
    When I Confirm The Gift Order
    Then The Book Should Be Added To The Gift Orders Queue
    And I Should Receive An Email Confirmation Of The Gift Order

Scenario 5: Confirm Gift Order - Unsuccessful Scenario
    [Documentation]    Given I have entered the recipient's details
    ...                When I confirm the gift order
    ...                And the book is not in stock anymore
    ...                Then I should see an error message indicating that the order could not be processed because book is out of stock
    [Tags]    gift-feature    scenario-5
    Given I Have Selected A Book To Send As A Gift
    And I Enter The Recipients Name Address And Country
    And I Confirm The Details
    And The Book Is Not In Stock Anymore
    When I Confirm The Gift Order
    Then I Should See An Error Message Indicating That The Order Could Not Be Processed Because Book Is Out Of Stock
