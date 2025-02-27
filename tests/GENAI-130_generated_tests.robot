*** Settings ***
Documentation    This test suite verifies the functionality of bookmarking books, viewing bookmarked books, and removing bookmarks.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
Bookmark a book - successful scenario
    [Documentation]    Verify that a book can be successfully bookmarked.
    [Tags]    req-GENAI-128    type-ok
    Given I am an authenticated user
    When I view a book's details
    And I click on the 'Bookmark' button
    Then the book should be added to my list of bookmarked books

Bookmark a book - unsuccessful scenario
    [Documentation]    Verify that a book cannot be bookmarked when there is a network error.
    [Tags]    req-GENAI-128    type-nok
    Given I am an authenticated user
    When I view a book's details
    And I click on the 'Bookmark' button
    And there is a network error
    Then the book should not be added to my list of bookmarked books

View bookmarked books - successful scenario
    [Documentation]    Verify that the list of bookmarked books can be viewed successfully.
    [Tags]    req-GENAI-128    type-ok
    Given I am an authenticated user
    When I navigate to my bookmarks section
    Then I should see a list of all books I have bookmarked

View bookmarked books - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when there is a server error while viewing bookmarked books.
    [Tags]    req-GENAI-128    type-nok
    Given I am an authenticated user
    When I navigate to my bookmarks section
    And there is a server error
    Then I should see an error message indicating that the bookmarks cannot be loaded

Remove a bookmark - successful scenario
    [Documentation]    Verify that a bookmark can be successfully removed.
    [Tags]    req-GENAI-128    type-ok
    Given I am an authenticated user
    When I view my list of bookmarked books
    And I click on the 'Remove Bookmark' button for a book
    Then the book should be removed from my list of bookmarked books

Remove a bookmark - unsuccessful scenario
    [Documentation]    Verify that a bookmark cannot be removed when there is a database error.
    [Tags]    req-GENAI-128    type-nok
    Given I am an authenticated user
    When I view my list of bookmarked books
    And I click on the 'Remove Bookmark' button for a book
    And there is a database error
    Then the book should not be removed from my list of bookmarked books

*** Keywords ***
I am an authenticated user
    New Page    ${URL}
    Click    text=Login
    Fill Text    username    ${USERNAME}
    Fill Text    password    ${PASSWORD}
    Click    text=Submit

I view a book's details
    Click    text=Books
    Click    text=Book Title

I click on the 'Bookmark' button
    Click    text=Bookmark

There is a network error
    # Simulate Network Error
    Evaluate    window.navigator.onLine = false

The book should be added to my list of bookmarked books
    Click    text=Bookmarks
    Get Text    text=Book Title    ${book_title}
    Should Be Equal    ${book_title}    Book Title

The book should not be added to my list of bookmarked books
    Click    text=Bookmarks
    Get Text    text=Book Title    ${book_title}
    Should Not Be Equal    ${book_title}    Book Title

I navigate to my bookmarks section
    Click    text=Bookmarks

I should see a list of all books I have bookmarked
    Get Text    text=Book Title    ${book_title}
    Should Be Equal    ${book_title}    Book Title

There is a server error
    # Simulate Server Error
    Evaluate    window.serverError = true

I should see an error message indicating that the bookmarks cannot be loaded
    Get Text    text=Error loading bookmarks    ${error_message}
    Should Be Equal    ${error_message}    Error loading bookmarks

I view my list of bookmarked books
    Click    text=Bookmarks

I click on the 'Remove Bookmark' button for a book
    Click    text=Remove Bookmark

The book should be removed from my list of bookmarked books
    Get Text    text=Book Title    ${book_title}
    Should Not Be Equal    ${book_title}    Book Title

There is a database error
    # Simulate Database Error
    Evaluate    window.databaseError = true

The book should not be removed from my list of bookmarked books
    Get Text    text=Book Title    ${book_title}
    Should Be Equal    ${book_title}    Book Title
