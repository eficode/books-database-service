*** Settings ***
Documentation    Common resources for Books Database Service tests
Library          Browser
Library          RequestsLibrary
Library          Collections

*** Variables ***
${BASE_URL}         http://localhost:8000
${API_URL}          ${BASE_URL}/api/v1
${BROWSER}          chromium
${HEADLESS}         True
${TIMEOUT}          10s

*** Keywords ***
Setup Test Environment
    [Documentation]    Initialize test environment
    Set Browser Timeout    ${TIMEOUT}

Teardown Test Environment
    [Documentation]    Clean up test environment
    Close Browser

Wait For Element And Click
    [Documentation]    Wait for element to be visible and click it
    [Arguments]    ${locator}
    Wait For Elements State    ${locator}    visible    timeout=${TIMEOUT}
    Click    ${locator}

Wait For Element And Type
    [Documentation]    Wait for element and type text
    [Arguments]    ${locator}    ${text}
    Wait For Elements State    ${locator}    visible    timeout=${TIMEOUT}
    Fill Text    ${locator}    ${text}

Verify Element Contains Text
    [Documentation]    Verify element contains expected text
    [Arguments]    ${locator}    ${expected_text}
    Wait For Elements State    ${locator}    visible    timeout=${TIMEOUT}
    Get Text    ${locator}    contains    ${expected_text}