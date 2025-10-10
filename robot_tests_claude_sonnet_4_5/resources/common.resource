*** Settings ***
Documentation    Common resource file with shared variables and keywords

*** Variables ***
${BASE_URL}         http://localhost:8000
${API_URL}          ${BASE_URL}/books
${BROWSER}          chromium
${HEADLESS}         True
${TIMEOUT}          10s

*** Keywords ***
Generate Random String
    [Arguments]    ${prefix}=Test
    ${timestamp}=    Get Time    epoch
    ${random_string}=    Set Variable    ${prefix}_${timestamp}
    RETURN    ${random_string}

Wait For Response
    [Arguments]    ${timeout}=${TIMEOUT}
    Sleep    0.5s
