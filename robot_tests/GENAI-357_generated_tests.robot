*** Settings ***
Documentation    Test suite for verifying the summary page of books by writers
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
View summary page - successful scenario
    [Documentation]    Verify that a logged-in user can see a list of writers and the number of books they have from each writer
    [Tags]    req-GENAI-355    type-ok
    I am a logged-in user
    navigate to the summary page
    should see a list of writers
    should see the number of books I have from each writer

View summary page with no writers displayed - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees an error message when the backend API fails to fetch the writers
    [Tags]    req-GENAI-355    type-nok
    I am a logged-in user
    backend API fails to fetch the writers
    navigate to the summary page
    should not see a list of writers
    should see an error message indicating the data could not be loaded

No books available - successful scenario
    [Documentation]    Verify that a logged-in user sees a message indicating no books are available when they have no books in their collection
    [Tags]    req-GENAI-355    type-ok
    I am a logged-in user
    have no books in my collection
    navigate to the summary page
    should see a message indicating that no books are available

No books available with backend error - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees an error message when they have no books and the backend API fails to fetch the books data
    [Tags]    req-GENAI-355    type-nok
    I am a logged-in user
    have no books in my collection
    backend API fails to fetch the books data
    navigate to the summary page
    should see an error message indicating the data could not be loaded

*** Keywords ***
I am a logged-in user
    New Browser    chromium
    New Page    ${URL}
    Fill Text    username_field    ${USERNAME}
    Fill Text    password_field    ${PASSWORD}
    Click    login_button
    Wait For Elements State    summary_page    visible

navigate to the summary page
    Click    summary_page_link
    Wait For Elements State    summary_page_content    visible

should see a list of writers
    Wait For Elements State    writers_list    visible

should see the number of books I have from each writer
    Wait For Elements State    books_count    visible

backend API fails to fetch the writers
    # Simulate backend failure
    Evaluate    window.simulateBackendFailure('writers')

should not see a list of writers
    Wait For Elements State    writers_list    hidden

should see an error message indicating the data could not be loaded
    Wait For Elements State    error_message    visible

have no books in my collection
    # Simulate no books in collection
    Evaluate    window.simulateNoBooks()

should see a message indicating that no books are available
    Wait For Elements State    no_books_message    visible

backend API fails to fetch the books data
    # Simulate backend failure
    Evaluate    window.simulateBackendFailure('books')
