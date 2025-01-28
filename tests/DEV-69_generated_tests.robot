*** Settings ***
Documentation    Test suite for book removal scenarios
Library          Browser

*** Variables ***
${BOOK_URL}      http://example.com/book
${BOOK_TITLE}    Example Book

*** Test Cases ***
Remove a book - successful scenario
    [Documentation]    Given I am a book seller
    ...                When I choose to remove a book from the store
    ...                Then the book should no longer be available for customers to order
    [Tags]    req-DEV-69    type-ok
    I Am A Book Seller
    I Choose To Remove A Book From The Store
    The Book Should No Longer Be Available For Customers To Order

Remove a book without proper authorization - unsuccessful scenario
    [Documentation]    Given I am a book seller
    ...                And I do not have the necessary permissions
    ...                When I choose to remove a book from the store
    ...                Then I should receive an error message indicating lack of permissions
    ...                And the book should still be available for customers to order
    [Tags]    req-DEV-69    type-nok
    I Am A Book Seller
    I Do Not Have The Necessary Permissions
    I Choose To Remove A Book From The Store
    I Should Receive An Error Message Indicating Lack Of Permissions
    The Book Should Still Be Available For Customers To Order

*** Keywords ***
I Am A Book Seller
    New Browser    chromium
    New Page    ${BOOK_URL}
    Login As Book Seller

I Choose To Remove A Book From The Store
    Click    text=${BOOK_TITLE}
    Click    id=remove-button

The Book Should No Longer Be Available For Customers To Order
    Reload
    Wait For Elements State    text=${BOOK_TITLE}    hidden

I Do Not Have The Necessary Permissions
    Logout
    Login As Unauthorized User

I Should Receive An Error Message Indicating Lack Of Permissions
    Click    id=remove-button
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    You do not have the necessary permissions

The Book Should Still Be Available For Customers To Order
    Reload
    Wait For Elements State    text=${BOOK_TITLE}    visible

Login As Book Seller
    Fill Text    id=username    bookseller
    Fill Text    id=password    password123
    Click    id=login-button
    Wait For Elements State    id=logout-button    visible

Logout
    Click    id=logout-button
    Wait For Elements State    id=login-button    visible

Login As Unauthorized User
    Fill Text    id=username    unauthorizeduser
    Fill Text    id=password    password123
    Click    id=login-button
    Wait For Elements State    id=logout-button    visible
