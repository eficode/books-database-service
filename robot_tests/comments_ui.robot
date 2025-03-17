*** Settings ***
Documentation     UI Tests for Comments on Books
Resource          resources/common.resource
Suite Setup       Setup Test Environment
Suite Teardown    Teardown Test Environment
Test Tags         ui    browser

*** Variables ***
${BOOK_ID}        1
${COMMENT_CONTENT}    This is a test comment.

*** Test Cases ***
User Can View Comments On A Book
    [Documentation]    Verify that comments are displayed for a book
    [Tags]             comments
    Given I Open The Book Detail Page    ${BOOK_ID}
    Then I Should See The Comments Section
    And I Should See Existing Comments

User Can Submit A Comment
    [Documentation]    Verify that a user can submit a comment
    [Tags]             comments
    Given I Open The Book Detail Page    ${BOOK_ID}
    When I Enter A Comment    ${COMMENT_CONTENT}
    And I Submit The Comment
    Then I Should See My Comment In The Comments Section
