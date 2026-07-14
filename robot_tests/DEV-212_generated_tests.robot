*** Settings ***
Library    Browser

Documentation    Test suite for verifying the functionality of viewing and managing favorite tagged books.

*** Variables ***
${URL}    http://example.com
${USERNAME}    user
${PASSWORD}    pass

*** Test Cases ***
View favorite tagged books - successful scenario
    [Documentation]    Verify that a logged-in user can view a list of all favorite tagged books.
    [Tags]    req-DEV-211    type-ok
    Given I am a logged-in user
    When I navigate to the favorites page
    Then I should see a list of all my favorite tagged books

View favorite tagged books - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees a message when there are no favorite tagged books.
    [Tags]    req-DEV-211    type-nok
    Given I am a logged-in user
    When I navigate to the favorites page
    And there are no favorite tagged books
    Then I should see a message indicating that there are no favorite tagged books

Manage favorite tagged books - successful scenario
    [Documentation]    Verify that a logged-in user can manage favorite tagged books by adding and removing books.
    [Tags]    req-DEV-211    type-ok
    Given I am a logged-in user
    When I view my favorite tagged books
    Then I should be able to remove a book from my favorites
    And I should be able to add a new book to my favorites

Manage favorite tagged books - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees error messages when trying to manage non-existent or duplicate favorite tagged books.
    [Tags]    req-DEV-211    type-nok
    Given I am a logged-in user
    When I view my favorite tagged books
    And I try to remove a book that is not in my favorites
    Then I should see an error message indicating that the book cannot be removed
    And I try to add a book that is already in my favorites
    Then I should see an error message indicating that the book is already in my favorites

*** Keywords ***
I am a logged-in user
    New Browser    chromium
    New Page    ${URL}
    Get Element    [role="textbox"][name="username"]
    Input Text    [role="textbox"][name="username"]    ${USERNAME}
    Get Element    [role="textbox"][name="password"]
    Input Text    [role="textbox"][name="password"]    ${PASSWORD}
    Get Element    [role="button"][name="login_button"]
    Click    [role="button"][name="login_button"]
    Get Element    [role="main"][name="home_page"]
    Wait For Elements State    [role="main"][name="home_page"]    visible

I navigate to the favorites page
    Get Element    [role="link"][name="favorites_link"]
    Click    [role="link"][name="favorites_link"]
    Get Element    [role="main"][name="favorites_page"]
    Wait For Elements State    [role="main"][name="favorites_page"]    visible

I should see a list of all my favorite tagged books
    Get Element    [role="list"][name="favorite_books_list"]
    Wait For Elements State    [role="list"][name="favorite_books_list"]    visible

There are no favorite tagged books
    Get Element    [role="list"][name="favorite_books_list"]
    Clear    [role="list"][name="favorite_books_list"]

I should see a message indicating that there are no favorite tagged books
    Get Element    [role="alert"][name="no_favorites_message"]
    Wait For Elements State    [role="alert"][name="no_favorites_message"]    visible

I view my favorite tagged books
    Get Element    [role="link"][name="favorites_link"]
    Click    [role="link"][name="favorites_link"]
    Get Element    [role="main"][name="favorites_page"]
    Wait For Elements State    [role="main"][name="favorites_page"]    visible

I should be able to remove a book from my favorites
    Get Element    [role="button"][name="remove_book_button"]
    Click    [role="button"][name="remove_book_button"]
    Get Element    [role="listitem"][name="removed_book"]
    Wait For Elements State    [role="listitem"][name="removed_book"]    hidden

I should be able to add a new book to my favorites
    Get Element    [role="button"][name="add_book_button"]
    Click    [role="button"][name="add_book_button"]
    Get Element    [role="listitem"][name="new_favorite_book"]
    Wait For Elements State    [role="listitem"][name="new_favorite_book"]    visible

I try to remove a book that is not in my favorites
    Get Element    [role="button"][name="remove_nonexistent_book_button"]
    Click    [role="button"][name="remove_nonexistent_book_button"]

I should see an error message indicating that the book cannot be removed
    Get Element    [role="alert"][name="remove_error_message"]
    Wait For Elements State    [role="alert"][name="remove_error_message"]    visible

I try to add a book that is already in my favorites
    Get Element    [role="button"][name="add_duplicate_book_button"]
    Click    [role="button"][name="add_duplicate_book_button"]

I should see an error message indicating that the book is already in my favorites
    Get Element    [role="alert"][name="add_error_message"]
    Wait For Elements State    [role="alert"][name="add_error_message"]    visible
