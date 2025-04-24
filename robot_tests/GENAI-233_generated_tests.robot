*** Settings ***
Documentation    This test suite verifies the functionality of adding, viewing, and removing books from the favorites page under various conditions.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
Add a book to favorites - successful scenario
    [Documentation]    Verify that a book can be successfully added to favorites.
    [Tags]    req-GENAI-231    type-ok
    Given I am a logged-in user
    When I view a book's details
    And I click on 'Add to Favorites'
    Then the book should be added to my favorites page

Add a book to favorites - unsuccessful scenario
    [Documentation]    Verify that a book is not added to favorites when there is a network issue.
    [Tags]    req-GENAI-231    type-nok
    Given I am a logged-in user
    When I view a book's details
    And I click on 'Add to Favorites'
    And there is a network issue
    Then the book should not be added to my favorites page

View favorites page - successful scenario
    [Documentation]    Verify that the favorites page displays all books added to favorites.
    [Tags]    req-GENAI-231    type-ok
    Given I am a logged-in user
    When I navigate to my favorites page
    Then I should see a list of all books I have added to favorites

View favorites page - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when there is a server error on the favorites page.
    [Tags]    req-GENAI-231    type-nok
    Given I am a logged-in user
    When I navigate to my favorites page
    And there is a server error
    Then I should see an error message and no list of books

Remove a book from favorites - successful scenario
    [Documentation]    Verify that a book can be successfully removed from favorites.
    [Tags]    req-GENAI-231    type-ok
    Given I am a logged-in user
    And I have books in my favorites page
    When I click on 'Remove from Favorites' for a book
    Then the book should be removed from my favorites page

Remove a book from favorites - unsuccessful scenario
    [Documentation]    Verify that a book is not removed from favorites when there is a network issue.
    [Tags]    req-GENAI-231    type-nok
    Given I am a logged-in user
    And I have books in my favorites page
    When I click on 'Remove from Favorites' for a book
    And there is a network issue
    Then the book should not be removed from my favorites page

*** Keywords ***
I am a logged-in user
    New Browser    chromium
    New Page    ${URL}
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    id=loginButton
    Wait For Elements State    id=logoutButton    visible

I view a book's details
    Click    id=bookDetails
    Wait For Elements State    id=addToFavoritesButton    visible

I click on 'Add to Favorites'
    Click    id=addToFavoritesButton
    Wait For Elements State    id=favoritesConfirmation    visible

The book should be added to my favorites page
    Click    id=favoritesPage
    Wait For Elements State    xpath=//div[@class='book' and text()='Book Title']    visible

There is a network issue
    # Simulate network issue
    Evaluate    window.navigator.onLine = false

The book should not be added to my favorites page
    Click    id=favoritesPage
    Wait For Elements State    xpath=//div[@class='book' and text()='Book Title']    hidden

I navigate to my favorites page
    Click    id=favoritesPage
    Wait For Elements State    id=favoritesList    visible

I should see a list of all books I have added to favorites
    Wait For Elements State    id=favoritesList    visible

There is a server error
    # Simulate server error
    Evaluate    window.serverError = true

I should see an error message and no list of books
    Wait For Elements State    id=errorMessage    visible
    Wait For Elements State    id=favoritesList    hidden

I have books in my favorites page
    # Ensure there are books in favorites
    Click    id=favoritesPage
    Wait For Elements State    xpath=//div[@class='book']    visible

I click on 'Remove from Favorites' for a book
    Click    xpath=//div[@class='book']//button[text()='Remove from Favorites']
    Wait For Elements State    xpath=//div[@class='book' and text()='Book Title']    hidden

The book should be removed from my favorites page
    Wait For Elements State    xpath=//div[@class='book' and text()='Book Title']    hidden

The book should not be removed from my favorites page
    Wait For Elements State    xpath=//div[@class='book' and text()='Book Title']    visible
