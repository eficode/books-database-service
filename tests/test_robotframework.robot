*** Settings ***
Library  Browser

*** Variables ***
${URL}  http://localhost:8000

*** Test Cases ***
Successfully remove a book
    [Documentation]  Allow book sellers to remove a book from the store so that customers can no longer order it.
    [Tags]  req-DEV-7  type-ok
    Given I am a book seller
    When I choose to remove a book from the store
    Then the book should no longer be available for customers to order

Attempt to remove a non-existent book
    [Documentation]  Attempt to remove a non-existent book from the store.
    [Tags]  req-DEV-7  type-ok
    Given I am a book seller
    When I attempt to remove a book that does not exist in the store
    Then I should receive an error message indicating that the book cannot be found

Attempt to remove a book without authorization
    [Documentation]  Attempt to remove a book from the store without proper authorization.
    [Tags]  req-DEV-7  type-nok
    Given I am a book seller
    And I am not authorized to remove books
    When I choose to remove a book from the store
    Then I should receive an error message indicating that I am not authorized to perform this action
