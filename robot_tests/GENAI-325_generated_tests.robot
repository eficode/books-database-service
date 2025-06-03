*** Settings ***
Library    Browser

Documentation    This test suite verifies the functionality of uploading and replacing book cover images in the book management section.

*** Variables ***
${ADMIN_USERNAME}    admin
${ADMIN_PASSWORD}    password
${BOOK_MANAGEMENT_URL}    http://example.com/book-management
${SUPPORTED_IMAGE}    path/to/supported_image.jpg
${UNSUPPORTED_IMAGE}    path/to/unsupported_image.txt
${LARGE_IMAGE}    path/to/large_image.jpg

*** Test Cases ***
Upload a new book cover image - successful scenario
    [Documentation]    Verify that a new book cover image can be successfully uploaded and displayed.
    [Tags]    req-GENAI-323    type-ok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image
    new cover image should be saved and displayed for that book

Upload a new book cover image with unsupported file type - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when uploading an unsupported file type as a book cover image.
    [Tags]    req-GENAI-323    type-nok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image with an unsupported file type
    error message should be displayed indicating the file type is not supported

Replace an existing book cover image - successful scenario
    [Documentation]    Verify that an existing book cover image can be successfully replaced and displayed.
    [Tags]    req-GENAI-323    type-ok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image
    new cover image should replace the existing one and be displayed for that book

Replace an existing book cover image with a file exceeding size limit - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when uploading a book cover image that exceeds the size limit.
    [Tags]    req-GENAI-323    type-nok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image that exceeds the size limit
    error message should be displayed indicating the file size is too large

*** Keywords ***
I am an admin
    New Page    ${BOOK_MANAGEMENT_URL}
    Fill Text    username    ${ADMIN_USERNAME}
    Fill Text    password    ${ADMIN_PASSWORD}
    Click    login-button

navigate to the book management section
    Click    book-management-link

select a book to edit
    Click    first-book-edit-button

upload a new cover image
    Browser.Upload File    cover-image-input    ${SUPPORTED_IMAGE}
    Click    save-button

upload a new cover image with an unsupported file type
    Browser.Upload File    cover-image-input    ${UNSUPPORTED_IMAGE}
    Click    save-button

upload a new cover image that exceeds the size limit
    Browser.Upload File    cover-image-input    ${LARGE_IMAGE}
    Click    save-button

new cover image should be saved and displayed for that book
    Browser.Wait For Elements State    cover-image    visible
    Element Attribute Value Should Be    cover-image    src    ${SUPPORTED_IMAGE}

new cover image should replace the existing one and be displayed for that book
    Browser.Wait For Elements State    cover-image    visible
    Element Attribute Value Should Be    cover-image    src    ${SUPPORTED_IMAGE}

error message should be displayed indicating the file type is not supported
    Browser.Wait For Elements State    error-message    visible
    Element Text Should Be    error-message    File type not supported

error message should be displayed indicating the file size is too large
    Browser.Wait For Elements State    error-message    visible
    Element Text Should Be    error-message    File size is too large
