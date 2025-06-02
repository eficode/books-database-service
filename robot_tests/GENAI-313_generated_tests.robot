*** Settings ***
Documentation    This test suite verifies the functionality of uploading and displaying cover pictures for books in the book service.
Library          Browser

*** Variables ***
${BOOK_SERVICE_URL}    http://example.com/books
${ADMIN_USERNAME}      admin
${ADMIN_PASSWORD}      password
${SUPPORTED_IMAGE}     path/to/supported_image.jpg
${UNSUPPORTED_IMAGE}   path/to/unsupported_image.txt
${PLACEHOLDER_IMAGE}   path/to/placeholder_image.jpg

*** Test Cases ***
Admin Uploads Cover Picture Successfully
    [Documentation]    Verify that an admin can successfully upload a cover picture for a book.
    [Tags]    req-GENAI-306    type-ok
    I am an admin of the books service
    upload a cover picture for a book
    cover picture should be saved and associated with the book
    cover picture should be displayed when users view the book details

Admin Uploads Unsupported Cover Picture
    [Documentation]    Verify that an admin cannot upload a cover picture with an unsupported file type.
    [Tags]    req-GENAI-306    type-nok
    I am an admin of the books service
    upload a cover picture for a book with an unsupported file type
    cover picture should not be saved
    error message should be displayed indicating the unsupported file type

User Views Book With Cover Picture
    [Documentation]    Verify that a user can view a book with a cover picture.
    [Tags]    req-GENAI-306    type-ok
    book has a cover picture
    user views the book details
    cover picture should be displayed

User Views Book With Missing Cover Picture
    [Documentation]    Verify that a placeholder image is displayed when the cover picture is missing.
    [Tags]    req-GENAI-306    type-nok
    book has a cover picture
    cover picture is missing
    user views the book details
    placeholder image should be displayed instead of the cover picture

*** Keywords ***
I am an admin of the books service
    New Browser    chromium
    New Page    ${BOOK_SERVICE_URL}
    Get Element    [name="username"]
    Input Text    [name="username"]    ${ADMIN_USERNAME}
    Get Element    [name="password"]
    Input Text    [name="password"]    ${ADMIN_PASSWORD}
    Get Element    [name="login"]
    Click    [name="login"]
    Wait For Elements State    [name="admin-dashboard"]    visible

upload a cover picture for a book
    Click    [name="upload-cover"]
    Set Input Files    [name="file-upload"]    ${SUPPORTED_IMAGE}
    Click    [name="submit-upload"]
    Wait For Elements State    [name="upload-success"]    visible

upload a cover picture for a book with an unsupported file type
    Click    [name="upload-cover"]
    Set Input Files    [name="file-upload"]    ${UNSUPPORTED_IMAGE}
    Click    [name="submit-upload"]
    Wait For Elements State    [name="upload-error"]    visible

cover picture should be saved and associated with the book
    Wait For Elements State    [name="cover-image"]    visible

cover picture should be displayed when users view the book details
    New Page    ${BOOK_SERVICE_URL}/book/1
    Wait For Elements State    [name="cover-image"]    visible

cover picture should not be saved
    Wait For Elements State    [name="cover-image"]    hidden

error message should be displayed indicating the unsupported file type
    Wait For Elements State    [name="upload-error"]    visible

book has a cover picture
    New Page    ${BOOK_SERVICE_URL}/book/1
    Wait For Elements State    [name="cover-image"]    visible

user views the book details
    New Page    ${BOOK_SERVICE_URL}/book/1

placeholder image should be displayed instead of the cover picture
    Wait For Elements State    [name="placeholder-image"]    visible
