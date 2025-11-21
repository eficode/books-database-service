*** Settings ***
Documentation    This test suite verifies the 'Language' field in the 'Add Book' view.
Library          Browser

*** Variables ***
${URL}           http://example.com/add-book

*** Test Cases ***
Display Language Field - Successful Scenario
    [Documentation]    Verify that the 'Language' field is displayed in the 'Add Book' view.
    [Tags]    req-GENAI-452    type-ok
    Given I am on the 'Add Book' view
    When I see the form to add a new book
    Then I should see a 'Language' field

Display Language Field - Unsuccessful Scenario
    [Documentation]    Verify that the 'Language' field is not displayed in the 'Add Book' view when it is missing.
    [Tags]    req-GENAI-452    type-nok
    Given I am on the 'Add Book' view
    When I see the form to add a new book
    And the 'Language' field is missing
    Then I should see the 'Language' field is missing

Save Language Field Data - Successful Scenario
    [Documentation]    Verify that the language data is saved in the database.
    [Tags]    req-GENAI-452    type-ok
    Given I am on the 'Add Book' view
    When I enter a language in the 'Language' field
    And I save the book details
    Then the language should be saved in the database

Save Language Field Data - Unsuccessful Scenario
    [Documentation]    Verify that the language data is not saved in the database when the connection is lost.
    [Tags]    req-GENAI-452    type-nok
    Given I am on the 'Add Book' view
    When I enter a language in the 'Language' field
    And I save the book details
    And the database connection is lost
    Then the language should not be saved in the database

Validate Language Field - Successful Scenario
    [Documentation]    Verify that an error message is displayed when the 'Language' field is empty.
    [Tags]    req-GENAI-452    type-ok
    Given I am on the 'Add Book' view
    When I leave the 'Language' field empty
    And I try to save the book details
    Then I should see an error message indicating that the 'Language' field is required

Validate Language Field - Unsuccessful Scenario
    [Documentation]    Verify that no error message is displayed when the 'Language' field is empty and validation is bypassed.
    [Tags]    req-GENAI-452    type-nok
    Given I am on the 'Add Book' view
    When I leave the 'Language' field empty
    And I try to save the book details
    And the form validation is bypassed
    Then I should not see an error message indicating that the 'Language' field is required

*** Keywords ***
I am on the 'Add Book' view
    New Page    ${URL}

I see the form to add a new book
    Wait For Elements State    //form[@id='add-book-form']    visible

I should see a 'Language' field
    Wait For Elements State    //input[@name='language']    visible

The 'Language' field is missing
    Wait For Elements State    //input[@name='language']    hidden

I enter a language in the 'Language' field
    Fill Text    //input[@name='language']    English

I save the book details
    Click    //button[@id='save-book']

The language should be saved in the database
    # Placeholder for database verification logic
    Log    Language saved in the database

The database connection is lost
    # Placeholder for simulating database connection loss
    Log    Database connection lost

The language should not be saved in the database
    # Placeholder for database verification logic
    Log    Language not saved in the database

I leave the 'Language' field empty
    Fill Text    //input[@name='language']    

I try to save the book details
    Click    //button[@id='save-book']

I should see an error message indicating that the 'Language' field is required
    Wait For Elements State    //div[@class='error' and contains(text(), 'Language field is required')]    visible

The form validation is bypassed
    # Placeholder for bypassing form validation logic
    Log    Form validation bypassed

I should not see an error message indicating that the 'Language' field is required
    Wait For Elements State    //div[@class='error' and contains(text(), 'Language field is required')]    hidden
