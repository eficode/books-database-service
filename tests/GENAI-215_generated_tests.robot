*** Settings ***
Documentation    This test suite verifies the export generation and access functionalities for customer business reports.
Library          Browser
Library          RequestsLibrary

*** Variables ***
${BASE_URL}      http://example.com
${API_ENDPOINT}  /api/export
${INVALID_PARAMS}  invalid_params
${INVALID_CREDENTIALS}  invalid_credentials

*** Test Cases ***
Generate export for customer business report - successful scenario
    [Documentation]    Verify that the system generates an export for a customer business report and makes it available via the API.
    [Tags]    req-GENAI-213    type-ok
    I am a Bookbridge business owner
    request to create an export for a customer business report
    system should generate the export and make it available via the API

Generate export for customer business report with invalid request - unsuccessful scenario
    [Documentation]    Verify that the system returns an error when an export request is made with invalid parameters.
    [Tags]    req-GENAI-213    type-nok
    I am a Bookbridge business owner
    request to create an export for a customer business report with invalid parameters
    system should return an error and not generate the export

Access export via API - successful scenario
    [Documentation]    Verify that the customer can access and download the export via the API once it is generated.
    [Tags]    req-GENAI-213    type-ok
    customer has requested a business report export
    export is generated
    customer should be able to access and download the export via the API

Access export via API with invalid credentials - unsuccessful scenario
    [Documentation]    Verify that the system denies access and returns an authentication error when invalid credentials are used.
    [Tags]    req-GENAI-213    type-nok
    customer has requested a business report export
    export is generated
    customer tries to access the export with invalid credentials
    system should deny access and return an authentication error

*** Keywords ***
I am a Bookbridge business owner
    New Browser    chromium
    New Page    ${BASE_URL}
    Login as Business Owner

Login as Business Owner
    # Add the steps to log in as a business owner
    # Example:
    # Input Text    username_field    business_owner
    # Input Text    password_field    password
    # Click Button    login_button

request to create an export for a customer business report
    Create Session    export_session    ${BASE_URL}
    POST    ${API_ENDPOINT}    {}

request to create an export for a customer business report with invalid parameters
    Create Session    export_session    ${BASE_URL}
    POST    ${API_ENDPOINT}    ${INVALID_PARAMS}

system should generate the export and make it available via the API
    ${response}=    Get Response    export_session
    Should Contain    ${response.content}    export_url

system should return an error and not generate the export
    ${response}=    Get Response    export_session
    Status Should Be    ${response}    400

customer has requested a business report export
    Request Export Generation

Request Export Generation
    # Add the steps to request export generation
    # Example:
    # Create Session    export_session    ${BASE_URL}
    # POST    ${API_ENDPOINT}    {}

export is generated
    Wait Until Export Is Ready

Wait Until Export Is Ready
    # Add the steps to wait until the export is ready
    # Example:
    # Sleep    10s

customer should be able to access and download the export via the API
    Create Session    export_session    ${BASE_URL}
    GET    ${API_ENDPOINT}/download
    ${response}=    Get Response    export_session
    Should Contain    ${response.content}    export_file

customer tries to access the export with invalid credentials
    Create Session    export_session    ${BASE_URL}
    GET    ${API_ENDPOINT}/download    headers=${INVALID_CREDENTIALS}

system should deny access and return an authentication error
    ${response}=    Get Response    export_session
    Status Should Be    ${response}    401
