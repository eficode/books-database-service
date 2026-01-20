*** Settings ***
Documentation    This test suite verifies the functionality of the favourites feature in the application.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
View Favourites Page - Successful Scenario
    [Documentation]    Verify that a logged-in user can view the favourites page with a list of favourite books.
    [Tags]    req-DEV-199    type-ok
    Given I am a logged-in user
    When I navigate to the favourites page
    Then I should see a list of my favourite books

View Favourites Page - Unsuccessful Scenario
    [Documentation]    Verify that a logged-in user sees a message indicating no favourite books when there are none.
    [Tags]    req-DEV-199    type-nok
    Given I am a logged-in user
    When I navigate to the favourites page
    And there are no favourite books
    Then I should see a message indicating no favourite books

Add a Book to Favourites - Successful Scenario
    [Documentation]    Verify that a user can add a book to their favourites list.
    [Tags]    req-DEV-199    type-ok
    Given I am viewing a book
    When I click on 'Add to Favourites'
    Then the book should be added to my favourites list

Add a Book to Favourites - Unsuccessful Scenario
    [Documentation]    Verify that a user sees a message indicating the book is already in their favourites list when trying to add it again.
    [Tags]    req-DEV-199    type-nok
    Given I am viewing a book
    When I click on 'Add to Favourites'
    And the book is already in my favourites list
    Then I should see a message indicating the book is already in my favourites list

Remove a Book from Favourites - Successful Scenario
    [Documentation]    Verify that a user can remove a book from their favourites list.
    [Tags]    req-DEV-199    type-ok
    Given I am viewing my favourites page
    When I click on 'Remove from Favourites' for a book
    Then the book should be removed from my favourites list

Remove a Book from Favourites - Unsuccessful Scenario
    [Documentation]    Verify that a user sees a message indicating the book is not in their favourites list when trying to remove it.
    [Tags]    req-DEV-199    type-nok
    Given I am viewing my favourites page
    When I click on 'Remove from Favourites' for a book
    And the book is not in my favourites list
    Then I should see a message indicating the book is not in my favourites list

*** Keywords ***
I am a logged-in user
    New Browser    headless=False
    Go To    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit

I navigate to the favourites page
    Click    text=Favourites

I should see a list of my favourite books
    Wait For Elements State    css=.favourite-book    visible

There are no favourite books
    Evaluate    [e.remove() for e in document.querySelectorAll('.favourite-book')]    window.document

I should see a message indicating no favourite books
    Wait For Elements State    text=No favourite books found    visible

I am viewing a book
    Go To    ${URL}/book/1

I click on 'Add to Favourites'
    Click    text=Add to Favourites

The book should be added to my favourites list
    Wait For Elements State    text=Book added to favourites    visible

The book is already in my favourites list
    Evaluate    document.body.insertAdjacentHTML('beforeend', '<div class="favourite-book"></div>')    window.document

I should see a message indicating the book is already in my favourites list
    Wait For Elements State    text=Book is already in your favourites list    visible

I am viewing my favourites page
    Go To    ${URL}/favourites

I click on 'Remove from Favourites' for a book
    Click    text=Remove from Favourites

The book should be removed from my favourites list
    Wait For Elements State    text=Book removed from favourites    visible

The book is not in my favourites list
    Evaluate    [e.remove() for e in document.querySelectorAll('.favourite-book')]    window.document

I should see a message indicating the book is not in my favourites list
    Wait For Elements State    text=Book is not in your favourites list    visible
