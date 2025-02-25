*** Settings ***
Documentation     Tests for responsive behavior and edge cases
Resource          resources/common.resource
Suite Setup       Setup Test Environment
Suite Teardown    Teardown Test Environment
Test Tags         ui    browser    responsive

*** Variables ***
${VERY_LONG_TITLE}    ${"A" * 100} Very Long Book Title That Might Break Layout
${LONG_AUTHOR}        ${"X" * 100} Author With Extremely Long Name
${MAX_INT_PAGES}      2147483647
${SPECIAL_CHARS}      !@#$%^&*()_+{}|:"<>?[];',./

*** Test Cases ***
Application Handles Mobile View
    [Documentation]    Test that the UI is responsive on mobile devices
    [Tags]             responsive
    # Set viewport to mobile size
    Set Viewport Size    375    812    # iPhone X dimensions
    
    # Check if the UI adapts correctly
    Wait For Elements State    h1:has-text("Books Library")    visible
    
    # Add a book in mobile view to verify form works
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    Add New Book    ${title}    ${author}    ${pages}    ${category}
    Book Should Exist    ${title}
    
    # Reset to desktop view
    Set Viewport Size    1280    800

Application Handles Very Long Text
    [Documentation]    Test that the UI can handle extremely long text inputs
    [Tags]             edge-case
    
    # Add book with very long title and author
    Add New Book    ${VERY_LONG_TITLE}    ${LONG_AUTHOR}    ${MAX_INT_PAGES}    Fiction
    
    # Verify the book was added successfully
    Book Should Exist    ${VERY_LONG_TITLE}
    
    # Verify the long text displays reasonably in the UI (doesn't break layout)
    # Note: This is a visual check, we just verify elements remain visible
    Wait For Elements State    .book-card:has(.book-title:has-text("Very Long Book Title"))    visible
    Wait For Elements State    .book-card:has(.book-author:has-text("Author With Extremely"))    visible

Application Handles Special Characters
    [Documentation]    Test that the UI can handle special characters in input
    [Tags]             edge-case
    
    ${special_title}=    Set Variable    Special ${SPECIAL_CHARS} Title
    ${special_author}=    Set Variable    Special ${SPECIAL_CHARS} Author
    
    # Add book with special characters
    Add New Book    ${special_title}    ${special_author}    100    Fiction
    
    # Verify the book was added successfully
    Book Should Exist    ${special_title}

Form Validation Works
    [Documentation]    Test that the form validation prevents invalid submissions
    [Tags]             validation
    
    # Try to submit with empty fields
    Click    button:has-text("Add Book")
    
    # Verify validation prevents submission
    # HTML5 validation will show the browser's native validation message
    # This is difficult to catch with Browser library, so we check the form is still there
    Wait For Elements State    #book-form    visible
    
    # Try negative number of pages
    Fill Text    id=title    Test Book
    Fill Text    id=author    Test Author
    Fill Text    id=pages    -100
    Select Options By    id=category    text    Fiction
    Click    button:has-text("Add Book")
    
    # HTML5 validation should prevent submission
    # Verify no success notification
    Wait For Elements State    .notification.success    hidden    timeout=3s    state=detached
    
    # Try valid form submission
    Fill Text    id=pages    100
    Click    button:has-text("Add Book")
    Wait For Elements State    .notification.success    visible

Searching Handles Edge Cases
    [Documentation]    Test search edge cases
    [Tags]             search    edge-case
    
    # Search with special characters
    Search For Book    ${SPECIAL_CHARS}
    
    # Search with very long query
    Search For Book    ${"A" * 200}
    
    # Search with empty query
    Search For Book    ${EMPTY}
    
    # Verify search functionality still works after edge cases
    ${title}    ${author}    ${pages}    ${category}=    Generate Random Book Data
    Add New Book    ${title}    ${author}    ${pages}    ${category}
    Search For Book    ${title}
    Book Should Exist    ${title}