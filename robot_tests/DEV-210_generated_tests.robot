*** Settings ***
Documentation    This test suite verifies the functionality of viewing, adding, and removing favorite books.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      testuser
${PASSWORD}      password

*** Test Cases ***
View favorite books page - successful scenario
    [Documentation]    Verify that a logged-in user can view their favorite books.
    [Tags]    req-DEV-208    type-ok
    Given I am a logged-in user
    When I navigate to the favorite books page
    Then I should see a list of my favorite books

View favorite books page - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees a message when they have no favorite books.
    [Tags]    req-DEV-208    type-nok
    Given I am a logged-in user
    And I have no favorite books
    When I navigate to the favorite books page
    Then I should see a message indicating that I have no favorite books

Add a book to favorites - successful scenario
    [Documentation]    Verify that a user can add a book to their favorite books list.
    [Tags]    req-DEV-208    type-ok
    Given I am viewing a book in the repository
    When I click on the 'Add to Favorites' button
    Then the book should be added to my favorite books list

Add a book to favorites - unsuccessful scenario
    [Documentation]    Verify that a user sees a message when trying to add a book already in their favorites.
    [Tags]    req-DEV-208    type-nok
    Given I am viewing a book in the repository
    And the book is already in my favorite books list
    When I click on the 'Add to Favorites' button
    Then I should see a message indicating that the book is already in my favorites

Remove a book from favorites - successful scenario
    [Documentation]    Verify that a user can remove a book from their favorite books list.
    [Tags]    req-DEV-208    type-ok
    Given I am viewing a book in my favorite books list
    When I click on the 'Remove from Favorites' button
    Then the book should be removed from my favorite books list

Remove a book from favorites - unsuccessful scenario
    [Documentation]    Verify that a user sees a message when trying to remove a book not in their favorites.
    [Tags]    req-DEV-208    type-nok
    Given I am viewing a book in my favorite books list
    And the book is not in my favorite books list
    When I click on the 'Remove from Favorites' button
    Then I should see a message indicating that the book is not in my favorites

*** Keywords ***
I am a logged-in user
    New Browser    headless=False
    New Context
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit

I navigate to the favorite books page
    Click    text=Favorite Books

I should see a list of my favorite books
    Wait For Elements State    css=.favorite-book    visible

I have no favorite books
    # Assuming there's a way to clear favorite books for the user
    Clear All Favorites

Clear All Favorites
    # Implementation to clear all favorite books
    # This is a placeholder for the actual implementation
    Log    Clearing all favorite books

I should see a message indicating that I have no favorite books
    Wait For Elements State    text=You have no favorite books    visible

I am viewing a book in the repository
    Click    text=Books
    Click    text=Some Book Title

I click on the 'Add to Favorites' button
    Click    text=Add to Favorites

The book should be added to my favorite books list
    Wait For Elements State    text=Book added to favorites    visible

The book is already in my favorite books list
    # Assuming there's a way to ensure the book is already in favorites
    Ensure Book Is In Favorites    Some Book Title

Ensure Book Is In Favorites
    [Arguments]    ${book_title}
    # Implementation to ensure the book is in favorites
    # This is a placeholder for the actual implementation
    Log    Ensuring book ${book_title} is in favorites

I should see a message indicating that the book is already in my favorites
    Wait For Elements State    text=Book is already in your favorites    visible

I am viewing a book in my favorite books list
    Click    text=Favorite Books
    Click    text=Some Book Title

I click on the 'Remove from Favorites' button
    Click    text=Remove from Favorites

The book should be removed from my favorite books list
    Wait For Elements State    text=Book removed from favorites    visible

The book is not in my favorite books list
    # Assuming there's a way to ensure the book is not in favorites
    Ensure Book Is Not In Favorites    Some Book Title

Ensure Book Is Not In Favorites
    [Arguments]    ${book_title}
    # Implementation to ensure the book is not in favorites
    # This is a placeholder for the actual implementation
    Log    Ensuring book ${book_title} is not in favorites

I should see a message indicating that the book is not in my favorites
    Wait For Elements State    text=Book is not in your favorites    visible
