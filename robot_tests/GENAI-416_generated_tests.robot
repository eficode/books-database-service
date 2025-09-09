*** Settings ***
Documentation    This test suite verifies the functionality of adding books to a collection and viewing updated recommendations.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
Add a new book to the collection - successful scenario
    [Documentation]    Verify that a logged-in user can successfully add a new book to their collection.
    [Tags]    req-GENAI-414    type-ok
    I am a logged-in user
    I navigate to the 'Add Book' section
    I enter the book details    title=Example Book    author=John Doe    genre=Fiction
    I submit the form
    The book should be added to my collection
    I should receive a confirmation message

Add a new book to the collection with missing details - unsuccessful scenario
    [Documentation]    Verify that a book cannot be added to the collection if required details are missing.
    [Tags]    req-GENAI-414    type-nok
    I am a logged-in user
    I navigate to the 'Add Book' section
    I enter the book details    title=Example Book    author=John Doe
    I submit the form
    The book should not be added to my collection
    I should receive an error message indicating missing details

View updated recommendations - successful scenario
    [Documentation]    Verify that recommendations are updated after adding a new book to the collection.
    [Tags]    req-GENAI-414    type-ok
    I have added a new book to my collection
    I navigate to the recommendations section
    I should see updated book recommendations based on my collection

View updated recommendations without adding a book - unsuccessful scenario
    [Documentation]    Verify that recommendations are not updated if no new book is added to the collection.
    [Tags]    req-GENAI-414    type-nok
    I have not added a new book to my collection
    I navigate to the recommendations section
    I should not see updated book recommendations
    I should see a message indicating no new recommendations

*** Keywords ***
I am a logged-in user
    New Page    ${URL}
    Click    text=Login
    Fill Text    username    ${USERNAME}
    Fill Text    password    ${PASSWORD}
    Click    text=Submit

I navigate to the 'Add Book' section
    Click    text=Add Book

I enter the book details
    [Arguments]    ${title}=${EMPTY}    ${author}=${EMPTY}    ${genre}=${EMPTY}
    Fill Text    title    ${title}
    Fill Text    author    ${author}
    Fill Text    genre    ${genre}

I submit the form
    Click    text=Submit

The book should be added to my collection
    Wait For Elements State    text=Example Book    visible

I should receive a confirmation message
    Wait For Elements State    text=Book added successfully    visible

The book should not be added to my collection
    Wait For Elements State    text=Example Book    hidden

I should receive an error message indicating missing details
    Wait For Elements State    text=Error: Missing details    visible

I have added a new book to my collection
    [Arguments]    ${title}=${EMPTY}    ${author}=${EMPTY}    ${genre}=${EMPTY}
    I am a logged-in user
    I navigate to the 'Add Book' section
    I enter the book details    ${title}=${title}    ${author}=${author}    ${genre}=${genre}
    I submit the form

I navigate to the recommendations section
    Click    text=Recommendations

I should see updated book recommendations based on my collection
    Wait For Elements State    text=Recommended for you    visible

I have not added a new book to my collection
    I am a logged-in user

I should not see updated book recommendations
    Wait For Elements State    text=Recommended for you    hidden

I should see a message indicating no new recommendations
    Wait For Elements State    text=No new recommendations    visible
