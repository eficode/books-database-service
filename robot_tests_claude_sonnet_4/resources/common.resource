*** Settings ***
Documentation    Common resource file for Books Database Service tests
Library          Browser
Library          RequestsLibrary
Library          Collections
Library          String

*** Variables ***
${BASE_URL}              http://localhost:8000
${API_URL}               ${BASE_URL}/api/books
${BROWSER_TYPE}          chromium
${HEADLESS}              True
${TIMEOUT}               10s

# Test Data
${VALID_BOOK_TITLE}      Test Book Title
${VALID_BOOK_AUTHOR}     Test Author
${VALID_BOOK_PAGES}      250
${VALID_BOOK_CATEGORY}   Fiction

*** Keywords ***
Setup Test Environment
    [Documentation]    Setup test environment with Docker
    Run Process    docker-compose    up    -d    shell=True    cwd=${CURDIR}/../..
    Sleep    5s    # Wait for services to start

Teardown Test Environment
    [Documentation]    Cleanup test environment
    Run Process    docker-compose    down    shell=True    cwd=${CURDIR}/../..

Wait For Element To Be Visible
    [Documentation]    Wait for element to be visible with timeout
    [Arguments]    ${locator}    ${timeout}=${TIMEOUT}
    Wait For Elements State    ${locator}    visible    timeout=${timeout}

Wait For Element To Be Enabled
    [Documentation]    Wait for element to be enabled with timeout
    [Arguments]    ${locator}    ${timeout}=${TIMEOUT}
    Wait For Elements State    ${locator}    enabled    timeout=${timeout}

Generate Random Book Data
    [Documentation]    Generate random book data for testing
    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${title}=    Set Variable    Test Book ${random_suffix}
    ${author}=    Set Variable    Test Author ${random_suffix}
    ${pages}=    Evaluate    random.randint(100, 500)    modules=random
    ${category}=    Set Variable    Fiction
    RETURN    ${title}    ${author}    ${pages}    ${category}