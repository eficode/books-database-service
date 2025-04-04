*** Settings ***
Documentation    This test suite verifies the functionality of the BookBridge Solution dashboard, including viewing quarterly book sales and exporting data.
Library          Browser

*** Variables ***
${URL}           http://bookbridge-solution.com/dashboard

*** Test Cases ***
View Quarterly Book Sales - Successful Scenario
    [Documentation]    Verify that the number of books sold in the last quarter is displayed.
    [Tags]    req-GENAI-185    type-ok
    Given I am a BookBridge Solution owner
    When I access the dashboard
    Then I should see the number of books sold in the last quarter

View Quarterly Book Sales with No Data Available - Unsuccessful Scenario
    [Documentation]    Verify that a message is displayed when no sales data is available for the last quarter.
    [Tags]    req-GENAI-185    type-nok
    Given I am a BookBridge Solution owner
    When I access the dashboard
    And there is no sales data for the last quarter
    Then I should see a message indicating that no sales data is available

Export Dashboard Data - Successful Scenario
    [Documentation]    Verify that the data can be exported in a printable format.
    [Tags]    req-GENAI-185    type-ok
    Given I am viewing the quarterly book sales dashboard
    When I choose to export the data
    Then I should be able to download the data in a printable format

Export Dashboard Data with Export Failure - Unsuccessful Scenario
    [Documentation]    Verify that an error message is displayed when the export process fails.
    [Tags]    req-GENAI-185    type-nok
    Given I am viewing the quarterly book sales dashboard
    When I choose to export the data
    And there is a failure in the export process
    Then I should see an error message indicating that the export failed

*** Keywords ***
I am a BookBridge Solution owner
    New Browser    headless=False
    New Page    ${URL}
    Wait For Elements State    "#dashboard"    visible

I access the dashboard
    Click    "#dashboard-link"
    Wait For Elements State    "#sales-data"    visible

I should see the number of books sold in the last quarter
    Wait For Elements State    "#sales-data"    visible
    ${sales_count}=    Get Text    "#sales-data"
    Should Not Be Empty    ${sales_count}

There is no sales data for the last quarter
    Evaluate    document.querySelector('#sales-data').innerText = ''

I should see a message indicating that no sales data is available
    Wait For Elements State    "#no-sales-data-message"    visible

I am viewing the quarterly book sales dashboard
    I am a BookBridge Solution owner
    I access the dashboard

I choose to export the data
    Click    "#export-button"
    Wait For Download    10s

I should be able to download the data in a printable format
    ${download_path}=    Get Downloaded Files
    File Should Exist    ${download_path}[0]

There is a failure in the export process
    Evaluate    document.querySelector('#export-button').setAttribute('disabled', 'true')

I should see an error message indicating that the export failed
    Wait For Elements State    "#export-error-message"    visible
