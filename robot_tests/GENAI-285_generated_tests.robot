*** Settings ***
Documentation    This test suite verifies the book recommendation feature for various special days.
Library          Browser

*** Variables ***
${URL}           http://bookbridge.example.com

*** Test Cases ***
Receive recommendations for Valentine's Day - successful scenario
    [Documentation]    Verify that a user receives book recommendations for Valentine's Day
    [Tags]    req-GENAI-283    type-ok
    Given I am a BookBridge user
    When I request book recommendations for Valentine's Day
    Then I should receive a list of book recommendations suitable for Valentine's Day

Receive recommendations for Valentine's Day with no available recommendations - unsuccessful scenario
    [Documentation]    Verify that a user receives a message when no book recommendations are available for Valentine's Day
    [Tags]    req-GENAI-283    type-nok
    Given I am a BookBridge user
    When I request book recommendations for Valentine's Day
    And there are no available book recommendations for Valentine's Day
    Then I should receive a message indicating that no recommendations are available

Receive recommendations for Mother's Day - successful scenario
    [Documentation]    Verify that a user receives book recommendations for Mother's Day
    [Tags]    req-GENAI-283    type-ok
    Given I am a BookBridge user
    When I request book recommendations for Mother's Day
    Then I should receive a list of book recommendations suitable for Mother's Day

Receive recommendations for Mother's Day with no available recommendations - unsuccessful scenario
    [Documentation]    Verify that a user receives a message when no book recommendations are available for Mother's Day
    [Tags]    req-GENAI-283    type-nok
    Given I am a BookBridge user
    When I request book recommendations for Mother's Day
    And there are no available book recommendations for Mother's Day
    Then I should receive a message indicating that no recommendations are available

Receive recommendations for Best Colleague Day - successful scenario
    [Documentation]    Verify that a user receives book recommendations for Best Colleague Day
    [Tags]    req-GENAI-283    type-ok
    Given I am a BookBridge user
    When I request book recommendations for Best Colleague Day
    Then I should receive a list of book recommendations suitable for Best Colleague Day

Receive recommendations for Best Colleague Day with no available recommendations - unsuccessful scenario
    [Documentation]    Verify that a user receives a message when no book recommendations are available for Best Colleague Day
    [Tags]    req-GENAI-283    type-nok
    Given I am a BookBridge user
    When I request book recommendations for Best Colleague Day
    And there are no available book recommendations for Best Colleague Day
    Then I should receive a message indicating that no recommendations are available

*** Keywords ***
I am a BookBridge user
    Browser.New Context
    Browser.New Page    ${URL}
    Browser.Wait For Elements State    text=BookBridge    visible

I request book recommendations for Valentine's Day
    Browser.Click    text=Valentine's Day Recommendations

I request book recommendations for Mother's Day
    Browser.Click    text=Mother's Day Recommendations

I request book recommendations for Best Colleague Day
    Browser.Click    text=Best Colleague Day Recommendations

there are no available book recommendations for Valentine's Day
    Browser.Wait For Elements State    text=No recommendations available    visible

there are no available book recommendations for Mother's Day
    Browser.Wait For Elements State    text=No recommendations available    visible

there are no available book recommendations for Best Colleague Day
    Browser.Wait For Elements State    text=No recommendations available    visible

I should receive a list of book recommendations suitable for Valentine's Day
    Browser.Wait For Elements State    text=Valentine's Day Book Recommendations    visible

I should receive a list of book recommendations suitable for Mother's Day
    Browser.Wait For Elements State    text=Mother's Day Book Recommendations    visible

I should receive a list of book recommendations suitable for Best Colleague Day
    Browser.Wait For Elements State    text=Best Colleague Day Book Recommendations    visible

I should receive a message indicating that no recommendations are available
    Browser.Wait For Elements State    text=No recommendations available    visible
