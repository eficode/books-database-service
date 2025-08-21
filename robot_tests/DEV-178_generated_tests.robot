*** Settings ***
Documentation    This test suite verifies the functionality of tagging books as favorites, viewing favorite books, and removing books from favorites.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      testuser
${PASSWORD}      testpass

*** Test Cases ***
Tag a book as favorite - successful scenario
    [Documentation]    Verify that a book can be successfully tagged as favorite.
    [Tags]    req-DEV-176    type-ok
    Given I am a logged-in reader
    When I view a book's details
    And I click on the 'Add to Favorites' button
    Then book should be added to my favorites list

Tag a book as favorite - unsuccessful scenario
    [Documentation]    Verify that a book cannot be tagged as favorite when there is a network error.
    [Tags]    req-DEV-176    type-nok
    Given I am a logged-in reader
    When I view a book's details
    And I click on the 'Add to Favorites' button
    And there is a network error
    Then book should not be added to my favorites list

View favorite books - successful scenario
    [Documentation]    Verify that a logged-in reader can view their favorite books.
    [Tags]    req-DEV-176    type-ok
    Given I am a logged-in reader
    When I navigate to the favorites page
    Then I should see a list of all books I have tagged as favorites

View favorite books - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when there is a server error while viewing favorite books.
    [Tags]    req-DEV-176    type-nok
    Given I am a logged-in reader
    When I navigate to the favorites page
    And there is a server error
    Then I should see an error message indicating the favorites list cannot be loaded

Remove a book from favorites - successful scenario
    [Documentation]    Verify that a book can be successfully removed from favorites.
    [Tags]    req-DEV-176    type-ok
    Given I am a logged-in reader
    When I view a book's details that is already in my favorites
    And I click on the 'Remove from Favorites' button
    Then book should be removed from my favorites list

Remove a book from favorites - unsuccessful scenario
    [Documentation]    Verify that a book cannot be removed from favorites when there is a network error.
    [Tags]    req-DEV-176    type-nok
    Given I am a logged-in reader
    When I view a book's details that is already in my favorites
    And I click on the 'Remove from Favorites' button
    And there is a network error
    Then book should not be removed from my favorites list

*** Keywords ***
I am a logged-in reader
    New Browser    chromium
    New Page    ${URL}
    Get Element    username
    Fill Text    username    ${USERNAME}
    Get Element    password
    Fill Text    password    ${PASSWORD}
    Click    login_button

I view a book's details
    Click    book_details_button

I click on the 'Add to Favorites' button
    Click    add_to_favorites_button

I click on the 'Remove from Favorites' button
    Click    remove_from_favorites_button

I navigate to the favorites page
    Click    favorites_page_button

there is a network error
    # Simulate Network Error
    # Implement network error simulation here

there is a server error
    # Simulate Server Error
    # Implement server error simulation here

book should be added to my favorites list
    Get Element    favorite_book

book should not be added to my favorites list
    Get Element    favorite_book

I should see a list of all books I have tagged as favorites
    Get Element    favorites_list

I should see an error message indicating the favorites list cannot be loaded
    Get Element    error_message

book should be removed from my favorites list
    Get Element    favorite_book

book should not be removed from my favorites list
    Get Element    favorite_book
