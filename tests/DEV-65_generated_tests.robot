*** Settings ***
Documentation    Test suite for book removal scenarios
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Remove a book - successful scenario
    [Documentation]    Given I am a book seller
    [Tags]    req-DEV-65    type-ok
    I am a book seller
    When I choose to remove a book from the store
    Then the book should no longer be available for customers to order

Remove a book - unsuccessful scenario
    [Documentation]    Given I am a book seller
    [Tags]    req-DEV-65    type-nok
    I am a book seller
    The book does not exist in the store
    When I choose to remove a book from the store
    Then I should receive an error message indicating the book cannot be found

Confirm book removal - successful scenario
    [Documentation]    Given I have removed a book from the store
    [Tags]    req-DEV-65    type-ok
    I have removed a book from the store
    When I check the store inventory
    Then the book should not appear in the list of available books

Confirm book removal - unsuccessful scenario
    [Documentation]    Given I have removed a book from the store
    [Tags]    req-DEV-65    type-nok
    I have removed a book from the store
    The store inventory has not been updated
    When I check the store inventory
    Then the book should still appear in the list of available books

*** Keywords ***
I am a book seller
    New Browser    chromium
    New Page    ${URL}
    Get Text    text=Welcome, Book Seller

The book does not exist in the store
    # Implement logic to ensure the book does not exist
    Log    Ensuring the book does not exist in the store

I choose to remove a book from the store
    Click    //button[@id='remove-book']
    Wait For Elements State    text=Book removed successfully    visible

I should receive an error message indicating the book cannot be found
    Wait For Elements State    text=Error: Book cannot be found    visible

I have removed a book from the store
    # Implement logic to remove a book
    Log    Book has been removed from the store

I check the store inventory
    Click    //button[@id='inventory']
    Wait For Elements State    text=Store Inventory    visible

The book should no longer be available for customers to order
    Get Element States    //div[@class='book-title']    [