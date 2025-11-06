*** Settings ***
Documentation    This test suite verifies the functionality of the Favourites Page, including viewing, adding, removing, and managing favourite books.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      testuser
${PASSWORD}      testpass

*** Test Cases ***
View Favourites Page - successful scenario
    [Documentation]    Verify that a logged-in user can view the favourites page and see a list of favourite books.
    [Tags]    req-DEV-182    type-ok
    I am a logged-in user
    I navigate to the favourites page
    I should see a list of my favourite books

View Favourites Page - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees a message indicating no favourite books are available when the favourites list is empty.
    [Tags]    req-DEV-182    type-nok
    I am a logged-in user
    I navigate to the favourites page
    there are no books in my favourites list
    I should see a message indicating that no favourite books are available

Add Book to Favourites - successful scenario
    [Documentation]    Verify that a book can be added to the favourites list successfully.
    [Tags]    req-DEV-182    type-ok
    I am viewing a book
    I click on the 'Add to Favourites' button
    the book should be added to my favourites list

Add Book to Favourites - unsuccessful scenario
    [Documentation]    Verify that a book is not added to the favourites list when there is a network error, and an error message is displayed.
    [Tags]    req-DEV-182    type-nok
    I am viewing a book
    I click on the 'Add to Favourites' button
    there is a network error
    the book should not be added to my favourites list
    I should see an error message

Remove Book from Favourites - successful scenario
    [Documentation]    Verify that a book can be removed from the favourites list successfully.
    [Tags]    req-DEV-182    type-ok
    I am on the favourites page
    I click on the 'Remove from Favourites' button next to a book
    the book should be removed from my favourites list

Remove Book from Favourites - unsuccessful scenario
    [Documentation]    Verify that a book is not removed from the favourites list when there is a server error, and an error message is displayed.
    [Tags]    req-DEV-182    type-nok
    I am on the favourites page
    I click on the 'Remove from Favourites' button next to a book
    there is a server error
    the book should not be removed from my favourites list
    I should see an error message

Manage Favourites - successful scenario
    [Documentation]    Verify that a user can reorder the favourites list by dragging and dropping books.
    [Tags]    req-DEV-182    type-ok
    I am on the favourites page
    I drag and drop books
    I should be able to reorder my favourites list

Manage Favourites - unsuccessful scenario
    [Documentation]    Verify that the order of the favourites list does not change when there is a client-side error, and an error message is displayed.
    [Tags]    req-DEV-182    type-nok
    I am on the favourites page
    I drag and drop books
    there is a client-side error
    the order of my favourites list should not change
    I should see an error message

*** Keywords ***
I am a logged-in user
    New Page    ${URL}
    Click    text=Login
    Fill Text    username    ${USERNAME}
    Fill Text    password    ${PASSWORD}
    Click    text=Submit

I navigate to the favourites page
    Click    text=Favourites

I should see a list of my favourite books
    Wait For Elements State    text=Favourite Book    visible

there are no books in my favourites list
    New Page    ${URL}/favourites?empty=true

I should see a message indicating that no favourite books are available
    Wait For Elements State    text=No favourite books available    visible

I am viewing a book
    New Page    ${URL}/book/1

I click on the 'Add to Favourites' button
    Click    text=Add to Favourites

there is a network error
    # Simulate Network Error
    # Implement network error simulation here

I should see an error message
    Wait For Elements State    text=Error occurred    visible

I am on the favourites page
    New Page    ${URL}/favourites

I click on the 'Remove from Favourites' button next to a book
    Click    text=Remove from Favourites

there is a server error
    # Simulate Server Error
    # Implement server error simulation here

I drag and drop books
    Drag And Drop    text=Book 1    text=Book 2

I should be able to reorder my favourites list
    Wait For Elements State    text=Reordered    visible

there is a client-side error
    # Simulate Client Error
    # Implement client-side error simulation here

I should see an error message
    Wait For Elements State    text=Error occurred    visible

the book should be added to my favourites list
    Wait For Elements State    text=Book added to favourites    visible

the book should not be added to my favourites list
    Wait For Elements State    text=Book not added to favourites    visible

the book should be removed from my favourites list
    Wait For Elements State    text=Book removed from favourites    visible

the book should not be removed from my favourites list
    Wait For Elements State    text=Book not removed from favourites    visible

the order of my favourites list should not change
    Wait For Elements State    text=Order unchanged    visible
