*** Settings ***
Documentation    This test suite verifies the functionality of searching for books by cover color.
Library          Browser

*** Variables ***
${URL}           http://example.com
${SEARCH_INPUT}  //input[@id='search']
${SEARCH_BUTTON} //button[@id='search-button']
${RESULT_LIST}   //div[@id='results']
${ERROR_MESSAGE} //div[@id='error']

*** Test Cases ***
Search for books with a specific cover color - successful scenario
    [Documentation]    Verify that a list of books with the specified cover color is displayed.
    [Tags]    req-DEV-88    type-ok
    Given I am a book seller
    When I search for books by cover color
    Then I should see a list of books with the specified cover color

Search for books with a specific cover color - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when the system encounters an error.
    [Tags]    req-DEV-88    type-nok
    Given I am a book seller
    When I search for books by cover color
    And the system encounters an error
    Then I should see an error message indicating the search could not be completed

No books found with the specified cover color - successful scenario
    [Documentation]    Verify that a message indicating no books were found is displayed.
    [Tags]    req-DEV-88    type-ok
    Given I am a book seller
    When I search for books by a cover color that does not exist in the inventory
    Then I should see a message indicating no books were found

No books found with the specified cover color - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when the system encounters an error.
    [Tags]    req-DEV-88    type-nok
    Given I am a book seller
    When I search for books by a cover color that does not exist in the inventory
    And the system encounters an error
    Then I should see an error message indicating the search could not be completed

*** Keywords ***
I am a book seller
    New Browser    headless=False
    New Context
    New Page    ${URL}

I search for books by cover color
    Fill Text    ${SEARCH_INPUT}    red
    Click    ${SEARCH_BUTTON}
    Wait For Elements State    ${RESULT_LIST}    visible

I should see a list of books with the specified cover color
    ${result_text}=    Get Text    ${RESULT_LIST}
    Should Not Be Empty    ${result_text}

The system encounters an error
    # Simulate an error condition
    Evaluate    window.simulateError()    window
    Wait For Elements State    ${ERROR_MESSAGE}    visible

I should see an error message indicating the search could not be completed
    ${error_text}=    Get Text    ${ERROR_MESSAGE}
    Should Be Equal As Strings    ${error_text}    Search could not be completed

I search for books by a cover color that does not exist in the inventory
    Fill Text    ${SEARCH_INPUT}    nonexistentcolor
    Click    ${SEARCH_BUTTON}
    Wait For Elements State    ${RESULT_LIST}    visible

I should see a message indicating no books were found
    ${result_text}=    Get Text    ${RESULT_LIST}
    Should Be Equal As Strings    ${result_text}    No books found
