*** Settings ***
Documentation    This test suite verifies the book rating functionality including submitting ratings and viewing average ratings.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      testuser
${PASSWORD}      password123

*** Test Cases ***
Rate a book - successful scenario
    [Documentation]    Verify that a logged-in user can rate a book successfully.
    [Tags]    req-GENAI-340    type-ok
    Given I am a logged-in user
    When I navigate to a book's detail page
    Then I should see an option to rate the book from 0 to 5 stars
    And I should be able to submit my rating
    And I should see a confirmation message that my rating has been submitted

Rate a book - unsuccessful scenario
    [Documentation]    Verify that a logged-in user cannot rate a book when the rating system is down.
    [Tags]    req-GENAI-340    type-nok
    Given I am a logged-in user
    When I navigate to a book's detail page
    And the rating system is down
    Then I should not be able to submit my rating
    And I should see an error message indicating that the rating system is currently unavailable

View average rating - successful scenario
    [Documentation]    Verify that the average rating is displayed correctly on the book's detail page.
    [Tags]    req-GENAI-340    type-ok
    Given I am on a book's detail page
    When I view the book's rating section
    Then I should see the average rating based on all user ratings

View average rating - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when the average rating data is corrupted.
    [Tags]    req-GENAI-340    type-nok
    Given I am on a book's detail page
    When I view the book's rating section
    And the average rating data is corrupted
    Then I should see an error message indicating that the average rating cannot be displayed

*** Keywords ***
I am a logged-in user
    New Browser    headless=False
    New Page    ${URL}
    Click    text=Login
    Fill Text    username    ${USERNAME}
    Fill Text    password    ${PASSWORD}
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I navigate to a book's detail page
    Click    text=Books
    Click    text=Some Book Title
    Wait For Elements State    text=Rate this book    visible

I should see an option to rate the book from 0 to 5 stars
    Wait For Elements State    css=.rating-stars    visible

I should be able to submit my rating
    Click    css=.rating-stars > star:nth-child(5)
    Click    text=Submit Rating

I should see a confirmation message that my rating has been submitted
    Wait For Elements State    text=Your rating has been submitted    visible

The rating system is down
    # Simulate the rating system being down
    Evaluate    window.simulateRatingSystemDown()    window

I should not be able to submit my rating
    Click    css=.rating-stars > star:nth-child(5)
    Click    text=Submit Rating
    Wait For Elements State    text=Rating system is currently unavailable    visible

I should see an error message indicating that the rating system is currently unavailable
    Wait For Elements State    text=Rating system is currently unavailable    visible

I am on a book's detail page
    Click    text=Books
    Click    text=Some Book Title
    Wait For Elements State    text=Average Rating    visible

I view the book's rating section
    Wait For Elements State    css=.average-rating    visible

I should see the average rating based on all user ratings
    Wait For Elements State    css=.average-rating    visible

The average rating data is corrupted
    # Simulate corrupted average rating data
    Evaluate    window.simulateCorruptedAverageRatingData()    window

I should see an error message indicating that the average rating cannot be displayed
    Wait For Elements State    text=Average rating cannot be displayed    visible
