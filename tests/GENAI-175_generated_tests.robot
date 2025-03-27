*** Settings ***
Documentation    This test suite verifies the functionality of viewing and exporting the top 3 most sold books in a specific language.
Library          Browser
Library          OperatingSystem
Library          Collections

*** Variables ***
${BOOKBRIDGE_URL}    https://bookbridge.example.com

*** Test Cases ***
View Top 3 Most Sold Books In A Specific Language - Successful Scenario
    [Documentation]    Verify that the top 3 most sold books in a specific language are displayed.
    [Tags]    req-GENAI-173    type-ok
    Given I am a Bookbridge business owner
    When I select a specific language
    Then I should see the top 3 most sold books written in that language

View Top 3 Most Sold Books In A Specific Language With No Books Available - Unsuccessful Scenario
    [Documentation]    Verify that a message is displayed when no books are available in the selected language.
    [Tags]    req-GENAI-173    type-nok
    Given I am a Bookbridge business owner
    When I select a specific language
    And there are no books available in that language
    Then I should see a message indicating that no books are available

Export Top 3 Most Sold Books Data - Successful Scenario
    [Documentation]    Verify that the data of the top 3 most sold books can be exported.
    [Tags]    req-GENAI-173    type-ok
    Given I have viewed the top 3 most sold books in a specific language
    When I choose to export the data
    Then the data should be exported in a format suitable for the marketing team

*** Keywords ***
I am a Bookbridge business owner
    New Page    ${BOOKBRIDGE_URL}
    Wait For Elements State    //input[@id='language-selector']    visible==True

I select a specific language
    Click    //input[@id='language-selector']
    Click    //option[@value='English']
    Wait For Elements State    //div[@class='top-books']    visible==True

I should see the top 3 most sold books written in that language
    Get Element States    //div[@class='top-books']    visible==True
    ${book1}=    Get Text    //div[@class='top-books']/div[1]
    Should Be Equal    ${book1}    1. Book Title 1
    ${book2}=    Get Text    //div[@class='top-books']/div[2]
    Should Be Equal    ${book2}    2. Book Title 2
    ${book3}=    Get Text    //div[@class='top-books']/div[3]
    Should Be Equal    ${book3}    3. Book Title 3

There are no books available in that language
    Click    //input[@id='language-selector']
    Click    //option[@value='Esperanto']
    Wait For Elements State    //div[@class='no-books-message']    visible==True

I should see a message indicating that no books are available
    Get Element States    //div[@class='no-books-message']    visible==True
    ${message}=    Get Text    //div[@class='no-books-message']
    Should Be Equal    ${message}    No books are available in this language.

I have viewed the top 3 most sold books in a specific language
    I am a Bookbridge business owner
    I select a specific language
    I should see the top 3 most sold books written in that language

I choose to export the data
    Click    //button[@id='export-data']
    Wait For    download

The data should be exported in a format suitable for the marketing team
    File Should Exist    export.csv
    ${content}=    Get File    export.csv
    Should Contain    ${content}    Book Title 1
    Should Contain    ${content}    Book Title 2
    Should Contain    ${content}    Book Title 3
