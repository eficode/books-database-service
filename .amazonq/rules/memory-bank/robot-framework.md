# Robot Framework Testing Standards

## Core Principles

### Test Style
- **Use Gherkin/ATDD style in test cases**: Given/When/Then/And
- **Never use Gherkin in keywords**: Keywords are reusable building blocks
- **Use "User" instead of "I"**: "User can log in" not "I can log in"
- **Behavior-focused test names**: Describe what the user can do

### Section Order
Always follow this order in Robot files:
1. `*** Settings ***`
2. `*** Variables ***`
3. `*** Test Cases ***`
4. `*** Keywords ***`

## Formatting Standards

### Line Length
- Keep lines ≤ 120 characters
- Use continuation (`...`) for long lines:
```robot
Long Keyword With Many Arguments
    [Arguments]    ${arg1}    ${arg2}    ${arg3}    ${arg4}
    ...            ${arg5}    ${arg6}
    Should Be Equal    ${arg1}    ${expected_value}
    ...    msg=Expected ${expected_value} but got ${arg1}
```

### Naming Conventions

**Test Case Names:**
- Sentence case
- Behavior-focused
- Describe user capability
```robot
*** Test Cases ***
User can log in with valid credentials
User can add a new book to the library
User can filter books by category
```

**Keyword Names:**
- Title Case With Spaces
- Action-oriented
- Clear and descriptive
```robot
*** Keywords ***
Open Browser To Login Page
Fill Login Form With Valid Credentials
Verify Dashboard Is Displayed
```

**Variables:**
- Constants: `ALL_CAPS`
- Regular variables: `camelCase` or `snake_case` (be consistent)
```robot
*** Variables ***
${BASE_URL}           http://localhost:8000
${BROWSER}            chromium
${TIMEOUT}            10s
${userName}           testuser
${user_email}         test@example.com
```

**Tags:**
- All lowercase
- Short and descriptive
- Use hyphens for multi-word tags
```robot
[Tags]    smoke    api    slow-network    crud-operations
```

## Settings Section

### Library Imports
```robot
*** Settings ***
Library          Browser    timeout=10s    run_on_failure=None
Library          RequestsLibrary
Library          Collections
Library          String
```

### Resource Imports
```robot
Resource         ../resources/Common.robot
Resource         ../resources/ui_keywords.resource
Resource         ../resources/api_keywords.resource
```

### Suite Setup/Teardown
```robot
Suite Setup      Open Books Application
Suite Teardown   Close Books Application
Test Setup       Reset Test Data
Test Teardown    Capture Screenshot On Failure
```

### Documentation
- One or two sentences describing suite intent
```robot
Documentation    UI acceptance tests for Books Database Service.
...              Tests cover CRUD operations, search, and filtering.
```

### Test Tags
```robot
Test Tags        ui    acceptance
```

## Variables Section

### Centralize Configuration
```robot
*** Variables ***
# Environment
${BASE_URL}              http://localhost:8000
${API_BASE_URL}          ${BASE_URL}/api

# Browser Settings
${BROWSER}               chromium
${HEADLESS}              ${True}
${TIMEOUT}               10s

# Locators - Named by widget role
${LOGIN_BUTTON}          css=#login-btn
${USERNAME_INPUT}        css=#username
${PASSWORD_INPUT}        css=#password
${DASHBOARD_HEADER}      xpath=//h1[text()='Dashboard']
${BOOK_CARD}             css=.book-card
${ADD_BOOK_FORM}         css=#book-form
```

## Test Cases Section

### Gherkin/ATDD Style
```robot
*** Test Cases ***
User can add a new book
    [Documentation]    Verify that user can successfully add a new book through the UI
    [Tags]    create    smoke
    Given user is on the books application homepage
    When user fills in the book form with title "1984" author "George Orwell" pages "328"
    And user submits the book form
    Then the book "1984" should appear in the books list

User can search for books by title
    [Documentation]    Verify that user can search for books using the search field
    [Tags]    search
    Given user is on the books application homepage
    And multiple books exist in the database
    When user searches for "Tolkien"
    Then only books matching "Tolkien" should be displayed
```

### Test Documentation
- Use `[Documentation]` tag for test intent
- Or use `Comment` as first step
```robot
User can delete a book
    Comment    This test verifies the complete delete workflow including confirmation
    [Tags]    delete
    Given user is on the books application homepage
    ...
```

## Keywords Section

