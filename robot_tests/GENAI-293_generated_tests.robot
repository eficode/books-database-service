*** Settings ***
Documentation    This test suite verifies the login and logout functionalities of the application.
Library          Browser

*** Variables ***
${LOGIN_URL}    https://example.com/login
${DASHBOARD_URL}    https://example.com/dashboard
${VALID_USERNAME}    user@example.com
${VALID_PASSWORD}    password123
${INVALID_USERNAME}    invalid@example.com
${INVALID_PASSWORD}    wrongpassword

*** Test Cases ***
Verify login functionality - successful scenario
    [Documentation]    Verify that a user can log in with valid credentials.
    [Tags]    req-GENAI-291    type-ok
    Given I am on the login page
    When I enter valid credentials
    Then I should be redirected to the dashboard
    And I should see a welcome message

Verify login functionality with invalid credentials - unsuccessful scenario
    [Documentation]    Verify that a user cannot log in with invalid credentials.
    [Tags]    req-GENAI-291    type-nok
    Given I am on the login page
    When I enter invalid credentials
    Then I should see an error message indicating invalid login

Verify logout functionality - successful scenario
    [Documentation]    Verify that a logged-in user can log out successfully.
    [Tags]    req-GENAI-291    type-ok
    Given I am logged in
    When I click the logout button
    Then I should be redirected to the login page
    And I should see a logout confirmation message

*** Keywords ***
I am on the login page
    New Page    ${LOGIN_URL}

I enter valid credentials
    Fill Text    username    ${VALID_USERNAME}
    Fill Text    password    ${VALID_PASSWORD}
    Click    login_button

I enter invalid credentials
    Fill Text    username    ${INVALID_USERNAME}
    Fill Text    password    ${INVALID_PASSWORD}
    Click    login_button

I should be redirected to the dashboard
    Wait Until Network Is Idle
    Get Url    ==    ${DASHBOARD_URL}

I should see a welcome message
    Get Text    welcome_message    ==    Welcome, user!

I should see an error message indicating invalid login
    Get Text    error_message    ==    Invalid username or password.

I am logged in
    New Page    ${LOGIN_URL}
    Fill Text    username    ${VALID_USERNAME}
    Fill Text    password    ${VALID_PASSWORD}
    Click    login_button
    Wait Until Network Is Idle
    Get Url    ==    ${DASHBOARD_URL}

I click the logout button
    Click    logout_button

I should be redirected to the login page
    Wait Until Network Is Idle
    Get Url    ==    ${LOGIN_URL}

I should see a logout confirmation message
    Get Text    confirmation_message    ==    You have been logged out.
