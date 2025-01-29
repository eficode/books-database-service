*** Settings ***
Documentation    Test suite for viewing new releases for previously bought books
Library          Browser

*** Variables ***
${URL}           https://example.com
${USERNAME}      testuser
${PASSWORD}      password123

*** Test Cases ***
View new releases for previously bought books - successful scenario
    [Documentation]    View new releases for previously bought books - successful scenario
    [Tags]    req-GENAI-52    type-ok
    I am a logged-in customer
    I search for any books
    I should see a section for new releases from my previously bought books based on author

View new releases for previously bought books - unsuccessful scenario
    [Documentation]    View new releases for previously bought books - unsuccessful scenario
    [Tags]    req-GENAI-52    type-nok
    I am a logged-in customer
    I search for any books
    There is an error fetching new releases from the backend
    I should see an error message indicating that new releases cannot be displayed at this time

No new releases available - successful scenario
    [Documentation]    No new releases available - successful scenario
    [Tags]    req-GENAI-52    type-ok
    I am a logged-in customer
    I navigate to my library
    There are no new releases for my previously bought books
    I should see a message indicating that there are no new releases at this time

No new releases available - unsuccessful scenario
    [Documentation]    No new releases available - unsuccessful scenario
    [Tags]    req-GENAI-52    type-nok
    I am a logged-in customer
    I navigate to my library
    There is an error fetching new releases from the backend
    I should see an error message indicating that new releases cannot be displayed at this time

*** Keywords ***
I am a logged-in customer
    New Page    ${URL}
    Click    text=Login
    Fill Text    id=username    ${USERNAME}
    Fill Text    id=password    ${PASSWORD}
    Click    id=loginButton
    Wait For Elements State    id=logoutButton    visible

I search for any books
    Click    text=Search
    Fill Text    id=searchBox    some book
    Click    id=searchButton
    Wait For Elements State    id=searchResults    visible

I should see a section for new releases from my previously bought books based on author
    Wait For Elements State    id=newReleasesSection    visible
    Get Element    id=newReleasesSection

There is an error fetching new releases from the backend
    # Simulate backend error
    Evaluate    window.simulateBackendError()

I should see an error message indicating that new releases cannot be displayed at this time
    Wait For Elements State    id=errorMessage    visible
    Get Element    id=errorMessage
    Get Text    id=errorMessage    ==    New releases cannot be displayed at this time

I navigate to my library
    Click    text=My Library
    Wait For Elements State    id=myLibraryPage    visible

There are no new releases for my previously bought books
    # Simulate no new releases
    Evaluate    window.simulateNoNewReleases()

I should see a message indicating that there are no new releases at this time
    Wait For Elements State    id=noNewReleasesMessage    visible
    Get Element    id=noNewReleasesMessage
    Get Text    id=noNewReleasesMessage    ==    There are no new releases at this time
