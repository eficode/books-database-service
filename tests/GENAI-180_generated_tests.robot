*** Settings ***
Documentation    This test suite verifies the functionality of adding and displaying categories in a bookstore application.
Library          Browser

*** Variables ***
${URL}           http://bookstore.example.com

*** Test Cases ***
Add new category - successful scenario
    [Documentation]    Verify that a bookstore manager can successfully add a new category 'Finnish mythology'.
    [Tags]    req-GENAI-179    type-ok
    I am a bookstore manager
    add a new category 'Finnish mythology'
    category should be available in the bookstore's category list
    customers should be able to see and select 'Finnish mythology' as a category

Add new category with invalid name - unsuccessful scenario
    [Documentation]    Verify that adding a new category with an invalid name is not allowed.
    [Tags]    req-GENAI-179    type-nok
    I am a bookstore manager
    add a new category ''
    category should not be available in the bookstore's category list
    customers should not be able to see and select '' as a category

Display books under 'Finnish mythology' - successful scenario
    [Documentation]    Verify that books under 'Finnish mythology' category are displayed correctly.
    [Tags]    req-GENAI-179    type-ok
    'Finnish mythology' category is added
    customers select 'Finnish mythology' category
    should see a list of books related to Finnish mythology

Display books under 'Finnish mythology' with no books available - unsuccessful scenario
    [Documentation]    Verify that a message is displayed when no books are available under 'Finnish mythology' category.
    [Tags]    req-GENAI-179    type-nok
    'Finnish mythology' category is added
    customers select 'Finnish mythology' category
    should see a message indicating no books are available in this category

*** Keywords ***
I am a bookstore manager
    New Browser    chromium
    New Page    ${URL}
    Click    text=Login
    Fill Text    input[name="username"]    manager
    Fill Text    input[name="password"]    password
    Click    text=Submit

add a new category 'Finnish mythology'
    Click    text=Add Category
    Fill Text    input[name="category_name"]    Finnish mythology
    Click    text=Save

add a new category ''
    Click    text=Add Category
    Fill Text    input[name="category_name"]    
    Click    text=Save

category should be available in the bookstore's category list
    ${TEXT}=    Get Text    text=Category List
    Should Contain    ${TEXT}    Finnish mythology

category should not be available in the bookstore's category list
    ${TEXT}=    Get Text    text=Category List
    Should Not Contain    ${TEXT}    

customers should be able to see and select 'Finnish mythology' as a category
    Click    text=Categories
    ${TEXT}=    Get Text    text=Category List
    Should Contain    ${TEXT}    Finnish mythology

customers should not be able to see and select '' as a category
    Click    text=Categories
    ${TEXT}=    Get Text    text=Category List
    Should Not Contain    ${TEXT}    

'Finnish mythology' category is added
    Click    text=Add Category
    Fill Text    input[name="category_name"]    Finnish mythology
    Click    text=Save

customers select 'Finnish mythology' category
    Click    text=Categories
    Click    text=Finnish mythology

should see a list of books related to Finnish mythology
    ${TEXT}=    Get Text    text=Book List
    Should Contain    ${TEXT}    Finnish mythology

should see a message indicating no books are available in this category
    ${TEXT}=    Get Text    text=No Books Available
    Should Be Equal    ${TEXT}    No books are available in this category
