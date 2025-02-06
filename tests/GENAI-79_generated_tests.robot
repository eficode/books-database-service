*** Settings ***
Documentation    This test suite verifies the functionality of adding books to the shopping cart and viewing the shopping cart in the BookBridge application.
Library          Browser

*** Variables ***
${BOOK_TITLE}    The Great Gatsby
${BOOK_PRICE}    $10.99
${OUT_OF_STOCK_MESSAGE}    This book is out of stock
${EMPTY_CART_MESSAGE}    Your shopping cart is empty

*** Test Cases ***
Add a single book to the shopping cart - successful scenario
    [Documentation]    Verify that a book can be successfully added to the shopping cart.
    [Tags]    req-GENAI-77    type-ok
    Given I am a logged-in BookBridge end customer
    When I select a book to add to my shopping cart
    Then the book should be added to my shopping cart
    And I should see the book's title and price in the shopping cart

Add a single book to the shopping cart - unsuccessful scenario
    [Documentation]    Verify that a book cannot be added to the shopping cart if it is out of stock.
    [Tags]    req-GENAI-77    type-nok
    Given I am a logged-in BookBridge end customer
    When I select a book to add to my shopping cart
    And the book is out of stock
    Then the book should not be added to my shopping cart
    And I should see an out-of-stock message

View shopping cart - successful scenario
    [Documentation]    Verify that the shopping cart displays all added books with their titles and prices.
    [Tags]    req-GENAI-77    type-ok
    Given I have added books to my shopping cart
    When I view my shopping cart
    Then I should see a list of all books in my cart along with their titles and prices

View shopping cart - unsuccessful scenario
    [Documentation]    Verify that the shopping cart displays a message indicating it is empty when no books are added.
    [Tags]    req-GENAI-77    type-nok
    Given I have not added any books to my shopping cart
    When I view my shopping cart
    Then I should see a message indicating that my shopping cart is empty

*** Keywords ***
I am a logged-in BookBridge end customer
    New Browser    chromium
    New Page    http://bookbridge.com
    Click    text=Login
    Fill Text    id=username    user
    Fill Text    id=password    pass
    Click    text=Submit
    Wait For Elements State    text=Logout    visible

I select a book to add to my shopping cart
    Click    text=${BOOK_TITLE}
    Click    text=Add to Cart

The book should be added to my shopping cart
    Wait For Elements State    text=${BOOK_TITLE}    visible
    Wait For Elements State    text=${BOOK_PRICE}    visible

I should see the book's title and price in the shopping cart
    Click    text=Shopping Cart
    Wait For Elements State    text=${BOOK_TITLE}    visible
    Wait For Elements State    text=${BOOK_PRICE}    visible

The book is out of stock
    Click    text=${BOOK_TITLE}
    Wait For Elements State    text=${OUT_OF_STOCK_MESSAGE}    visible

The book should not be added to my shopping cart
    Click    text=Shopping Cart
    Wait For Elements State    text=${BOOK_TITLE}    hidden

I should see an out-of-stock message
    Wait For Elements State    text=${OUT_OF_STOCK_MESSAGE}    visible

I have added books to my shopping cart
    I am a logged-in BookBridge end customer
    I select a book to add to my shopping cart

I view my shopping cart
    Click    text=Shopping Cart

I should see a list of all books in my cart along with their titles and prices
    Wait For Elements State    text=${BOOK_TITLE}    visible
    Wait For Elements State    text=${BOOK_PRICE}    visible

I have not added any books to my shopping cart
    I am a logged-in BookBridge end customer

I should see a message indicating that my shopping cart is empty
    Click    text=Shopping Cart
    Wait For Elements State    text=${EMPTY_CART_MESSAGE}    visible
