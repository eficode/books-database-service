*** Settings ***
Documentation    Test suite for verifying the search functionality for top-rated books on Bookbridge Solution.
Library          Browser

*** Variables ***
${URL}           https://bookbridge-solution.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
Search for top-rated books - successful scenario
    [Documentation]    Verify that a logged-in customer can search for and see a list of top-rated software development books, and add them to the wishlist.
    [Tags]    req-GENAI-109    type-ok
    Given I am a logged-in Bookbridge Solution customer
    When I search for top-rated software development books
    Then I should see a list of top-rated software development books
    And I should be able to add any of these books to my wishlist

Search for top-rated books with no results - unsuccessful scenario
    [Documentation]    Verify that a logged-in customer sees a message indicating no books were found when there are no top-rated software development books available, and cannot add any books to the wishlist.
    [Tags]    req-GENAI-109    type-nok
    Given I am a logged-in Bookbridge Solution customer
    When I search for top-rated software development books
    And there are no top-rated software development books available
    Then I should see a message indicating no books were found
    And I should not be able to add any books to my wishlist

*** Keywords ***
I am a logged-in Bookbridge Solution customer
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I search for top-rated software development books
    Fill Text    id=search-bar    top-rated software development books
    Click    id=search-button
    Wait For Elements State    css=.book-list    visible

I should see a list of top-rated software development books
    ${books}=    Get Elements    css=.book-list .book-item
    Should Be True    ${books} != []

I should be able to add any of these books to my wishlist
    ${books}=    Get Elements    css=.book-list .book-item
    FOR    ${book}    IN    @{books}
        Click    ${book}    text=Add to Wishlist
        Wait For Elements State    css=.wishlist .book-item    visible
    END

There are no top-rated software development books available
    Evaluate    document.querySelectorAll('.book-list .book-item').forEach(e => e.remove());

I should see a message indicating no books were found
    Wait For Elements State    text=No books found    visible

I should not be able to add any books to my wishlist
    ${wishlist_button}=    Get Element    css=.add-to-wishlist
    Wait For Elements State    ${wishlist_button}    hidden
