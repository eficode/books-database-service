*** Settings ***
Documentation    Test suite for book availability and update scenarios
Library          Browser

*** Variables ***
${URL}           http://example.com
${LOGISTICS_MANAGER}    Logistics Manager
${NON_MANAGER}   Non Manager

*** Test Cases ***
View book availability - successful scenario
    [Documentation]    Given I am a Logistics Manager
    ...                When I check the availability of a book
    ...                Then I should see the current stock level of the book
    ...                And I should be able to predict the delivery time for the end customer
    [Tags]    req-GENAI-56    type-ok
    I am a Logistics Manager
    I check the availability of a book
    I should see the current stock level of the book
    I should be able to predict the delivery time for the end customer

View book availability - unsuccessful scenario
    [Documentation]    Given I am not a Logistics Manager
    ...                When I check the availability of a book
    ...                Then I should not see the current stock level of the book
    ...                And I should not be able to predict the delivery time for the end customer
    [Tags]    req-GENAI-56    type-nok
    I am not a Logistics Manager
    I check the availability of a book
    I should not see the current stock level of the book
    I should not be able to predict the delivery time for the end customer

Update book availability - successful scenario
    [Documentation]    Given I am a Logistics Manager
    ...                When a book's stock level changes
    ...                Then the availability information should be updated in real-time
    ...                And end customer can see that the book is in stock
    [Tags]    req-GENAI-56    type-ok
    I am a Logistics Manager
    A book's stock level changes
    The availability information should be updated in real-time
    End customer can see that the book is in stock

Update book availability - unsuccessful scenario
    [Documentation]    Given I am not a Logistics Manager
    ...                When a book's stock level changes
    ...                Then the availability information should not be updated in real-time
    ...                And end customer cannot see that the book is in stock
    [Tags]    req-GENAI-56    type-nok
    I am not a Logistics Manager
    A book's stock level changes
    The availability information should not be updated in real-time
    End customer cannot see that the book is in stock

*** Keywords ***
I am a Logistics Manager
    New Browser    chromium
    New Page    ${URL}
    Login As    ${LOGISTICS_MANAGER}

I am not a Logistics Manager
    New Browser    chromium
    New Page    ${URL}
    Login As    ${NON_MANAGER}

I check the availability of a book
    Click    //button[@id='check-availability']

I should see the current stock level of the book
    Wait For Elements State    //div[@id='stock-level']    visible
    Get Element State    //div[@id='stock-level']    visible

I should be able to predict the delivery time for the end customer
    Wait For Elements State    //div[@id='delivery-time']    visible
    Get Element State    //div[@id='delivery-time']    visible

I should not see the current stock level of the book
    Get Element State    //div[@id='stock-level']    hidden

I should not be able to predict the delivery time for the end customer
    Get Element State    //div[@id='delivery-time']    hidden

A book's stock level changes
    Click    //button[@id='update-stock']

The availability information should be updated in real-time
    Wait For Elements State    //div[@id='stock-level']    visible
    Get Element State    //div[@id='stock-level']    visible

End customer can see that the book is in stock
    Wait For Elements State    //div[@id='customer-view']    visible
    Get Element State    //div[@id='customer-view']    visible

The availability information should not be updated in real-time
    Get Element State    //div[@id='stock-level']    hidden

End customer cannot see that the book is in stock
    Get Element State    //div[@id='customer-view']    hidden
