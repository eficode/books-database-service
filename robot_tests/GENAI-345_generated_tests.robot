*** Settings ***
Documentation    This test suite verifies the functionality of viewing and ranking authors in a book enthusiast application.
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
View authors in alphabetical order
    [Documentation]    Verify that authors are listed in alphabetical order.
    [Tags]    req-GENAI-343    type-ok
    Given I am a book enthusiast
    When I view the list of authors
    Then the authors should be listed in alphabetical order

View authors in non-alphabetical order
    [Documentation]    Verify that authors are not listed in alphabetical order.
    [Tags]    req-GENAI-343    type-nok
    Given I am a book enthusiast
    When I view the list of authors
    Then the authors should not be listed in alphabetical order

Rank authors by stars
    [Documentation]    Verify that ranking authors by stars is saved and displayed correctly.
    [Tags]    req-GENAI-343    type-ok
    Given I am viewing the list of authors
    When I rank authors by stars
    Then the ranking should be saved and displayed correctly

Fail to rank authors by stars
    [Documentation]    Verify that ranking authors by stars is not saved and displayed correctly.
    [Tags]    req-GENAI-343    type-nok
    Given I am viewing the list of authors
    When I rank authors by stars
    Then the ranking should not be saved and displayed correctly

*** Keywords ***
I am a book enthusiast
    New Browser    headless=False
    New Page    ${URL}
    Wait For Elements State    //div[@id='authors']    visible

I view the list of authors
    Click    //button[@id='view-authors']
    Wait For Elements State    //div[@id='author-list']    visible

The authors should be listed in alphabetical order
    ${authors}=    Get Text    //div[@id='author-list']//li
    ${sorted_authors}=    Evaluate    sorted(${authors})
    Should Be Equal As Strings    ${authors}    ${sorted_authors}

The authors should not be listed in alphabetical order
    ${authors}=    Get Text    //div[@id='author-list']//li
    ${sorted_authors}=    Evaluate    sorted(${authors})
    Should Not Be Equal As Strings    ${authors}    ${sorted_authors}

I am viewing the list of authors
    New Browser    headless=False
    New Page    ${URL}
    Click    //button[@id='view-authors']
    Wait For Elements State    //div[@id='author-list']    visible

I rank authors by stars
    Click    //button[@id='rank-authors']
    Wait For Elements State    //div[@id='ranking']    visible

The ranking should be saved and displayed correctly
    ${ranking}=    Get Text    //div[@id='ranking']//li
    Should Not Be Empty    ${ranking}

The ranking should not be saved and displayed correctly
    ${ranking}=    Get Text    //div[@id='ranking']//li
    Should Be Empty    ${ranking}
