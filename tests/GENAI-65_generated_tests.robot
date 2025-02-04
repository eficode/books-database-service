*** Settings ***
Documentation    This test suite verifies the functionality of searching, removing, and preventing future orders of books with black covers.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search for books with black covers - successful scenario
    [Documentation]    Verify that searching for books with black covers returns a list of such books.
    [Tags]    req-GENAI-63    type-ok
    Given I am a book seller
    When I search for books with black covers
    Then I should see a list of all books with black covers in the store

Search for books with black covers - unsuccessful scenario
    [Documentation]    Verify that searching for books with black covers returns no books when there are none.
    [Tags]    req-GENAI-63    type-nok
    Given I am a book seller
    When I search for books with black covers
    Then I should not see any books with black covers in the store

Remove books with black covers - successful scenario
    [Documentation]    Verify that selected books with black covers are removed from the store inventory.
    [Tags]    req-GENAI-63    type-ok
    Given I have a list of books with black covers
    When I select books to remove
    Then the selected books should be removed from the store inventory

Remove books with black covers - unsuccessful scenario
    [Documentation]    Verify that selected books with black covers are not removed from the store inventory when removal fails.
    [Tags]    req-GENAI-63    type-nok
    Given I have a list of books with black covers
    When I select books to remove
    Then the selected books should not be removed from the store inventory

Prevent future orders of books with black covers - successful scenario
    [Documentation]    Verify that future orders of books with black covers are prevented after updating order settings.
    [Tags]    req-GENAI-63    type-ok
    Given I have removed books with black covers
    When I update the order settings
    Then future orders of books with black covers should be prevented

Prevent future orders of books with black covers - unsuccessful scenario
    [Documentation]    Verify that future orders of books with black covers are not prevented after updating order settings fails.
    [Tags]    req-GENAI-63    type-nok
    Given I have removed books with black covers
    When I update the order settings
    Then future orders of books with black covers should not be prevented

*** Keywords ***
I am a book seller
    New Browser    headless=False
    New Page    ${URL}
    Wait For Elements State    //input[@name="search"]    visible

I search for books with black covers
    Click    //input[@name="search"]
    Type Text    //input[@name="search"]    black covers
    Click    //button[@name="searchButton"]
    Wait For Elements State    //div[@class="book-list"]    visible

I should see a list of all books with black covers in the store
    ${books}=    Get Elements    //div[@class="book-list"]//div[@class="book"]
    Should Be True    ${books} != []

I should not see any books with black covers in the store
    ${books}=    Get Elements    //div[@class="book-list"]//div[@class="book"]
    Should Be True    ${books} == []

I have a list of books with black covers
    ${books}=    Get Elements    //div[@class="book-list"]//div[@class="book"]
    Should Be True    ${books} != []

I select books to remove
    FOR    ${book}    IN    @{books}
        Click    ${book}//button[@name="remove"]
    END
    Wait For Elements State    //div[@class="notification"]    visible

The selected books should be removed from the store inventory
    ${books}=    Get Elements    //div[@class="book-list"]//div[@class="book"]
    Should Be True    ${books} == []

The selected books should not be removed from the store inventory
    ${books}=    Get Elements    //div[@class="book-list"]//div[@class="book"]
    Should Be True    ${books} != []

I have removed books with black covers
    ${books}=    Get Elements    //div[@class="book-list"]//div[@class="book"]
    FOR    ${book}    IN    @{books}
        Click    ${book}//button[@name="remove"]
    END
    Wait For Elements State    //div[@class="notification"]    visible
    ${books}=    Get Elements    //div[@class="book-list"]//div[@class="book"]
    Should Be True    ${books} == []

I update the order settings
    Click    //button[@name="settings"]
    Click    //input[@name="preventBlackCovers"]
    Click    //button[@name="saveSettings"]
    Wait For Elements State    //div[@class="notification"]    visible

Future orders of books with black covers should be prevented
    ${setting}=    Get Element    //input[@name="preventBlackCovers"]
    ${checked}=    Get Property    ${setting}    checked
    Should Be True    ${checked} == True

Future orders of books with black covers should not be prevented
    ${setting}=    Get Element    //input[@name="preventBlackCovers"]
    ${checked}=    Get Property    ${setting}    checked
    Should Be True    ${checked} == False
