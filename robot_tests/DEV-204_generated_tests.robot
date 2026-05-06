*** Settings ***
Documentation    Test suite for verifying book arrangement functionality
Library          Browser

*** Variables ***

*** Test Cases ***
Arrange Books In Ascending Order
    [Documentation]    Verify that books are arranged in ascending alphabetical order
    [Tags]    req-DEV-203    type-ok
    I have a list of books
    I choose to arrange the list alphabetically
    The list should be sorted in ascending alphabetical order by book title

Arrange Books In Ascending Order With An Empty List
    [Documentation]    Verify that an empty list remains empty when arranged in ascending order
    [Tags]    req-DEV-203    type-nok
    I have an empty list of books
    I choose to arrange the list alphabetically
    The list should remain empty

Arrange Books In Descending Order
    [Documentation]    Verify that books are arranged in descending alphabetical order
    [Tags]    req-DEV-203    type-ok
    I have a list of books
    I choose to arrange the list in reverse alphabetical order
    The list should be sorted in descending alphabetical order by book title

Arrange Books In Descending Order With An Empty List
    [Documentation]    Verify that an empty list remains empty when arranged in descending order
    [Tags]    req-DEV-203    type-nok
    I have an empty list of books
    I choose to arrange the list in reverse alphabetical order
    The list should remain empty

*** Keywords ***
I have a list of books
    [Documentation]    Initialize a list of books
    # Code to initialize a list of books

I have an empty list of books
    [Documentation]    Initialize an empty list of books
    # Code to initialize an empty list of books

I choose to arrange the list alphabetically
    [Documentation]    Arrange the list alphabetically
    # Code to arrange the list alphabetically

I choose to arrange the list in reverse alphabetical order
    [Documentation]    Arrange the list in reverse alphabetical order
    # Code to arrange the list in reverse alphabetical order

The list should be sorted in ascending alphabetical order by book title
    [Documentation]    Verify the list is sorted in ascending order
    # Code to verify the list is sorted in ascending order

The list should be sorted in descending alphabetical order by book title
    [Documentation]    Verify the list is sorted in descending order
    # Code to verify the list is sorted in descending order

The list should remain empty
    [Documentation]    Verify the list remains empty
    # Code to verify the list remains empty
