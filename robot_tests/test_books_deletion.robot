*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library           Collections

*** Variables ***
${URL}            http://localhost:8000
${BROWSER}        Chrome

*** Test Cases ***
Validate Single Book Deletion
    [Documentation]    Validate the deletion of a single book from the UI to the database.
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Click Element    xpath=//button[@id='delete-book-1']
    Alert Should Be Present
    Confirm Action
    Wait Until Page Contains    Book deleted
    Close Browser

Validate Bulk Book Deletion
    [Documentation]    Validate the bulk deletion of books from the UI to the database.
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Click Element    xpath=//button[@id='bulk-delete']
    Alert Should Be Present
    Confirm Action
    Wait Until Page Contains    Books deleted
    Close Browser
