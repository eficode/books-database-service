*** Settings ***
Documentation    This test suite verifies the identification and removal of test books from the database.
Library          Browser

*** Variables ***
${DATABASE_URL}    http://example.com/database

*** Test Cases ***
Identify and remove test books - successful scenario
    [Documentation]    Verify that test books are successfully identified and removed from the database.
    [Tags]    req-DEV-134    type-ok
    there are test books in the database
    system identifies books marked as test data
    those books should be removed from the database

Identify and remove test books - unsuccessful scenario
    [Documentation]    Verify that test books are not removed if the system fails to identify them.
    [Tags]    req-DEV-134    type-nok
    there are test books in the database
    system fails to identify books marked as test data
    those books should not be removed from the database

Confirm removal of test books - successful scenario
    [Documentation]    Verify that no test books are found after successful removal.
    [Tags]    req-DEV-134    type-ok
    test books have been removed
    I query the database for test books
    no test books should be found

Confirm removal of test books - unsuccessful scenario
    [Documentation]    Verify that test books might still be found if the query is incorrect.
    [Tags]    req-DEV-134    type-nok
    test books have been removed
    I query the database incorrectly for test books
    test books might still be found

*** Keywords ***
there are test books in the database
    Browser.New Context
    Browser.New Page    ${DATABASE_URL}
    Browser.Wait For Elements State    text="Test Books"    state=visible

system identifies books marked as test data
    Browser.Click    //button[@id='identify-test-books']
    Browser.Wait For Elements State    text="Books Identified"    state=visible

system fails to identify books marked as test data
    Browser.Click    //button[@id='identify-test-books']
    Browser.Wait For Elements State    text="Identification Failed"    state=visible

those books should be removed from the database
    Browser.Click    //button[@id='remove-test-books']
    Browser.Wait For Elements State    text="Test Books"    state=hidden

those books should not be removed from the database
    Browser.Get Text    text="Test Books"

test books have been removed
    Browser.Click    //button[@id='remove-test-books']
    Browser.Wait For Elements State    text="Test Books"    state=hidden

I query the database for test books
    Browser.Fill Text    //input[@id='query']    test books
    Browser.Click    //button[@id='search']

no test books should be found
    Browser.Wait For Elements State    text="Test Books"    state=hidden

I query the database incorrectly for test books
    Browser.Fill Text    //input[@id='query']    incorrect query
    Browser.Click    //button[@id='search']

test books might still be found
    Browser.Get Text    text="Test Books"
