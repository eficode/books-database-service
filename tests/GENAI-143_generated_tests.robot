*** Settings ***
Documentation    This test suite verifies the functionality of displaying, filtering, and exporting top-sold books data for the mining industry.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Display top-sold books - successful scenario
    [Documentation]    Verify that the top-sold books in the mining industry are displayed and sorted by sales volume.
    [Tags]    req-GENAI-141    type-ok
    I am a Sales Manager
    navigate to the top-sold books section for the mining industry
    should see a list of the top-sold books in the mining industry
    list should be sorted by sales volume

Display top-sold books - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when there is a network issue while loading top-sold books data.
    [Tags]    req-GENAI-141    type-nok
    I am a Sales Manager
    navigate to the top-sold books section for the mining industry
    there is a network issue
    should see an error message indicating that the data could not be loaded

Filter top-sold books by date range - successful scenario
    [Documentation]    Verify that the top-sold books in the mining industry are displayed within the selected date range.
    [Tags]    req-GENAI-141    type-ok
    I am a Sales Manager
    apply a date range filter
    should see the top-sold books in the mining industry within the selected date range

Filter top-sold books by date range - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when an invalid date range is selected.
    [Tags]    req-GENAI-141    type-nok
    I am a Sales Manager
    apply a date range filter
    selected date range is invalid
    should see an error message indicating that the date range is invalid

Export top-sold books data - successful scenario
    [Documentation]    Verify that the top-sold books data can be exported in CSV format.
    [Tags]    req-GENAI-141    type-ok
    I am a Sales Manager
    choose to export the top-sold books data
    should be able to download the data in CSV format

Export top-sold books data - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when there is a server error while exporting top-sold books data.
    [Tags]    req-GENAI-141    type-nok
    I am a Sales Manager
    choose to export the top-sold books data
    there is a server error
    should see an error message indicating that the export failed

*** Keywords ***
I am a Sales Manager
    New Browser    chromium
    New Page    ${URL}
    Login as Sales Manager

navigate to the top-sold books section for the mining industry
    Click    //a[@href='/top-sold-books/mining']

should see a list of the top-sold books in the mining industry
    Wait For Elements State    //div[@class='book-list']    visible

list should be sorted by sales volume
    ${books}    Get Texts    //div[@class='book-list']//div[@class='sales-volume']
    Should Be Sorted    ${books}

there is a network issue
    Simulate Network Issue

should see an error message indicating that the data could not be loaded
    Wait For Elements State    //div[@class='error-message']    visible
    Element Text Should Be    //div[@class='error-message']    Data could not be loaded

apply a date range filter
    Click    //input[@id='date-range']
    Input Text    //input[@id='start-date']    2022-01-01
    Input Text    //input[@id='end-date']    2022-12-31
    Click    //button[@id='apply-filter']

should see the top-sold books in the mining industry within the selected date range
    Wait For Elements State    //div[@class='book-list']    visible

selected date range is invalid
    Click    //input[@id='date-range']
    Input Text    //input[@id='start-date']    invalid-date
    Input Text    //input[@id='end-date']    invalid-date
    Click    //button[@id='apply-filter']

should see an error message indicating that the date range is invalid
    Wait For Elements State    //div[@class='error-message']    visible
    Element Text Should Be    //div[@class='error-message']    Invalid date range

choose to export the top-sold books data
    Click    //button[@id='export-data']

should be able to download the data in CSV format
    Wait For Download    timeout=30s
    File Should Exist    ${DOWNLOAD_DIR}/top-sold-books.csv

there is a server error
    Simulate Server Error

should see an error message indicating that the export failed
    Wait For Elements State    //div[@class='error-message']    visible
    Element Text Should Be    //div[@class='error-message']    Export failed
