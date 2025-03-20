*** Settings ***
Documentation    This test suite verifies the functionality of displaying related academic literature for a selected book.
Library          Browser

*** Variables ***
${BOOK_URL}    https://example.com/book

*** Test Cases ***
Display related academic literature - successful scenario
    [Documentation]    Verify that related academic literature published before 1980 is displayed with title, author, and publication year.
    [Tags]    req-GENAI-154    type-ok
    customer has selected a book
    customer views the book details
    system should display a list of related academic literature published before 1980
    list should include the title, author, and publication year of each related academic work

Display related academic literature with missing data - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when related academic literature data is incomplete.
    [Tags]    req-GENAI-154    type-nok
    customer has selected a book
    customer views the book details
    system fails to retrieve the title, author, or publication year of the related academic work
    system should display an error message indicating incomplete data

No related academic literature found - successful scenario
    [Documentation]    Verify that a message is displayed when no related academic literature published before 1980 is found.
    [Tags]    req-GENAI-154    type-ok
    customer has selected a book
    customer views the book details
    no related academic literature published before 1980 is found
    system should display a message indicating that no related academic literature is available

No related academic literature found with system error - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when the system encounters an error while searching for related academic literature.
    [Tags]    req-GENAI-154    type-nok
    customer has selected a book
    customer views the book details
    system encounters an error while searching for related academic literature
    system should display an error message indicating a system issue

*** Keywords ***
customer has selected a book
    New Page    ${BOOK_URL}

customer views the book details
    Click    text=View Details
    Wait For Elements State    text=Related Academic Literature    visible

system should display a list of related academic literature published before 1980
    Wait For Elements State    css=.academic-literature-list    visible
    Get Text    css=.academic-literature-item
    Should Contain    ${text}    1980

list should include the title, author, and publication year of each related academic work
    Get Text    css=.academic-literature-item .title
    Should Not Be Empty    ${text}
    Get Text    css=.academic-literature-item .author
    Should Not Be Empty    ${text}
    Get Text    css=.academic-literature-item .year
    Should Not Be Empty    ${text}

system fails to retrieve the title, author, or publication year of the related academic work
    # Simulate failure by removing elements
    Evaluate    document.querySelector('.academic-literature-item .title').remove();    window

system should display an error message indicating incomplete data
    Wait For Elements State    text=Error: Incomplete Data    visible

no related academic literature published before 1980 is found
    # Simulate no data found
    Evaluate    document.querySelector('.academic-literature-list').innerHTML = '';    window

system should display a message indicating that no related academic literature is available
    Wait For Elements State    text=No related academic literature available    visible

system encounters an error while searching for related academic literature
    # Simulate system error
    Evaluate    throw new Error('System Error');    window

system should display an error message indicating a system issue
    Wait For Elements State    text=Error: System Issue    visible
