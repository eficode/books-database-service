*** Settings ***
Documentation    Test suite for verifying book shop homepage and book details page load times.
Library          Browser

*** Variables ***
${BOOK_SHOP_URL}    https://example.com
${BOOK_DETAILS_URL} https://example.com/book/1

*** Test Cases ***
Homepage Should Load Within 3 Seconds
    [Documentation]    Verify that the book shop homepage loads within 3 seconds.
    [Tags]    req-DEV-131    type-ok
    Given I am a book enthusiast
    When I navigate to the book shop homepage
    Then the homepage should load within 3 seconds

Homepage Should Not Load Within 3 Seconds
    [Documentation]    Verify that the book shop homepage does not load within 3 seconds.
    [Tags]    req-DEV-131    type-nok
    Given I am a book enthusiast
    When I navigate to the book shop homepage
    Then the homepage should not load within 3 seconds

Book Details Page Should Load Within 2 Seconds
    [Documentation]    Verify that the book details page loads within 2 seconds.
    [Tags]    req-DEV-131    type-ok
    Given I am a book enthusiast
    When I navigate to a book details page
    Then the book details page should load within 2 seconds

Book Details Page Should Not Load Within 2 Seconds
    [Documentation]    Verify that the book details page does not load within 2 seconds.
    [Tags]    req-DEV-131    type-nok
    Given I am a book enthusiast
    When I navigate to a book details page
    Then the book details page should not load within 2 seconds

*** Keywords ***
I am a book enthusiast
    Log    I am a book enthusiast

I navigate to the book shop homepage
    New Page    ${BOOK_SHOP_URL}

The homepage should load within 3 seconds
    Wait For Elements State    //body    visible    timeout=3s

The homepage should not load within 3 seconds
    Wait For Elements State    //body    visible    timeout=3s
    Should Be Equal As Numbers    ${elapsed_time}    3    msg=Homepage loaded within 3 seconds

I navigate to a book details page
    New Page    ${BOOK_DETAILS_URL}

The book details page should load within 2 seconds
    Wait For Elements State    //body    visible    timeout=2s

The book details page should not load within 2 seconds
    Wait For Elements State    //body    visible    timeout=2s
    Should Be Equal As Numbers    ${elapsed_time}    2    msg=Book details page loaded within 2 seconds
