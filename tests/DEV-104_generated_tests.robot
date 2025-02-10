*** Settings ***
Documentation    Test suite for verifying book removal scenarios in the inventory system.
Library          Browser

*** Variables ***
${URL}           http://example.com
${VALID_BOOK_ID} 12345
${INVALID_BOOK_ID} abcde

*** Test Cases ***
Successfully Remove A Book
    [Documentation]    Verify that a book can be successfully removed from the inventory.
    [Tags]    req-DEV-103    type-ok
    Given I am a Product Owner
    When I choose to remove a book from the inventory
    Then the book should be removed from the catalog
    And the inventory should reflect the updated catalog

Attempt To Remove A Non-Existent Book
    [Documentation]    Verify that attempting to remove a non-existent book returns an error.
    [Tags]    req-DEV-103    type-nok
    Given I am a Product Owner
    When I attempt to remove a book that does not exist in the inventory
    Then I should receive an error message indicating the book does not exist

Attempt To Remove A Book Without Proper Authorization
    [Documentation]    Verify that attempting to remove a book without proper authorization returns an error.
    [Tags]    req-DEV-103    type-nok
    Given I am a Product Owner
    And I do not have the necessary permissions
    When I choose to remove a book from the inventory
    Then I should receive an error message indicating insufficient permissions

Attempt To Remove A Book With Invalid Book ID
    [Documentation]    Verify that attempting to remove a book with an invalid book ID returns an error.
    [Tags]    req-DEV-103    type-nok
    Given I am a Product Owner
    And I provide an invalid book ID
    When I choose to remove a book from the inventory
    Then I should receive an error message indicating invalid book ID

*** Keywords ***
I am a Product Owner
    New Browser    chromium
    New Page    ${URL}
    Login As Product Owner

choose to remove a book from the inventory
    Click    id=remove-book-button
    Fill Text    id=book-id-input    ${VALID_BOOK_ID}
    Click    id=confirm-remove-button

attempt to remove a book that does not exist in the inventory
    Click    id=remove-book-button
    Fill Text    id=book-id-input    non-existent-book-id
    Click    id=confirm-remove-button

I do not have the necessary permissions
    Logout
    Login As Unauthorized User

provide an invalid book ID
    Click    id=remove-book-button
    Fill Text    id=book-id-input    ${INVALID_BOOK_ID}
    Click    id=confirm-remove-button

book should be removed from the catalog
    Wait For Elements State    id=book-${VALID_BOOK_ID}    hidden

inventory should reflect the updated catalog
    Check Inventory Updated

should receive an error message indicating the book does not exist
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    Book does not exist

should receive an error message indicating insufficient permissions
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    Insufficient permissions

should receive an error message indicating invalid book ID
    Wait For Elements State    id=error-message    visible
    Get Text    id=error-message    ==    Invalid book ID

Login As Product Owner
    Fill Text    id=username    product_owner
    Fill Text    id=password    password123
    Click    id=login-button

Logout
    Click    id=logout-button

Login As Unauthorized User
    Fill Text    id=username    unauthorized_user
    Fill Text    id=password    password123
    Click    id=login-button

Check Inventory Updated
    # Custom keyword to verify the inventory is updated
