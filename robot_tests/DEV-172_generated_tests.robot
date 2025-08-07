*** Settings ***
Library  Browser

Documentation  This test suite verifies the functionality of searching and removing low-selling books from the store.

*** Variables ***
${URL}  http://bookstore.example.com

*** Test Cases ***
Search for books with low sales - successful scenario
    [Documentation]  Verify that a list of low-selling books is displayed when searched.
    [Tags]  req-DEV-170  type-ok
    Given I am a book seller
    When I search for low-selling books
    Then I should see a list of books with sales below a certain threshold

Search for books with low sales - unsuccessful scenario
    [Documentation]  Verify that a message is displayed when no low-selling books are found.
    [Tags]  req-DEV-170  type-nok
    Given I am a book seller
    When I search for low-selling books
    And there are no books with sales below the threshold
    Then I should see a message indicating no low-selling books found

Remove low-selling books from the store - successful scenario
    [Documentation]  Verify that selected low-selling books are removed from the store inventory.
    [Tags]  req-DEV-170  type-ok
    Given I have a list of low-selling books  ${LOW_SELLING_BOOKS}
    When I select books to remove  ${LOW_SELLING_BOOKS}
    Then the selected books should be removed from the store inventory  ${LOW_SELLING_BOOKS}

Remove low-selling books from the store - unsuccessful scenario
    [Documentation]  Verify that an error message is displayed when books to be removed are not found in the inventory.
    [Tags]  req-DEV-170  type-nok
    Given I have a list of low-selling books  ${LOW_SELLING_BOOKS}
    When I select books to remove  ${LOW_SELLING_BOOKS}
    And the books are not found in the store inventory  ${LOW_SELLING_BOOKS}
    Then I should see an error message indicating the books could not be removed

*** Keywords ***
I am a book seller
    New Browser  chromium
    New Page  ${URL}
    Wait For Elements State  //input[@name='search']  visible=True

I search for low-selling books
    Click  //input[@name='search']
    Fill Text  //input[@name='search']  low-selling
    Click  //button[@name='searchButton']
    Wait For Elements State  //div[@id='results']  visible=True

I should see a list of books with sales below a certain threshold
    Browser.Get Element States  //div[@id='results']//li  visible=True

There are no books with sales below the threshold
    Wait For Elements State  //div[@id='noResultsMessage']  visible=True

I should see a message indicating no low-selling books found
    Browser.Get Element States  //div[@id='noResultsMessage']  visible=True

I have a list of low-selling books
    [Arguments]  ${book_list}
    Set Test Variable  ${LOW_SELLING_BOOKS}  ${book_list}

I select books to remove
    [Arguments]  ${book_list}
    FOR  ${book}  IN  @{book_list}
        Click  //li[contains(text(), '${book}')]
        Click  //button[@name='removeButton']
    END

The selected books should be removed from the store inventory
    [Arguments]  ${book_list}
    FOR  ${book}  IN  @{book_list}
        Browser.Get Element States  //li[contains(text(), '${book}')]  hidden=True
    END

The books are not found in the store inventory
    [Arguments]  ${book_list}
    FOR  ${book}  IN  @{book_list}
        Browser.Get Element States  //li[contains(text(), '${book}')]  hidden=True
    END

I should see an error message indicating the books could not be removed
    Browser.Get Element States  //div[@id='errorMessage']  visible=True
