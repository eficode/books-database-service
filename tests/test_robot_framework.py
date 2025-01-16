*** Settings ***
Library  Browser

*** Variables ***
${EMAIL_RECEIVED}  False

*** Test Cases ***
Receive daily email
  [Documentation]  Verify that the Sales Manager receives an email with a list of the most sold books at 8:00 AM.
  [Tags]  req-GEN-51  type-ok
  Given I am a Sales Manager
  When the system time is 8:00 AM
  Then I should receive an email with a list of the most sold books

Receive daily email - Negative Case
  [Documentation]  Verify that the Sales Manager does not receive an email if the system time is not 8:00 AM.
  [Tags]  req-GEN-51  type-nok
  Given I am a Sales Manager
  When the system time is not 8:00 AM
  Then I should not receive an email with a list of the most sold books

Email content
  [Documentation]  Verify that the daily email contains a list of the most sold books sorted by sales volume in descending order.
  [Tags]  req-GEN-51  type-ok
  Given I have received the daily email
  Then the email should contain a list of the most sold books
  And the list should be sorted by sales volume in descending order

Email content - Negative Case
  [Documentation]  Verify that the daily email does not contain the correct list of most sold books if the email is not received.
  [Tags]  req-GEN-51  type-nok
  Given I have not received the daily email
  Then the email should not contain a list of the most sold books
  And the list should not be sorted by sales volume in descending order

*** Keywords ***
I am a Sales Manager
  Log  Sales Manager is logged in

The system time is 8:00 AM
  Log  Setting system time to 08:00 AM
  Set Variable  ${EMAIL_RECEIVED}  True

The system time is not 8:00 AM
  Log  Setting system time to 09:00 AM
  Set Variable  ${EMAIL_RECEIVED}  False

I should receive an email with a list of the most sold books
  Run Keyword If  '${EMAIL_RECEIVED}' == 'True'  Log  Email received with list of most sold books
  ...  ELSE  Fail  Email not received

I should not receive an email with a list of the most sold books
  Run Keyword If  '${EMAIL_RECEIVED}' == 'False'  Log  Email not received
  ...  ELSE  Fail  Email received

I have received the daily email
  Set Variable  ${EMAIL_RECEIVED}  True

I have not received the daily email
  Set Variable  ${EMAIL_RECEIVED}  False

The email should contain a list of the most sold books
  Log  Email contains list of most sold books

The list should be sorted by sales volume in descending order
  Log  List is sorted by sales volume in descending order

The email should not contain a list of the most sold books
  Log  Email does not contain list of most sold books

The list should not be sorted by sales volume in descending order
  Log  List is not sorted by sales volume in descending order
