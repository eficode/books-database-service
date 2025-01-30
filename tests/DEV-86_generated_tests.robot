*** Settings ***
Documentation    Suite for testing book search functionality by color
Library          Browser

*** Variables ***
${URL}           http://example.com

*** Test Cases ***
Search books by a specific color - successful scenario
    [Documentation]    Search books by a specific color - successful scenario
    [Tags]    req-DEV-85    type-ok
    Given I am a book seller
    When I search for books by the color 'red'
    Then I should see a list of books that have the color 'red' in their description or cover image

Search books by a specific color with no results - unsuccessful scenario
    [Documentation]    Search books by a specific color with no results - unsuccessful scenario
    [Tags]    req-DEV-85    type-nok
    Given I am a book seller
    When I search for books by the color 'red'
    And there are no books with the color 'red' in their description or cover image
    Then I should see a message indicating that no books were found with the color 'red'

No books found for a specific color - successful scenario
    [Documentation]    No books found for a specific color - successful scenario
    [Tags]    req-DEV-85    type-ok
    Given I am a book seller
    When I search for books by the color 'purple'
    Then I should see a message indicating that no books were found with the color 'purple'

No books found for a specific color with existing results - unsuccessful scenario
    [Documentation]    No books found for a specific color with existing results - unsuccessful scenario
    [Tags]    req-DEV-85    type-nok
    Given I am a book seller
    When I search for books by the color 'purple'
    And there are books with the color 'purple' in their description or cover image
    Then I should see a list of books that have the color 'purple' in their description or cover image

*** Keywords ***
I am a book seller
    Browser.New Page    ${URL}

I search for books by the color ${color}
    Browser.Fill Text    input[name="search"]    ${color}
    Browser.Click    button[name="searchButton"]

I should see a list of books that have the color ${color} in their description or cover image
    ${books}=    Browser.Get Elements    css=.book-item
    FOR    ${book}    IN    @{books}
        ${description}=    Browser.Get Text    ${book} .description
        ${cover}=    Browser.Get Attribute    ${book} img    src
        Should Contain    ${description}    ${color}
        Should Contain    ${cover}    ${color}
    END

There are no books with the color ${color} in their description or cover image
    ${books}=    Browser.Get Elements    css=.book-item
    FOR    ${book}    IN    @{books}
        ${description}=    Browser.Get Text    ${book} .description
        ${cover}=    Browser.Get Attribute    ${book} img    src
        Should Not Contain    ${description}    ${color}
        Should Not Contain    ${cover}    ${color}
    END

There are books with the color ${color} in their description or cover image
    ${books}=    Browser.Get Elements    css=.book-item
    FOR    ${book}    IN    @{books}
        ${description}=    Browser.Get Text    ${book} .description
        ${cover}=    Browser.Get Attribute    ${book} img    src
        Should Contain    ${description}    ${color}
        Should Contain    ${cover}    ${color}
    END

I should see a message indicating that no books were found with the color ${color}
    ${message}=    Browser.Get Text    css=.no-results
    Should Be Equal    ${message}    No books found with the color ${color}
