*** Settings ***
Documentation    This test suite verifies the functionality of uploading and replacing book cover images in the book management section.
Library          Browser

*** Variables ***
${URL}           http://example.com
${VALID_IMAGE}   ${CURDIR}/resources/valid_image.jpg
${INVALID_IMAGE} ${CURDIR}/resources/invalid_image.txt
${CORRUPTED_IMAGE} ${CURDIR}/resources/corrupted_image.jpg

*** Test Cases ***
Upload a book cover image - successful scenario
    [Documentation]    Verify that an admin can successfully upload a valid book cover image.
    [Tags]    req-GENAI-329    type-ok
    I am an admin
    navigate to the book management section
    select a book to upload a cover image for
    upload a valid image file
    book cover image should be successfully uploaded
    image should be displayed on the book's detail page

Upload a book cover image with an unsupported file format - unsuccessful scenario
    [Documentation]    Verify that an admin receives an error when uploading an unsupported file format as a book cover image.
    [Tags]    req-GENAI-329    type-nok
    I am an admin
    navigate to the book management section
    select a book to upload a cover image for
    upload an unsupported file format
    should receive an error message indicating the file is not supported

Upload an invalid book cover image - successful scenario
    [Documentation]    Verify that an admin receives an error when uploading an invalid image file as a book cover image.
    [Tags]    req-GENAI-329    type-nok
    I am an admin
    navigate to the book management section
    select a book to upload a cover image for
    upload an invalid image file
    should receive an error message indicating the file is not supported

Upload an invalid book cover image with a corrupted file - unsuccessful scenario
    [Documentation]    Verify that an admin receives an error when uploading a corrupted image file as a book cover image.
    [Tags]    req-GENAI-329    type-nok
    I am an admin
    navigate to the book management section
    select a book to upload a cover image for
    upload a corrupted image file
    should receive an error message indicating the file is corrupted

Replace an existing book cover image - successful scenario
    [Documentation]    Verify that an admin can successfully replace an existing book cover image with a new valid image file.
    [Tags]    req-GENAI-329    type-ok
    I am an admin
    navigate to the book management section
    select a book with an existing cover image
    upload a new valid image file
    new book cover image should replace the existing one
    new image should be displayed on the book's detail page

Replace an existing book cover image with an invalid file - unsuccessful scenario
    [Documentation]    Verify that an admin receives an error when trying to replace an existing book cover image with an invalid image file.
    [Tags]    req-GENAI-329    type-nok
    I am an admin
    navigate to the book management section
    select a book with an existing cover image
    upload an invalid image file
    should receive an error message indicating the file is not supported

*** Keywords ***
I am an admin
    New Browser    chromium
    Go To    ${URL}
    Login as Admin

Login as Admin
    Click    //button[text()='Login']
    Input Text    //input[@name='username']    admin
    Input Text    //input[@name='password']    admin123
    Click    //button[text()='Submit']

navigate to the book management section
    Click    //a[@href='/book-management']

select a book to upload a cover image for
    Click    //tr[1]//button[text()='Upload Cover']

upload a valid image file
    Upload File    //input[@type='file']    ${VALID_IMAGE}
    Click    //button[text()='Submit']

upload an unsupported file format
    Upload File    //input[@type='file']    ${INVALID_IMAGE}
    Click    //button[text()='Submit']

upload an invalid image file
    Upload File    //input[@type='file']    ${INVALID_IMAGE}
    Click    //button[text()='Submit']

upload a corrupted image file
    Upload File    //input[@type='file']    ${CORRUPTED_IMAGE}
    Click    //button[text()='Submit']

select a book with an existing cover image
    Click    //tr[1]//button[text()='Replace Cover']

upload a new valid image file
    Upload File    //input[@type='file']    ${VALID_IMAGE}
    Click    //button[text()='Submit']

book cover image should be successfully uploaded
    Wait For Elements State    //img[@alt='Book Cover']    visible

image should be displayed on the book's detail page
    Get Element State    //img[@alt='Book Cover']    visible

should receive an error message indicating the file is not supported
    Wait For Elements State    //div[@class='error' and contains(text(), 'file is not supported')]    visible

should receive an error message indicating the file is corrupted
    Wait For Elements State    //div[@class='error' and contains(text(), 'file is corrupted')]    visible

new book cover image should replace the existing one
    Wait For Elements State    //img[@alt='Book Cover']    visible

new image should be displayed on the book's detail page
    Get Element State    //img[@alt='Book Cover']    visible
