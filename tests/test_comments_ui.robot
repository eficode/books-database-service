*** Settings ***
Documentation     Integration tests for comment display and submission
Resource          resources/common.resource
Suite Setup       Setup Test Environment
Suite Teardown    Teardown Test Environment
Test Tags         ui    browser

*** Variables ***
${TEST_BOOK_ID}            1
${TEST_COMMENT_CONTENT}    This is a test comment

*** Test Cases ***
User Can Submit A Comment
    [Documentation]    Verify that a user can submit a comment on a book
    [Tags]             comment
    Given I Open The Book Detail Page For Book    ${TEST_BOOK_ID}
    When I Enter A Comment    ${TEST_COMMENT_CONTENT}
    And I Submit The Comment
    Then I Should See My Comment In The Comments Section

User Can View Comments
    [Documentation]    Verify that a user can view comments on a book
    [Tags]             comment
    Given I Open The Book Detail Page For Book    ${TEST_BOOK_ID}
    When There Are Existing Comments
    Then I Should See A List Of Comments