### No Gherkin in Keywords
```robot
*** Keywords ***
# CORRECT - No Gherkin
Open Books Application
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Page    ${BASE_URL}
    Wait For Elements State    css=h1    visible    timeout=${TIMEOUT}

Fill Book Form
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    Fill Text    ${TITLE_INPUT}    ${title}
    Fill Text    ${AUTHOR_INPUT}    ${author}
    Fill Text    ${PAGES_INPUT}    ${pages}
    Select Options By    ${CATEGORY_SELECT}    value    ${category}

# INCORRECT - Don't use Gherkin
Given User Is On Homepage
    # Wrong - don't use Given/When/Then in keywords
```

### Keyword Documentation
```robot
Create Book Via API
    [Documentation]    Creates a new book using the REST API
    ...                Returns the created book object with ID
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    ${body}=    Create Dictionary    title=${title}    author=${author}
    ...         pages=${pages}    category=${category}
    ${response}=    POST On Session    books_api    /books/    json=${body}
    RETURN    ${response.json()}
```

### Avoid Run Keywords Chains
```robot
# INCORRECT - Hard to read
Run Keywords
    Open Browser    ${URL}    chrome
    AND    Maximize Browser Window
    AND    Set Selenium Speed    0.5s

# CORRECT - Create higher-level keyword
Open Browser To Application
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Set Selenium Speed    0.5s
```

### Control Structures

**FOR Loops:**
```robot
Verify All Books Have Required Fields
    ${books}=    Get All Books Via API
    FOR    ${book}    IN    @{books}
        Should Not Be Empty    ${book}[title]    msg=Book missing title
        Should Not Be Empty    ${book}[author]    msg=Book missing author
        Should Be True    ${book}[pages] > 0    msg=Invalid page count
    END
```

**IF Blocks:**
```robot
Click Edit Button For Book
    [Arguments]    ${title}
    ${book_exists}=    Run Keyword And Return Status
    ...                Get Element    xpath=//h3[text()='${title}']
    IF    ${book_exists}
        Click    xpath=//h3[text()='${title}']/ancestor::div//button[@class='edit-btn']
    ELSE
        Fail    Book "${title}" not found in the list
    END
```

## Error Handling and Assertions

### Helpful Error Messages
```robot
# INCORRECT - No context
Should Be Equal    ${actual}    ${expected}

# CORRECT - Clear error message
Should Be Equal    ${actual}    ${expected}
...    msg=Expected status to be ${expected}, but got ${actual}

Should Be True    ${book_count} > 0
...    msg=No books found in the database. Expected at least 1 book.

Should Contain    ${response.json()}    id
...    msg=API response missing 'id' field. Response: ${response.json()}
```

### Capture Context on Failure
```robot
Verify Book Details
    [Arguments]    ${book_id}    ${expected_title}
    ${book}=    Get Book By ID Via API    ${book_id}
    Should Be Equal    ${book}[title]    ${expected_title}
    ...    msg=Book ${book_id} has wrong title. Expected: ${expected_title}, Got: ${book}[title]
```

## Best Practices

### Locator Management
```robot
*** Variables ***
# Centralize locators with descriptive names
${SEARCH_INPUT}          css=#search-input
${SEARCH_BUTTON}         css=#search-btn
${BOOK_TITLE}            css=.book-title
${EDIT_BUTTON}           css=.edit-btn
${DELETE_BUTTON}         css=.delete-btn
${FAVORITE_BUTTON}       css=.favorite-btn
```

### Resource File Organization
```robot
# resources/common.resource
*** Settings ***
Library          Browser
Library          RequestsLibrary

*** Variables ***
${BASE_URL}      http://localhost:8000
${TIMEOUT}       10s

*** Keywords ***
Wait For Response
    Sleep    1s

# resources/ui_keywords.resource
*** Settings ***
Resource         common.resource

*** Keywords ***
Open Books Application
    ...

# resources/api_keywords.resource
*** Settings ***
Resource         common.resource

*** Keywords ***
Create API Session
    ...
```

### Custom Python Libraries
```python
# libs/BookHelpers.py
class BookHelpers:
    """Custom library for book-related helper functions"""
    
    def generate_random_book_data(self):
        """Generate random book data for testing"""
        import random
        titles = ["Book One", "Book Two", "Book Three"]
        authors = ["Author A", "Author B", "Author C"]
        return {
            'title': random.choice(titles),
            'author': random.choice(authors),
            'pages': random.randint(100, 500)
        }
```

```robot
*** Settings ***
Library          libs/BookHelpers.py

*** Test Cases ***
User can add random book
    ${book_data}=    Generate Random Book Data
    Fill Book Form    ${book_data}[title]    ${book_data}[author]    ${book_data}[pages]
```

### Avoid Commented-Out Code
```robot
# INCORRECT - Don't leave commented code
# Click    css=#old-button
# Sleep    5s
Click    css=#new-button

# CORRECT - Remove unused code or use Comment for explanation
Comment    Using new button selector after UI redesign
Click    css=#new-button
```

