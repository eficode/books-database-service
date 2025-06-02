*** Settings ***
Documentation    This test suite verifies the functionality of uploading, viewing, updating, and removing book covers in the system.
Library          Browser

*** Variables ***
${BOOK_URL}      http://example.com/book
${UPLOAD_URL}    http://example.com/upload
${REMOVE_URL}    http://example.com/remove
${VIEW_URL}      http://example.com/view
${SUPPORTED_FORMAT}    image/jpeg
${UNSUPPORTED_FORMAT}  image/tiff
${EXCEED_SIZE}  10MB

*** Test Cases ***
Upload Book Cover - Successful Scenario
    [Documentation]    Verify that a book cover can be successfully uploaded and associated with the book.
    [Tags]    req-GENAI-317    type-ok
    Given I have a book in the system
    When I upload a book cover image
    Then the book cover should be associated with the book
    And the book cover should be displayed when viewing the book details

Upload Book Cover - Unsuccessful Scenario
    [Documentation]    Verify that an unsupported book cover image format is not accepted.
    [Tags]    req-GENAI-317    type-nok
    Given I have a book in the system
    When I upload a book cover image
    And the image format is not supported
    Then the book cover should not be associated with the book
    And an error message should be displayed

View Book Cover - Successful Scenario
    [Documentation]    Verify that the book cover image is displayed when viewing book details.
    [Tags]    req-GENAI-317    type-ok
    Given a book has a cover image
    When I view the book details
    Then I should see the book cover image

View Book Cover - Unsuccessful Scenario
    [Documentation]    Verify that an error message is displayed when the image storage service is down.
    [Tags]    req-GENAI-317    type-nok
    Given a book has a cover image
    When I view the book details
    And the image storage service is down
    Then I should not see the book cover image
    And an error message should be displayed

Update Book Cover - Successful Scenario
    [Documentation]    Verify that a new book cover image replaces the old one.
    [Tags]    req-GENAI-317    type-ok
    Given a book has an existing cover image
    When I upload a new book cover image
    Then the new book cover should replace the old one
    And the new book cover should be displayed when viewing the book details

Update Book Cover - Unsuccessful Scenario
    [Documentation]    Verify that an oversized book cover image is not accepted.
    [Tags]    req-GENAI-317    type-nok
    Given a book has an existing cover image
    When I upload a new book cover image
    And the image size exceeds the limit
    Then the new book cover should not replace the old one
    And an error message should be displayed

Remove Book Cover - Successful Scenario
    [Documentation]    Verify that a book cover can be successfully removed.
    [Tags]    req-GENAI-317    type-ok
    Given a book has a cover image
    When I remove the book cover
    Then the book cover should no longer be associated with the book
    And the book cover should not be displayed when viewing the book details

Remove Book Cover - Unsuccessful Scenario
    [Documentation]    Verify that an error message is displayed when the image storage service is down.
    [Tags]    req-GENAI-317    type-nok
    Given a book has a cover image
    When I remove the book cover
    And the image storage service is down
    Then the book cover should still be associated with the book
    And an error message should be displayed

*** Keywords ***
I have a book in the system
    New Browser    chromium
    New Page    ${BOOK_URL}
    Wait For Elements State    Book Details    visible

I upload a book cover image
    Click    //input[@type='file']
    Upload File    //input[@type='file']    ${UPLOAD_URL}
    Click    //button[@id='upload']

The book cover should be associated with the book
    Wait For Elements State    Upload Successful    visible

The book cover should be displayed when viewing the book details
    Go To    ${VIEW_URL}
    Wait For Elements State    //img[@id='book-cover']    visible

The image format is not supported
    Set Variable    ${UPLOAD_URL}    ${UNSUPPORTED_FORMAT}

An error message should be displayed
    Wait For Elements State    Error: Unsupported Format    visible

A book has a cover image
    New Browser    chromium
    New Page    ${VIEW_URL}
    Wait For Elements State    //img[@id='book-cover']    visible

I view the book details
    Go To    ${VIEW_URL}

I should see the book cover image
    Wait For Elements State    //img[@id='book-cover']    visible

The image storage service is down
    Set Variable    ${VIEW_URL}    http://example.com/view?service=down

I upload a new book cover image
    Click    //input[@type='file']
    Upload File    //input[@type='file']    ${UPLOAD_URL}
    Click    //button[@id='upload']

The new book cover should replace the old one
    Wait For Elements State    Upload Successful    visible

The image size exceeds the limit
    Set Variable    ${UPLOAD_URL}    ${EXCEED_SIZE}

I remove the book cover
    Go To    ${REMOVE_URL}
    Click    //button[@id='remove']

The book cover should no longer be associated with the book
    Wait For Elements State    Removal Successful    visible

The book cover should not be displayed when viewing the book details
    Go To    ${VIEW_URL}
    Wait For Elements State    //img[@id='book-cover']    hidden

The book cover should still be associated with the book
    Wait For Elements State    //img[@id='book-cover']    visible
