*** Settings ***
Documentation    Test suite for BookBridge similar books feature
Library          Browser

*** Variables ***
${BOOKBRIDGE_URL}    https://bookbridge.example.com
${USERNAME}          user
${PASSWORD}          pass

*** Test Cases ***
View similar books - successful scenario
    [Documentation]    View similar books - successful scenario
    [Tags]    req-DEV-74    type-ok
    I am a logged-in BookBridge customer
    I have a list of books I have read
    I view the details of a book I have read
    I should see a list of similar books recommended based on that book

View similar books with no recommendations - unsuccessful scenario
    [Documentation]    View similar books with no recommendations - unsuccessful scenario
    [Tags]    req-DEV-74    type-nok
    I am a logged-in BookBridge customer
    I have a list of books I have read
    I view the details of a book I have read
    I should see a message indicating no similar books are available

Filter similar books by category - successful scenario
    [Documentation]    Filter similar books by category - successful scenario
    [Tags]    req-DEV-74    type-ok
    I am viewing similar books recommended based on a book I have read
    I apply a category filter
    I should see a list of similar books within the selected category

Filter similar books by category with no results - unsuccessful scenario
    [Documentation]    Filter similar books by category with no results - unsuccessful scenario
    [Tags]    req-DEV-74    type-nok
    I am viewing similar books recommended based on a book I have read
    I apply a category filter
    I should see a message indicating no books are available in the selected category

*** Keywords ***
I am a logged-in BookBridge customer
    New Page    ${BOOKBRIDGE_URL}
    Click    text=Login
    Fill Text    input[name="username"]    ${USERNAME}
    Fill Text    input[name="password"]    ${PASSWORD}
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I have a list of books I have read
    Click    text=My Books
    Wait For Elements State    text=Books I Have Read    visible

I view the details of a book I have read
    Click    text=Books I Have Read
    Click    text=View Details
    Wait For Elements State    text=Similar Books    visible

I should see a list of similar books recommended based on that book
    Wait For Elements State    text=Recommended Books    visible
    Get Text    text=Recommended Books

I should see a message indicating no similar books are available
    Wait For Elements State    text=No similar books available    visible
    Get Text    text=No similar books available

I am viewing similar books recommended based on a book I have read
    I am a logged-in BookBridge customer
    I have a list of books I have read
    I view the details of a book I have read

I apply a category filter
    Click    text=Filter
    Click    text=Category
    Click    text=Apply
    Wait For Elements State    text=Filtered Books    visible

I should see a list of similar books within the selected category
    Wait For Elements State    text=Filtered Books    visible
    Get Text    text=Filtered Books

I should see a message indicating no books are available in the selected category
    Wait For Elements State    text=No books available in this category    visible
    Get Text    text=No books available in this category
