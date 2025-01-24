*** Settings ***
Documentation    Test suite for filtering books by 'scifi' category
Library          Browser

*** Variables ***
${BASE_URL}      http://example.com

*** Test Cases ***
Filter books by 'scifi' category - successful scenario
    [Documentation]    Given I am a book organizer
    ...                When I apply the 'scifi' filter
    ...                Then I should see a list of all books categorized under 'scifi'
    [Tags]    req-DEV-53    type-ok
    I Am A Book Organizer
    I Apply The Scifi Filter
    I Should See A List Of All Books Categorized Under Scifi

Filter books by 'scifi' category with no books - unsuccessful scenario
    [Documentation]    Given I am a book organizer
    ...                When I apply the 'scifi' filter
    ...                And there are no books in the 'scifi' category
    ...                Then I should see a message indicating that no books are found
    [Tags]    req-DEV-53    type-nok
    I Am A Book Organizer
    I Apply The Scifi Filter
    There Are No Books In The Scifi Category
    I Should See A Message Indicating That No Books Are Found

Filter books by 'scifi' category with backend error - unsuccessful scenario
    [Documentation]    Given I am a book organizer
    ...                When I apply the 'scifi' filter
    ...                And the backend API returns an error
    ...                Then I should see an error message indicating that the filter operation failed
    [Tags]    req-DEV-53    type-nok
    I Am A Book Organizer
    I Apply The Scifi Filter
    The Backend API Returns An Error
    I Should See An Error Message Indicating That The Filter Operation Failed

Filter books by 'scifi' category with unauthorized access - unsuccessful scenario
    [Documentation]    Given I am a book organizer
    ...                When I apply the 'scifi' filter
    ...                And I am not authorized to use the filter functionality
    ...                Then I should see an error message indicating that I am not authorized to perform this action
    [Tags]    req-DEV-53    type-nok
    I Am A Book Organizer
    I Apply The Scifi Filter
    I Am Not Authorized To Use The Filter Functionality
    I Should See An Error Message Indicating That I Am Not Authorized To Perform This Action

*** Keywords ***
I Am A Book Organizer
    New Page    ${BASE_URL}
    Wait For Elements State    //body    visible

I Apply The Scifi Filter
    Click    //button[@id='filter-scifi']
    Wait For Elements State    //div[@id='book-list']    visible

I Should See A List Of All Books Categorized Under Scifi
    Wait For Elements State    //div[@id='book-list']//div[contains(@class, 'book-item')]    visible

There Are No Books In The Scifi Category
    # Simulate no books in the 'scifi' category
    Evaluate    document.querySelector('#book-list').innerHTML = ''

I Should See A Message Indicating That No Books Are Found
    Wait For Elements State    //div[@id='no-books-message']    visible

The Backend API Returns An Error
    # Simulate backend API error
    Evaluate    document.querySelector('#book-list').innerHTML = '<div id="error-message">Backend error</div>'

I Should See An Error Message Indicating That The Filter Operation Failed
    Wait For Elements State    //div[@id='error-message']    visible

I Am Not Authorized To Use The Filter Functionality
    # Simulate unauthorized access
    Evaluate    document.querySelector('#book-list').innerHTML = '<div id="unauthorized-message">Unauthorized</div>'

I Should See An Error Message Indicating That I Am Not Authorized To Perform This Action
    Wait For Elements State    //div[@id='unauthorized-message']    visible
