*** Settings ***
Documentation    This test suite verifies the functionality of arranging books in ascending and descending order, including scenarios with empty lists.
Library          Browser

*** Variables ***
${URL}           http://example.com/books

*** Test Cases ***
Arrange Books In Ascending Order
    [Documentation]    Verify that books are arranged in ascending alphabetical order.
    [Tags]    req-GENAI-466    type-ok
    Given I have a list of books
    When I choose to arrange the list alphabetically
    Then the list should be displayed in ascending alphabetical order by book title

Arrange Books In Ascending Order With An Empty List
    [Documentation]    Verify that an empty list remains empty when arranged alphabetically.
    [Tags]    req-GENAI-466    type-nok
    Given I have a list of books
    And the list is empty
    When I choose to arrange the list alphabetically
    Then the list should remain empty

Arrange Books In Descending Order
    [Documentation]    Verify that books are arranged in descending alphabetical order.
    [Tags]    req-GENAI-466    type-ok
    Given I have a list of books
    When I choose to arrange the list in reverse alphabetical order
    Then the list should be displayed in descending alphabetical order by book title

Arrange Books In Descending Order With An Empty List
    [Documentation]    Verify that an empty list remains empty when arranged in reverse alphabetical order.
    [Tags]    req-GENAI-466    type-nok
    Given I have a list of books
    And the list is empty
    When I choose to arrange the list in reverse alphabetical order
    Then the list should remain empty

*** Keywords ***
I have a list of books
    New Page    ${URL}
    Wait For Elements State    //div[@class='book-list']    visible

The list is empty
    Fill Text    //div[@class='book-list']    

I choose to arrange the list alphabetically
    Click    //button[@id='sort-asc']

I choose to arrange the list in reverse alphabetical order
    Click    //button[@id='sort-desc']

The list should be displayed in ascending alphabetical order by book title
    ${books}=    Get Text    //div[@class='book-title']
    Should Be Equal As Strings    ${books}    ${books.sort()}

The list should remain empty
    ${books}=    Get Text    //div[@class='book-title']
    Length Should Be    ${books}    0

The list should be displayed in descending alphabetical order by book title
    ${books}=    Get Text    //div[@class='book-title']
    Should Be Equal As Strings    ${books}    ${books.sort(reverse=True)}
