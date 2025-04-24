*** Settings ***
Documentation    This test suite verifies the functionality of the Favorites Page for Authors.
Library          Browser

*** Variables ***
${BASE_URL}      http://example.com
${USERNAME}      testuser
${PASSWORD}      password123

*** Test Cases ***
Add author to favorites - successful scenario
    [Documentation]    Verify that a logged-in user can successfully add an author to their favorites list.
    [Tags]    req-GENAI-234    type-ok
    Given I am a logged-in user
    When I navigate to an author's page
    And I click on 'Add to Favorites'
    Then the author should be added to my favorites list

Add author to favorites - unsuccessful scenario
    [Documentation]    Verify that a logged-in user cannot add an author to their favorites list if the author is already in the list.
    [Tags]    req-GENAI-234    type-nok
    Given I am a logged-in user
    When I navigate to an author's page
    And I click on 'Add to Favorites'
    But the author is already in my favorites list
    Then the author should not be added again to my favorites list

View favorites list - successful scenario
    [Documentation]    Verify that a logged-in user can view their list of favorite authors and their books.
    [Tags]    req-GENAI-234    type-ok
    Given I am a logged-in user
    When I navigate to my favorites page
    Then I should see a list of my favorite authors and their books

View favorites list - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees a message indicating no favorite authors if their favorites list is empty.
    [Tags]    req-GENAI-234    type-nok
    Given I am a logged-in user
    When I navigate to my favorites page
    But I have no favorite authors
    Then I should see a message indicating that I have no favorite authors

Remove author from favorites - successful scenario
    [Documentation]    Verify that a logged-in user can successfully remove an author from their favorites list.
    [Tags]    req-GENAI-234    type-ok
    Given I am a logged-in user
    When I navigate to my favorites page
    And I click on 'Remove from Favorites' next to an author
    Then the author should be removed from my favorites list

Remove author from favorites - unsuccessful scenario
    [Documentation]    Verify that a logged-in user cannot remove an author from their favorites list if the author is not in the list.
    [Tags]    req-GENAI-234    type-nok
    Given I am a logged-in user
    When I navigate to my favorites page
    And I click on 'Remove from Favorites' next to an author
    But the author is not in my favorites list
    Then the author should not be removed and I should see an error message

*** Keywords ***
I am a logged-in user
    New Browser    headless=False
    New Page    ${BASE_URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I navigate to an author's page
    Go To    ${BASE_URL}/author/123
    Wait For Elements State    text=Add to Favorites    visible

I click on 'Add to Favorites'
    Click    text=Add to Favorites
    Wait For Elements State    text=Remove from Favorites    visible

The author should be added to my favorites list
    Go To    ${BASE_URL}/favorites
    Wait For Elements State    text=Author Name    visible

The author is already in my favorites list
    Go To    ${BASE_URL}/favorites
    Wait For Elements State    text=Author Name    visible

The author should not be added again to my favorites list
    Go To    ${BASE_URL}/favorites
    Get Text    text=Author Name
    Get Text    text=Remove from Favorites

I navigate to my favorites page
    Go To    ${BASE_URL}/favorites
    Wait For Elements State    text=Favorites    visible

I should see a list of my favorite authors and their books
    Get Text    text=Author Name
    Get Text    text=Book Title

I have no favorite authors
    Get Text    text=Author Name

I should see a message indicating that I have no favorite authors
    Get Text    text=You have no favorite authors

I click on 'Remove from Favorites' next to an author
    Click    text=Remove from Favorites
    Wait For Elements State    text=Add to Favorites    visible

The author should be removed from my favorites list
    Go To    ${BASE_URL}/favorites
    Get Text    text=Author Name

The author is not in my favorites list
    Get Text    text=Author Name

The author should not be removed and I should see an error message
    Get Text    text=Error: Author not in favorites
