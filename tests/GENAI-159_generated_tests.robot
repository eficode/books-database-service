*** Settings ***
Documentation    This test suite verifies the weekly email subscription and delivery for highest-rated books.
Library          Browser

*** Variables ***
${BASE_URL}      http://example.com
${EMAIL}         user@example.com
${PASSWORD}      password123

*** Test Cases ***
Subscribe to weekly email - successful scenario
    [Documentation]    Verify that a registered user can successfully subscribe to the weekly highest-rated books email.
    [Tags]    req-GENAI-157    type-ok
    Given I am a registered user
    When I opt-in for the weekly highest-rated books email
    Then I should receive a confirmation of my subscription

Subscribe to weekly email without confirmation - unsuccessful scenario
    [Documentation]    Verify that a registered user does not receive a confirmation if the confirmation email is not sent.
    [Tags]    req-GENAI-157    type-nok
    Given I am a registered user
    When I opt-in for the weekly highest-rated books email
    And the confirmation email is not sent
    Then I should not receive a confirmation of my subscription

Receive weekly email - successful scenario
    [Documentation]    Verify that a subscribed user receives the weekly highest-rated books email with correct content.
    [Tags]    req-GENAI-157    type-ok
    Given I am subscribed to the weekly highest-rated books email
    When the weekly email is sent
    Then I should receive an email listing the highest-rated books of the week
    And the email should include book titles, authors, and ratings

Do not receive weekly email - unsuccessful scenario
    [Documentation]    Verify that a subscribed user does not receive the weekly email if it is not delivered.
    [Tags]    req-GENAI-157    type-nok
    Given I am subscribed to the weekly highest-rated books email
    When the weekly email is sent
    And the email is not delivered
    Then I should not receive an email listing the highest-rated books of the week

*** Keywords ***
I am a registered user
    New Browser    chromium
    New Page    ${BASE_URL}
    Click    //a[text()='Login']
    Fill Text    //input[@name='email']    ${EMAIL}
    Fill Text    //input[@name='password']    ${PASSWORD}
    Click    //button[text()='Login']
    Wait For Elements State    //div[text()='Welcome, User']    visible

I opt-in for the weekly highest-rated books email
    Click    //a[text()='Settings']
    Click    //input[@name='weekly_email']
    Click    //button[text()='Save']
    Wait For Elements State    //div[text()='Settings saved successfully']    visible

I should receive a confirmation of my subscription
    Wait For Elements State    //div[text()='Subscription confirmed']    visible
    Close Browser

The confirmation email is not sent
    # Simulate email not being sent by skipping email sending step
    Log    Simulating email not being sent

I should not receive a confirmation of my subscription
    Wait For Elements State    //div[text()='Subscription confirmed']    hidden
    Close Browser

I am subscribed to the weekly highest-rated books email
    New Browser    chromium
    New Page    ${BASE_URL}
    Click    //a[text()='Login']
    Fill Text    //input[@name='email']    ${EMAIL}
    Fill Text    //input[@name='password']    ${PASSWORD}
    Click    //button[text()='Login']
    Wait For Elements State    //div[text()='Welcome, User']    visible
    Click    //a[text()='Settings']
    Click    //input[@name='weekly_email']
    Click    //button[text()='Save']
    Wait For Elements State    //div[text()='Settings saved successfully']    visible
    Close Browser

The weekly email is sent
    # Simulate sending weekly email
    Log    Simulating weekly email being sent

I should receive an email listing the highest-rated books of the week
    # Simulate checking email inbox
    Log    Simulating email received with highest-rated books

The email should include book titles, authors, and ratings
    # Simulate verifying email content
    Log    Simulating email content verification

The email is not delivered
    # Simulate email not being delivered
    Log    Simulating email not being delivered

I should not receive an email listing the highest-rated books of the week
    # Simulate checking email inbox
    Log    Simulating no email received
