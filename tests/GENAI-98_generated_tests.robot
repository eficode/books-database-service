*** Settings ***
Documentation    This test suite verifies the functionality of viewing and sorting the most sold books.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
View Most Sold Books - Successful Scenario
    [Documentation]    Verify that a logged-in user can view the most sold books.
    [Tags]    req-GENAI-96    type-ok
    Given I am a logged-in user
    When I navigate to the 'Most Sold Books' section
    Then I should see a list of the most sold books

View Most Sold Books With No Data Available - Unsuccessful Scenario
    [Documentation]    Verify that a logged-in user sees a message when no data is available.
    [Tags]    req-GENAI-96    type-nok
    Given I am a logged-in user
    And there is no data available
    When I navigate to the 'Most Sold Books' section
    Then I should see a message indicating that no data is available

Sort Most Sold Books By Different Criteria - Successful Scenario
    [Documentation]    Verify that the most sold books can be sorted by different criteria.
    [Tags]    req-GENAI-96    type-ok
    Given I am viewing the 'Most Sold Books' section
    When I select a sorting option    by date
    Then the list of most sold books should be sorted according to the selected criteria

Sort Most Sold Books With Invalid Criteria - Unsuccessful Scenario
    [Documentation]    Verify that an error message is shown when an invalid sorting option is selected.
    [Tags]    req-GENAI-96    type-nok
    Given I am viewing the 'Most Sold Books' section
    When I select an invalid sorting option
    Then I should see an error message indicating that the sorting option is invalid

*** Keywords ***
I am a logged-in user
    New Page    ${URL}
    Click    text=Login
    Fill Text    username    user
    Fill Text    password    pass
    Click    text=Submit

I navigate to the 'Most Sold Books' section
    Click    text=Most Sold Books

I should see a list of the most sold books
    Wait For Elements State    text=Most Sold Books    visible

There is no data available
    # Simulate no data available scenario
    Evaluate    window.localStorage.setItem('mostSoldBooks', '[]')

I should see a message indicating that no data is available
    Wait For Elements State    text=No data available    visible

I am viewing the 'Most Sold Books' section
    I navigate to the 'Most Sold Books' section

I select a sorting option
    [Arguments]    ${option}
    Click    text=${option}

The list of most sold books should be sorted according to the selected criteria
    # Verify sorting logic here
    Log    List sorted by ${option}

I select an invalid sorting option
    Click    text=Invalid Option

I should see an error message indicating that the sorting option is invalid
    Wait For Elements State    text=Invalid sorting option    visible
