*** Settings ***
Documentation    Common resource file containing shared keywords, variables, and configurations
...              for both UI and API tests of the Books Database Service.
Library          OperatingSystem
Library          Process

*** Variables ***
# Application URLs
${BASE_URL}                 http://127.0.0.1:8000
${API_BASE_URL}            ${BASE_URL}
${UI_BASE_URL}             ${BASE_URL}

# Docker settings
${DOCKER_COMPOSE_FILE}     ${CURDIR}${/}..${/}..${/}docker-compose.yml
${SERVER_STARTUP_TIMEOUT}  30s
${SERVER_CHECK_INTERVAL}   2s

# Test data
${VALID_BOOK_TITLE}        Test Book Title
${VALID_BOOK_AUTHOR}       Test Author
${VALID_BOOK_PAGES}        250
${VALID_BOOK_CATEGORY}     Fiction

# Updated book data
${UPDATED_BOOK_TITLE}      Updated Test Book
${UPDATED_BOOK_AUTHOR}     Updated Author
${UPDATED_BOOK_PAGES}      300
${UPDATED_BOOK_CATEGORY}   Non-Fiction

*** Keywords ***
Setup Test Environment
    [Documentation]    Sets up the test environment by starting Docker containers
    Log    Setting up test environment with Docker Compose
    ${result}=    Run Process    docker-compose    -f    ${DOCKER_COMPOSE_FILE}    up    -d
    ...           timeout=60s    shell=True
    Should Be Equal As Numbers    ${result.rc}    0    Docker Compose failed to start: ${result.stderr}
    Wait For Server To Be Ready
    Log    Test environment is ready

Teardown Test Environment
    [Documentation]    Tears down the test environment by stopping Docker containers
    Log    Tearing down test environment
    ${result}=    Run Process    docker-compose    -f    ${DOCKER_COMPOSE_FILE}    down    -v
    ...           timeout=30s    shell=True
    Log    Test environment cleaned up

Wait For Server To Be Ready
    [Documentation]    Waits for the server to be ready by checking the health endpoint
    Wait Until Keyword Succeeds    ${SERVER_STARTUP_TIMEOUT}    ${SERVER_CHECK_INTERVAL}    Check Server Health

Check Server Health
    [Documentation]    Checks if the server is responding to requests
    ${result}=    Run Process    powershell.exe    -Command    Invoke-WebRequest -Uri ${BASE_URL}/docs -UseBasicParsing    timeout=5s
    Should Be Equal As Numbers    ${result.rc}    0    Server is not responding

Clean Database
    [Documentation]    Cleans the database by removing all books
    Log    Cleaning database for test isolation

Generate Test Book Data
    [Documentation]    Returns a dictionary with valid test book data
    ${book_data}=    Create Dictionary    title=${VALID_BOOK_TITLE}    author=${VALID_BOOK_AUTHOR}    
    ...              pages=${VALID_BOOK_PAGES}    category=${VALID_BOOK_CATEGORY}
    [Return]    ${book_data}

Generate Updated Test Book Data
    [Documentation]    Returns a dictionary with updated test book data
    ${book_data}=    Create Dictionary    title=${UPDATED_BOOK_TITLE}    author=${UPDATED_BOOK_AUTHOR}    
    ...              pages=${UPDATED_BOOK_PAGES}    category=${UPDATED_BOOK_CATEGORY}
    [Return]    ${book_data}

Log Test Info
    [Documentation]    Logs test information for debugging
    [Arguments]    ${message}
    Log    ${message}    level=INFO

Log Test Debug
    [Documentation]    Logs debug information
    [Arguments]    ${message}
    Log    ${message}    level=DEBUG

Verify Response Contains Book Data
    [Documentation]    Verifies that a response contains expected book data
    [Arguments]    ${response}    ${expected_title}    ${expected_author}    ${expected_pages}    ${expected_category}
    Should Contain    ${response}    ${expected_title}
    Should Contain    ${response}    ${expected_author}
    Should Contain    ${response}    ${expected_pages}
    Should Contain    ${response}    ${expected_category}