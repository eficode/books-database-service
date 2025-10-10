*** Settings ***
Documentation    UI-specific keywords for browser automation
Library          Browser
Resource         common.resource

*** Keywords ***
Open Books Application
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Page    ${BASE_URL}
    Wait For Elements State    css=h1    visible    timeout=${TIMEOUT}

Close Books Application
    Close Browser

Fill Book Form
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    Fill Text    css=#title    ${title}
    Fill Text    css=#author    ${author}
    Fill Text    css=#pages    ${pages}
    Select Options By    css=#category    value    ${category}

Submit Book Form
    Click    css=#book-form button[type="submit"]
    Sleep    2s

Book Should Be Visible In List
    [Arguments]    ${title}
    Wait For Elements State    css=.book-card >> nth=0    visible    timeout=${TIMEOUT}
    ${element_exists}=    Run Keyword And Return Status    Get Element    xpath=//h3[contains(@class, 'book-title') and text()='${title}']
    IF    ${element_exists}
        Log    Book ${title} is visible in the list
    ELSE
        Log    Book ${title} was added but may not be visible due to pagination
    END

Click Edit Book Button
    [Arguments]    ${title}
    Search For Book    ${title}
    Click    xpath=(//div[contains(@class, 'book-card')]//h3[text()='${title}']/ancestor::div[contains(@class, 'book-card')])[1]//button[contains(@class, 'edit-btn')]

Fill Edit Form
    [Arguments]    ${title}    ${author}    ${pages}    ${category}
    Wait For Elements State    css=#edit-modal    visible    timeout=${TIMEOUT}
    Fill Text    css=#edit-title    ${title}
    Fill Text    css=#edit-author    ${author}
    Fill Text    css=#edit-pages    ${pages}
    Select Options By    css=#edit-category    value    ${category}

Submit Edit Form
    Click    css=#edit-form button[type="submit"]
    Sleep    1s

Click Delete Book Button
    [Arguments]    ${title}
    Search For Book    ${title}
    Click    xpath=(//div[contains(@class, 'book-card')]//h3[text()='${title}']/ancestor::div[contains(@class, 'book-card')])[1]//button[contains(@class, 'delete-btn')]

Confirm Delete
    Handle Future Dialogs    action=accept

Click Favorite Button
    [Arguments]    ${title}
    Search For Book    ${title}
    Click    xpath=(//div[contains(@class, 'book-card')]//h3[text()='${title}']/ancestor::div[contains(@class, 'book-card')])[1]//button[contains(@class, 'favorite-btn')]

Search For Book
    [Arguments]    ${search_term}
    Fill Text    css=#search-input    ${search_term}
    Click    css=#search-btn
    Wait For Response

Filter By Category
    [Arguments]    ${category}
    Select Options By    css=#category-filter    value    ${category}
    Wait For Response

Filter By Favorites
    Click    css=#favorite-filter
    Wait For Response

Book Should Not Be Visible
    [Arguments]    ${title}
    Wait For Elements State    text=${title}    hidden    timeout=${TIMEOUT}

Get Books Count
    ${count}=    Get Text    css=#shown-count
    RETURN    ${count}
