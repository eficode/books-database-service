*** Settings ***
Documentation    This test suite verifies the functionality of adding, viewing, and removing books from the favourites list.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      testuser
${PASSWORD}      testpassword

*** Test Cases ***
Add a book to favourites - successful scenario
    [Documentation]    Verify that a book can be successfully added to favourites.
    [Tags]    req-DEV-179    type-ok
    Given I am a logged-in user
    When I view a book's details
    And I click on the 'Add to Favourites' button
    Then the book should be added to my favourites list

Add a book to favourites - unsuccessful scenario
    [Documentation]    Verify that a book is not added to favourites when there is a system error.
    [Tags]    req-DEV-179    type-nok
    Given I am a logged-in user
    When I view a book's details
    And I click on the 'Add to Favourites' button
    And the system encounters an error
    Then the book should not be added to my favourites list

View favourites page - successful scenario
    [Documentation]    Verify that the favourites page displays all favourite books.
    [Tags]    req-DEV-179    type-ok
    Given I am a logged-in user
    When I navigate to the favourites page
    Then I should see a list of all my favourite books

View favourites page - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when there is a system error on the favourites page.
    [Tags]    req-DEV-179    type-nok
    Given I am a logged-in user
    When I navigate to the favourites page
    And the system encounters an error
    Then I should see an error message instead of my favourite books

Remove a book from favourites - successful scenario
    [Documentation]    Verify that a book can be successfully removed from favourites.
    [Tags]    req-DEV-179    type-ok
    Given I am a logged-in user
    And I have a book in my favourites list
    When I click on the 'Remove from Favourites' button
    Then the book should be removed from my favourites list

Remove a book from favourites - unsuccessful scenario
    [Documentation]    Verify that a book is not removed from favourites when there is a system error.
    [Tags]    req-DEV-179    type-nok
    Given I am a logged-in user
    And I have a book in my favourites list
    When I click on the 'Remove from Favourites' button
    And the system encounters an error
    Then the book should not be removed from my favourites list

*** Keywords ***
I am a logged-in user
    Browser.New Browser    chromium
    Browser.New Context
    Browser.New Page
    Browser.Go To    ${URL}
    Browser.Fill Text    username    ${USERNAME}
    Browser.Fill Text    password    ${PASSWORD}
    Browser.Click    login

I view a book's details
    Browser.Click    book-details

I click on the 'Add to Favourites' button
    Browser.Click    add-to-favourites

The book should be added to my favourites list
    Browser.Wait For Elements State    favourites-list    visible
    ${text}=    Browser.Get Text    favourites-list
    Should Be Equal    ${text}    book-title

The system encounters an error
    # Simulate Error keyword needs to be implemented or replaced with actual error simulation steps

The book should not be added to my favourites list
    Browser.Wait For Elements State    favourites-list    hidden
    ${text}=    Browser.Get Text    favourites-list
    Should Not Be Equal    ${text}    book-title

I navigate to the favourites page
    Browser.Click    favourites-page

I should see a list of all my favourite books
    Browser.Wait For Elements State    favourites-list    visible

I should see an error message instead of my favourite books
    Browser.Wait For Elements State    error-message    visible

I have a book in my favourites list
    # Add Book To Favourites keyword needs to be implemented or replaced with actual steps to add a book to favourites

I click on the 'Remove from Favourites' button
    Browser.Click    remove-from-favourites

The book should be removed from my favourites list
    Browser.Wait For Elements State    favourites-list    hidden
    ${text}=    Browser.Get Text    favourites-list
    Should Not Be Equal    ${text}    book-title

The book should not be removed from my favourites list
    Browser.Wait For Elements State    favourites-list    visible
    ${text}=    Browser.Get Text    favourites-list
    Should Be Equal    ${text}    book-title
