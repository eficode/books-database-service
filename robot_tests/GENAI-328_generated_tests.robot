*** Settings ***
Documentation    This test suite verifies the functionality of uploading and validating book cover images in the book management section.
Library          Browser

*** Variables ***
${BOOK_MANAGEMENT_URL}    http://example.com/book-management
${VALID_IMAGE_PATH}       ${CURDIR}/resources/valid_image.jpg
${INVALID_IMAGE_PATH}     ${CURDIR}/resources/invalid_image.txt
${LARGE_IMAGE_PATH}       ${CURDIR}/resources/large_image.jpg

*** Test Cases ***
Upload a new book cover image - successful scenario
    [Documentation]    Verify that an admin can successfully upload a new book cover image.
    [Tags]    req-GENAI-326    type-ok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image
    new cover image should be saved and displayed for the book

Upload a new book cover image with invalid format - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when uploading a book cover image with an invalid format.
    [Tags]    req-GENAI-326    type-nok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image with an invalid format
    should receive an error message indicating the invalid format

Replace an existing book cover image - successful scenario
    [Documentation]    Verify that an admin can successfully replace an existing book cover image.
    [Tags]    req-GENAI-326    type-ok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image
    new cover image should replace the existing one and be displayed for the book

Replace an existing book cover image with a large file size - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when uploading a book cover image with a large file size.
    [Tags]    req-GENAI-326    type-nok
    I am an admin
    navigate to the book management section
    select a book to edit
    upload a new cover image with a large file size
    should receive an error message indicating the file size is too large

Validate image format and size - successful scenario
    [Documentation]    Verify that the image format and size are validated when uploading a book cover image.
    [Tags]    req-GENAI-326    type-ok
    I am an admin
    upload a book cover image
    image format should be validated
    image size should be validated
    should receive an error message if the image format or size is invalid

Validate image format and size with invalid image - unsuccessful scenario
    [Documentation]    Verify that an error message is displayed when uploading a book cover image with an invalid format or size.
    [Tags]    req-GENAI-326    type-nok
    I am an admin
    upload a book cover image with an invalid format or size
    should receive an error message indicating the invalid format or size

*** Keywords ***
I am an admin
    New Browser    chromium
    Go To    ${BOOK_MANAGEMENT_URL}
    Login as admin user

Login as admin user
    Click    //input[@name='username']
    Type Text    //input[@name='username']    admin
    Click    //input[@name='password']
    Type Text    //input[@name='password']    adminpassword
    Click    //button[@type='submit']

navigate to the book management section
    Click    //a[@href='/book-management']

select a book to edit
    Click    //tr[1]//td[5]//button[text()='Edit']

upload a new cover image
    Upload File    //input[@type='file']    ${VALID_IMAGE_PATH}
    Click    //button[text()='Save']

upload a new cover image with an invalid format
    Upload File    //input[@type='file']    ${INVALID_IMAGE_PATH}
    Click    //button[text()='Save']

upload a new cover image with a large file size
    Upload File    //input[@type='file']    ${LARGE_IMAGE_PATH}
    Click    //button[text()='Save']

new cover image should be saved and displayed for the book
    Wait For Elements State    //img[@src='/images/valid_image.jpg']    visible

new cover image should replace the existing one and be displayed for the book
    Wait For Elements State    //img[@src='/images/valid_image.jpg']    visible

should receive an error message indicating the invalid format
    Wait For Elements State    //div[@class='error' and contains(text(),'Invalid format')]    visible

should receive an error message indicating the file size is too large
    Wait For Elements State    //div[@class='error' and contains(text(),'File size is too large')]    visible

image format should be validated
    Wait For Elements State    //div[@class='success' and contains(text(),'Format validated')]    visible

image size should be validated
    Wait For Elements State    //div[@class='success' and contains(text(),'Size validated')]    visible

should receive an error message if the image format or size is invalid
    Wait For Elements State    //div[@class='error' and contains(text(),'Invalid format or size')]    visible

upload a book cover image
    Upload File    //input[@type='file']    ${VALID_IMAGE_PATH}
    Click    //button[text()='Save']

upload a book cover image with an invalid format or size
    Upload File    //input[@type='file']    ${INVALID_IMAGE_PATH}
    Click    //button[text()='Save']
