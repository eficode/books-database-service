*** Settings ***
Documentation    This test suite verifies the functionality of viewing and loading book cover images in the catalog.
Library          Browser

*** Variables ***
${CATALOG_URL}    https://example.com/catalog

*** Test Cases ***
View book cover in catalog - successful scenario
    [Documentation]    Verify that book covers are displayed in the catalog.
    [Tags]    req-GENAI-506    type-ok
    Given I am browsing the book catalog
    When I view the list of book titles
    Then I should see a picture of the cover for each book

View book cover in catalog - unsuccessful scenario
    [Documentation]    Verify that an error message is shown when book cover images fail to load.
    [Tags]    req-GENAI-506    type-nok
    Given I am browsing the book catalog
    When I view the list of book titles
    And the book cover images fail to load
    Then I should see an error message indicating the images could not be loaded

Book cover image loading - successful scenario
    [Documentation]    Verify that a placeholder image is shown while the book cover image is loading.
    [Tags]    req-GENAI-506    type-ok
    Given I am browsing the book catalog
    When the book cover image is loading
    Then I should see a placeholder image until the book cover image is fully loaded

Book cover image loading - unsuccessful scenario
    [Documentation]    Verify that a default error image is shown when the placeholder image fails to display.
    [Tags]    req-GENAI-506    type-nok
    Given I am browsing the book catalog
    When the book cover image is loading
    And the placeholder image fails to display
    Then I should see a default error image indicating the placeholder could not be loaded

*** Keywords ***
I am browsing the book catalog
    New Page    ${CATALOG_URL}

I view the list of book titles
    Wait For Elements State    css=div.book-title    visible

I should see a picture of the cover for each book
    Wait For Elements State    css=img.book-cover    visible

The book cover images fail to load
    Evaluate    document.querySelectorAll('img.book-cover').forEach(img => img.src = '');

I should see an error message indicating the images could not be loaded
    Wait For Elements State    css=div.error-message    visible

The book cover image is loading
    Evaluate    document.querySelector('img.book-cover').src = 'loading-image-url';

I should see a placeholder image until the book cover image is fully loaded
    Wait For Elements State    css=img.placeholder    visible

The placeholder image fails to display
    Evaluate    document.querySelector('img.placeholder').src = '';

I should see a default error image indicating the placeholder could not be loaded
    Wait For Elements State    css=img.error-placeholder    visible
