*** Settings ***
Library    Browser
Documentation    This test suite verifies the functionality of the favorite books feature in the application.

*** Variables ***
${URL}    http://example.com
${USERNAME}    user
${PASSWORD}    pass

*** Test Cases ***
I should see a list of all my favorite books
    [Documentation]    Verify that a logged-in user can see a list of all their favorite books.
    [Tags]    req-GENAI-435    type-ok
    Given I am a logged-in user
    When I navigate to the favorite books page
    Then I should see a list of all my favorite books

I should see a message indicating that there are no favorite books
    [Documentation]    Verify that a logged-in user sees a message when there are no favorite books.
    [Tags]    req-GENAI-435    type-nok
    Given I am a logged-in user
    When I navigate to the favorite books page
    And there are no favorite books in my list
    Then I should see a message indicating that there are no favorite books

The book should be added to my favorite books list
    [Documentation]    Verify that a book can be added to the favorite books list.
    [Tags]    req-GENAI-435    type-ok
    Given I am viewing a book's details
    When I click on 'Add to Favorites'
    Then the book should be added to my favorite books list

I should see a message indicating that the book is already in my favorites
    [Documentation]    Verify that a message is shown when trying to add a book already in favorites.
    [Tags]    req-GENAI-435    type-nok
    Given I am viewing a book's details
    When I click on 'Add to Favorites'
    And the book is already in my favorite books list
    Then I should see a message indicating that the book is already in my favorites

The book should be removed from my favorite books list
    [Documentation]    Verify that a book can be removed from the favorite books list.
    [Tags]    req-GENAI-435    type-ok
    Given I am viewing my favorite books page
    When I click on 'Remove from Favorites' for a book
    Then the book should be removed from my favorite books list

I should see a message indicating that the book is not in my favorites
    [Documentation]    Verify that a message is shown when trying to remove a book not in favorites.
    [Tags]    req-GENAI-435    type-nok
    Given I am viewing my favorite books page
    When I click on 'Remove from Favorites' for a book
    And the book is not in my favorite books list
    Then I should see a message indicating that the book is not in my favorites

*** Keywords ***
I am a logged-in user
    New Browser    headless=False
    Go To    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit

I navigate to the favorite books page
    Click    text=Favorite Books

I should see a list of all my favorite books
    Wait For Elements State    css=.favorite-book    visible

There are no favorite books in my list
    Evaluate    [el.remove() for el in document.querySelectorAll('.favorite-book')]

I should see a message indicating that there are no favorite books
    Wait For Elements State    text=No favorite books found    visible

I am viewing a book's details
    Go To    ${URL}/book/1

I click on 'Add to Favorites'
    Click    text=Add to Favorites

The book should be added to my favorite books list
    Wait For Elements State    text=Added to Favorites    visible

The book is already in my favorite books list
    Evaluate    document.body.insertAdjacentHTML('beforeend', '<div class="favorite-book"></div>')

I should see a message indicating that the book is already in my favorites
    Wait For Elements State    text=Book is already in your favorites    visible

I am viewing my favorite books page
    Go To    ${URL}/favorites

I click on 'Remove from Favorites' for a book
    Click    text=Remove from Favorites

The book should be removed from my favorite books list
    Wait For Elements State    text=Removed from Favorites    visible

The book is not in my favorite books list
    Evaluate    [el.remove() for el in document.querySelectorAll('.favorite-book')]

I should see a message indicating that the book is not in my favorites
    Wait For Elements State    text=Book is not in your favorites    visible