### Use Comment for Explanations
```robot
*** Test Cases ***
User can complete checkout process
    Comment    This test requires payment gateway to be in test mode
    Comment    Test credit card: 4111111111111111
    Given user has items in cart
    When user proceeds to checkout
    And user enters payment details
    Then order should be confirmed
```

## Complete Example

```robot
*** Settings ***
Documentation    UI acceptance tests for Books Database Service.
...              Tests cover CRUD operations, search, and filtering functionality.
Library          Browser    timeout=10s    run_on_failure=None
Library          RequestsLibrary
Resource         resources/common.resource
Resource         resources/ui_keywords.resource
Suite Setup      Open Books Application
Suite Teardown   Close Books Application
Test Tags        ui    acceptance

*** Variables ***
${BASE_URL}              http://localhost:8000
${BROWSER}               chromium
${HEADLESS}              ${True}
${TIMEOUT}               10s
${BOOK_CARD}             css=.book-card
${SEARCH_INPUT}          css=#search-input

*** Test Cases ***
User can add a new book
    [Documentation]    Verify that user can successfully add a new book through the UI
    [Tags]    create    smoke
    Given user is on the books application homepage
    When user fills in the book form with title "The Great Gatsby"
    ...      author "F. Scott Fitzgerald" pages "180" category "Fiction"
    And user submits the book form
    Then the book "The Great Gatsby" should appear in the books list

User can search for books
    [Documentation]    Verify that user can search for books by title or author
    [Tags]    search
    Given user is on the books application homepage
    And multiple books exist in the database
    When user searches for "Tolkien"
    Then only books matching "Tolkien" should be displayed
    And the books count should be updated

User can delete a book
    [Documentation]    Verify that user can delete a book with confirmation
    [Tags]    delete
    Given user is on the books application homepage
    And a book "Test Book" by "Test Author" exists
    When user clicks delete button for book "Test Book"
    And user confirms the deletion
    Then the book "Test Book" should not be visible

*** Keywords ***
User Is On The Books Application Homepage
    Wait For Elements State    css=h1    visible    timeout=${TIMEOUT}

User Fills In The Book Form With Title "${title}" Author "${author}" Pages "${pages}" Category "${category}"
    Fill Book Form    ${title}    ${author}    ${pages}    ${category}

User Submits The Book Form
    Submit Book Form

The Book "${title}" Should Appear In The Books List
    Book Should Be Visible In List    ${title}

Fill Book Form
    [Documentation]    Fill the book creation form with provided data
    [Arguments]    ${title}    ${author}    ${pages}    ${category}=Fiction
    Fill Text    css=#title    ${title}
    Fill Text    css=#author    ${author}
    Fill Text    css=#pages    ${pages}
    Select Options By    css=#category    value    ${category}

Submit Book Form
    [Documentation]    Submit the book form and wait for response
    Click    css=#book-form button[type="submit"]
    Sleep    2s

Book Should Be Visible In List
    [Documentation]    Verify that a book with given title is visible in the list
    [Arguments]    ${title}
    Wait For Elements State    ${BOOK_CARD} >> nth=0    visible    timeout=${TIMEOUT}
    ${element_exists}=    Run Keyword And Return Status
    ...                   Get Element    xpath=//h3[contains(@class, 'book-title') and text()='${title}']
    Should Be True    ${element_exists}
    ...    msg=Book "${title}" not found in the books list
```

## Anti-Patterns to Avoid

### Don't Mix Gherkin in Keywords
```robot
# WRONG
*** Keywords ***
Given User Is Logged In
    Open Browser    ${URL}
    Input Text    ${USERNAME}    admin

# RIGHT
*** Keywords ***
Log In As Admin
    Open Browser    ${URL}
    Input Text    ${USERNAME}    admin
```

### Don't Use "I" - Use "User"
```robot
# WRONG
I can add a book
    Given I am on the homepage
    When I fill the form

# RIGHT
User can add a book
    Given user is on the homepage
    When user fills the form
```

### Don't Chain Run Keywords
```robot
# WRONG
Run Keywords    Open Browser    ${URL}    AND    Login    admin    pass123

# RIGHT
Open Browser And Login As Admin
    Open Browser    ${URL}
    Login    admin    pass123
```

### Don't Leave Magic Numbers
```robot
# WRONG
Sleep    5s
Wait Until Element Is Visible    ${BUTTON}    30s

# RIGHT
Sleep    ${SHORT_WAIT}
Wait Until Element Is Visible    ${BUTTON}    timeout=${TIMEOUT}
```
