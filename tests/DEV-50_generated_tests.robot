*** Settings ***
Documentation    Test suite for managing red books in the store
Library          Browser

*** Variables ***
${STORE_URL}    http://example.com/store

*** Test Cases ***
Remove all red books from the store - successful scenario
    [Documentation]    Remove all red books from the store - successful scenario
    [Tags]    req-DEV-50    type-ok
    Given I am a book seller
    When I identify books with a red cover
    Then those books should be removed from the store's inventory
    And customers should no longer be able to order these books

Fail to remove all red books from the store - unsuccessful scenario
    [Documentation]    Fail to remove all red books from the store - unsuccessful scenario
    [Tags]    req-DEV-50    type-nok
    Given I am a book seller
    When I identify books with a red cover
    And there is an error in the inventory system
    Then those books should not be removed from the store's inventory
    And customers should still be able to order these books

*** Keywords ***
I am a book seller
    Browser.Open Browser    ${STORE_URL}    chromium
    Login as book seller

Login as book seller
    # Implement login steps here
    Browser.Fill Text    username_field    seller
    Browser.Fill Text    password_field    password
    Browser.Click    login_button
    Browser.Wait For Elements State    Welcome, seller    visible

I identify books with a red cover
    # Implement steps to identify red books
    Browser.Click    Books
    Browser.Click    Filter by color
    Browser.Click    Red
    Browser.Wait For Elements State    Red Books    visible

Those books should be removed from the store's inventory
    # Implement steps to remove books
    Browser.Click    Remove All
    Browser.Wait For Elements State    Red Books    hidden

Customers should no longer be able to order these books
    # Implement steps to verify books are not orderable
    Browser.Open Browser    ${STORE_URL}    chromium
    Search for red books
    Browser.Wait For Elements State    Red Books    hidden

There is an error in the inventory system
    # Simulate an error in the inventory system
    Simulate Inventory Error

Simulate Inventory Error
    # Implement steps to simulate an error
    Browser.Evaluate JavaScript    window.simulateInventoryError = true;

Those books should not be removed from the store's inventory
    # Verify books are still in inventory
    Browser.Reload
    Browser.Wait For Elements State    Red Books    visible

Customers should still be able to order these books
    # Verify books are still orderable
    Browser.Open Browser    ${STORE_URL}    chromium
    Search for red books
    Browser.Wait For Elements State    Red Books    visible

Search for red books
    # Implement search for red books
    Browser.Fill Text    search_field    red books
    Browser.Click    search_button
    Browser.Wait For Elements State    search_results    visible
