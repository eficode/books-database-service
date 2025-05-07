*** Settings ***
Documentation    This test suite verifies the functionality of adding books to favourites, viewing the favourites list, and adding favourite books to the shopping cart.
Library          Browser

*** Variables ***
${URL}           http://example.com
${USERNAME}      user
${PASSWORD}      pass

*** Test Cases ***
Add a red book to favourites - successful scenario
    [Documentation]    Verify that a red book can be successfully added to favourites.
    [Tags]    req-DEV-165    type-ok
    I am a logged-in user
    I am viewing a red book
    I click on 'Add to Favourites'
    The book should be added to my favourites list
    I should see a confirmation message

Add a red book to favourites - unsuccessful scenario
    [Documentation]    Verify that a red book cannot be added to favourites if the system encounters an error.
    [Tags]    req-DEV-165    type-nok
    I am a logged-in user
    I am viewing a red book
    I click on 'Add to Favourites'
    The system encounters an error
    The book should not be added to my favourites list
    I should see an error message

View favourites list - successful scenario
    [Documentation]    Verify that the favourites list displays all added red books.
    [Tags]    req-DEV-165    type-ok
    I am a logged-in user
    I navigate to my favourites list
    I should see all the red books I have added

View favourites list - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed if the system encounters an error while viewing the favourites list.
    [Tags]    req-DEV-165    type-nok
    I am a logged-in user
    I navigate to my favourites list
    The system encounters an error
    I should see an error message

Add a favourite book to shopping cart - successful scenario
    [Documentation]    Verify that a favourite book can be successfully added to the shopping cart.
    [Tags]    req-DEV-165    type-ok
    I am a logged-in user
    I have a red book in my favourites list
    I click on 'Add to Cart' for that book
    The book should be added to my shopping cart
    I should see a confirmation message

Add a favourite book to shopping cart - unsuccessful scenario
    [Documentation]    Verify that a favourite book cannot be added to the shopping cart if the system encounters an error.
    [Tags]    req-DEV-165    type-nok
    I am a logged-in user
    I have a red book in my favourites list
    I click on 'Add to Cart' for that book
    The system encounters an error
    The book should not be added to my shopping cart
    I should see an error message

*** Keywords ***
I am a logged-in user
    Browser.New Context
    Browser.New Page    ${URL}
    Browser.Fill Text    username    ${USERNAME}
    Browser.Fill Text    password    ${PASSWORD}
    Browser.Click    login

I am viewing a red book
    Browser.Click    text=red book

I click on 'Add to Favourites'
    Browser.Click    text=add to favourites

The book should be added to my favourites list
    Browser.Wait For Elements State    text=favourites list    visible
    Browser.Get Text    text=favourites list    ==    red book

I should see a confirmation message
    Browser.Wait For Elements State    text=confirmation message    visible

The system encounters an error
    # Simulate an error condition
    Browser.Evaluate JavaScript    window.simulateError()

The book should not be added to my favourites list
    Browser.Get Text    text=favourites list    !=    red book

I should see an error message
    Browser.Wait For Elements State    text=error message    visible

I navigate to my favourites list
    Browser.Click    text=favourites list

I should see all the red books I have added
    Browser.Get Text    text=favourites list    ==    red book

I have a red book in my favourites list
    I am a logged-in user
    I am viewing a red book
    I click on 'Add to Favourites'
    The book should be added to my favourites list
    I should see a confirmation message

I click on 'Add to Cart' for that book
    Browser.Click    text=add to cart

The book should be added to my shopping cart
    Browser.Wait For Elements State    text=shopping cart    visible
    Browser.Get Text    text=shopping cart    ==    red book
