*** Settings ***
Documentation    This test suite verifies the functionality of viewing and purchasing favourite books.
Library          Browser

*** Variables ***
${BASE_URL}      http://example.com
${USERNAME}      user
${PASSWORD}      pass
${INVALID_CC}    1234 5678 9012 3456

*** Test Cases ***
View list of favourite books - successful scenario
    [Documentation]    Verify that a logged-in user can view their list of favourite books.
    [Tags]    req-GENAI-237    type-ok
    I am a logged-in user
    I navigate to my favourites section
    I should see a list of books I have tagged as favourites

View list of favourite books with no favourites - unsuccessful scenario
    [Documentation]    Verify that a logged-in user sees a message when they have no favourite books.
    [Tags]    req-GENAI-237    type-nok
    I am a logged-in user
    I have not tagged any book to be my favorite
    I navigate to my favourites section
    I should see a message indicating that I have no favourite books

Purchase a favourite book - successful scenario
    [Documentation]    Verify that a user can purchase a favourite book and trigger payment process with a credit card.
    [Tags]    req-GENAI-237    type-ok
    I am viewing my list of favourite books
    I select a book to purchase
    I should be taken to the purchase page for that book
    I should be able to trigger payment process with credit card

Purchase a favourite book with invalid credit card - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when a user tries to purchase a book with an invalid credit card.
    [Tags]    req-GENAI-237    type-nok
    I am viewing my list of favourite books
    I select a book to purchase
    I enter an invalid credit card
    I should see an error message indicating the payment could not be processed

*** Keywords ***
I am a logged-in user
    New Page    ${BASE_URL}
    Click    text=Login
    Fill Text    username    ${USERNAME}
    Fill Text    password    ${PASSWORD}
    Click    text=Submit

I navigate to my favourites section
    Click    text=Favourites

I should see a list of books I have tagged as favourites
    Wait For Elements State    css=.favourite-book    visible

I have not tagged any book to be my favorite
    # This step assumes precondition setup in the system, no action needed in the test.
    No Operation

I should see a message indicating that I have no favourite books
    Wait For Elements State    text=You have no favourite books    visible

I am viewing my list of favourite books
    I am a logged-in user
    I navigate to my favourites section

I select a book to purchase
    Click    css=.favourite-book:first-child
    Click    text=Purchase

I should be taken to the purchase page for that book
    Wait For Elements State    css=.purchase-page    visible

I should be able to trigger payment process with credit card
    Fill Text    credit-card-number    4111 1111 1111 1111
    Click    text=Pay
    Wait For Elements State    text=Payment Successful    visible

I enter an invalid credit card
    Fill Text    credit-card-number    ${INVALID_CC}
    Click    text=Pay

I should see an error message indicating the payment could not be processed
    Wait For Elements State    text=Payment could not be processed    visible
