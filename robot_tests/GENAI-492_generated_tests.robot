*** Settings ***
Library    Browser

Documentation    This test suite verifies the functionality of the Favorites Page, including viewing, adding, and removing favorite books.

*** Variables ***
${URL}    http://example.com
${USERNAME}    user
${PASSWORD}    pass

*** Test Cases ***
View favorites page - successful scenario
    [Documentation]    Verify that a logged-in user can view the favorites page and see a list of favorite books.
    [Tags]    req-GENAI-491    type-ok
    I am a logged-in user
    I navigate to the favorites page
    I should see a list of books I have tagged as favorites

View favorites page - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees a message indicating no favorites are available when no books are tagged as favorites.
    [Tags]    req-GENAI-491    type-nok
    I am a logged-in user
    I have no books tagged as favorites
    I navigate to the favorites page
    I should see a message indicating no favorites are available

Add book to favorites - successful scenario
    [Documentation]    Verify that a user can tag a book as a favorite and see it on the favorites page.
    [Tags]    req-GENAI-491    type-ok
    I am viewing a book's details
    I tag the book as a favorite
    The book should appear on my favorites page

Add book to favorites - unsuccessful scenario
    [Documentation]    Verify that a user sees a message indicating the book is already in favorites when trying to tag it again.
    [Tags]    req-GENAI-491    type-nok
    I am viewing a book's details
    I have already tagged the book as a favorite
    I tag the book as a favorite
    I should see a message indicating the book is already in my favorites

Remove book from favorites - successful scenario
    [Documentation]    Verify that a user can untag a book as a favorite and see it removed from the favorites page.
    [Tags]    req-GENAI-491    type-ok
    I am on the favorites page
    I untag a book as a favorite
    The book should be removed from my favorites page

Remove book from favorites - unsuccessful scenario
    [Documentation]    Verify that a user sees a message indicating the book is not in favorites when trying to untag it.
    [Tags]    req-GENAI-491    type-nok
    I am on the favorites page
    The book is not tagged as a favorite
    I untag a book as a favorite
    I should see a message indicating the book is not in my favorites

*** Keywords ***
I am a logged-in user
    New Browser    headless=False
    Go To    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit

I navigate to the favorites page
    Click    text=Favorites

I should see a list of books I have tagged as favorites
    Wait For Elements State    css=.favorite-book    visible

I have no books tagged as favorites
    # Assuming there's a way to clear all favorites for the user
    Clear All Favorites For User

I should see a message indicating no favorites are available
    Wait For Elements State    text=No favorites available    visible

I am viewing a book's details
    Go To    ${URL}/book/1

I tag the book as a favorite
    Click    text=Add to Favorites

The book should appear on my favorites page
    I navigate to the favorites page
    Wait For Elements State    css=.favorite-book    visible

I have already tagged the book as a favorite
    I tag the book as a favorite

I should see a message indicating the book is already in my favorites
    Wait For Elements State    text=Book is already in your favorites    visible

I am on the favorites page
    I navigate to the favorites page

I untag a book as a favorite
    Click    text=Remove from Favorites

The book should be removed from my favorites page
    Wait For Elements State    css=.favorite-book    hidden

The book is not tagged as a favorite
    # Assuming there's a way to ensure the book is not in favorites
    Ensure Book Not In Favorites    ${USERNAME}    1

I should see a message indicating the book is not in my favorites
    Wait For Elements State    text=Book is not in your favorites    visible

Clear All Favorites For User
    # Implement the logic to clear all favorites for a user
    Log    Clearing all favorites for user ${USERNAME}

Ensure Book Not In Favorites
    [Arguments]    ${username}    ${book_id}
    # Implement the logic to ensure the book is not in favorites
    Log    Ensuring book with ID ${book_id} is not in favorites for user ${username}
