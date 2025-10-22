*** Settings ***
Documentation    Common resource file with shared keywords, variables and settings
Library          Browser
Library          RequestsLibrary
Library          Collections
Library          OperatingSystem
Library          Process


*** Variables ***
# Application URLs
${BASE_URL}              http://localhost:8000
${UI_URL}                ${BASE_URL}
${API_URL}               ${BASE_URL}/books

# Browser Settings
${BROWSER}               chromium
${HEADLESS}              False
${BROWSER_TIMEOUT}       10s

# Docker Settings
${DOCKER_COMPOSE_FILE}   docker-compose.yml
${DOCKER_STARTUP_WAIT}   5s

# Test Data
${TEST_BOOK_TITLE}       The Great Gatsby
${TEST_BOOK_AUTHOR}      F. Scott Fitzgerald
${TEST_BOOK_PAGES}       180
${TEST_BOOK_CATEGORY}    Fiction


*** Keywords ***
Start Docker Environment
    [Documentation]    Start the application using Docker Compose
    ${result}=    Run Process    docker-compose    up    -d
    ...    cwd=${CURDIR}${/}..${/}..
    ...    shell=True
    ...    stdout=PIPE
    ...    stderr=PIPE
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=Failed to start Docker containers: ${result.stderr}
    Log    Docker containers started: ${result.stdout}
    Sleep    ${DOCKER_STARTUP_WAIT}    reason=Wait for application to initialize
    Wait Until Application Is Ready

Stop Docker Environment
    [Documentation]    Stop and remove Docker containers
    ${result}=    Run Process    docker-compose    down
    ...    cwd=${CURDIR}${/}..${/}..
    ...    shell=True
    ...    stdout=PIPE
    ...    stderr=PIPE
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=Failed to stop Docker containers: ${result.stderr}
    Log    Docker containers stopped: ${result.stdout}

Wait Until Application Is Ready
    [Documentation]    Wait until the application is ready to accept requests
    Wait Until Keyword Succeeds    30s    2s    Application Should Be Running

Application Should Be Running
    [Documentation]    Verify that the application is responding to requests
    ${response}=    GET    ${BASE_URL}    expected_status=200
    Status Should Be    200    ${response}

Clean Up Test Data
    [Documentation]    Remove all test data from the database
    ${response}=    GET    ${API_URL}
    IF    ${response.status_code} == 200
        ${books}=    Set Variable    ${response.json()}
        FOR    ${book}    IN    @{books}
            DELETE    ${API_URL}/${book}[id]    expected_status=any
        END
    END

Create Test Book
    [Documentation]    Create a test book via API and return the book data
    [Arguments]    ${title}=${TEST_BOOK_TITLE}    ${author}=${TEST_BOOK_AUTHOR}    
    ...            ${pages}=${TEST_BOOK_PAGES}    ${category}=${TEST_BOOK_CATEGORY}
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    ...    favorite=${False}
    ${response}=    POST    ${API_URL}    json=${book_data}
    Status Should Be    200    ${response}
    ${created_book}=    Set Variable    ${response.json()}
    Log    Created test book with ID: ${created_book}[id]
    RETURN    ${created_book}

Verify Book Exists
    [Documentation]    Verify that a book exists in the database
    [Arguments]    ${book_id}
    ${response}=    GET    ${API_URL}/${book_id}
    Status Should Be    200    ${response}
    RETURN    ${response.json()}

Delete Book By ID
    [Documentation]    Delete a book by its ID
    [Arguments]    ${book_id}
    ${response}=    DELETE    ${API_URL}/${book_id}
    Status Should Be    200    ${response}

Generate Random Book Data
    [Documentation]    Generate random book data for testing
    ${timestamp}=    Get Time    epoch
    ${title}=    Set Variable    Test Book ${timestamp}
    ${author}=    Set Variable    Test Author ${timestamp}
    ${pages}=    Evaluate    random.randint(100, 500)
    ${categories}=    Create List    Fiction    Non-Fiction    Fantasy    Science Fiction    Mystery
    ${category}=    Evaluate    random.choice(${categories})
    ${book_data}=    Create Dictionary
    ...    title=${title}
    ...    author=${author}
    ...    pages=${pages}
    ...    category=${category}
    RETURN    ${book_data}
