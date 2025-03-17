*** Settings ***
Documentation     End-to-End Tests for Book Comments Feature
Resource          resources/common.resource
Suite Setup       Setup Test Environment
Suite Teardown    Teardown Test Environment
Test Tags         e2e    comments

*** Variables ***
${BOOK_TITLE}     Test Book for Comments
${BOOK_AUTHOR}    Test Author
${BOOK_PAGES}     100
${BOOK_CATEGORY}  Fiction
${COMMENT_CONTENT}  This is a test comment.

*** Test Cases ***
User Can Leave A Comment On A Book
    [Documentation]    Verify that a user can leave a comment on a book
    [Tags]             comments
    Given I Am Logged In As A User
    And I Have Created A Book    ${BOOK_TITLE}    ${BOOK_AUTHOR}    ${BOOK_PAGES}    ${BOOK_CATEGORY}
    When I Navigate To The Book Detail Page    ${BOOK_TITLE}
    And I Enter A Comment    ${COMMENT_CONTENT}
    And I Submit The Comment
    Then I Should See My Comment Under The Book's Comments Section

User Can View Comments On A Book
    [Documentation]    Verify that a user can view comments on a book
    [Tags]             comments
    Given I Am On The Book Detail Page    ${BOOK_TITLE}
    When There Are Existing Comments
    Then I Should See A List Of Comments Left By Other Users

Comment Validation
    [Documentation]    Verify that an error message is shown when submitting an empty comment
    [Tags]             comments
    Given I Am Entering A Comment
    When I Submit An Empty Comment
    Then I Should See An Error Message Indicating That The Comment Cannot Be Empty
