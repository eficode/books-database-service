*** Settings ***
Library           Browser
Documentation    This test suite verifies the functionality of viewing book cover images in the catalog.

*** Variables ***
${CATALOG_URL}    http://example.com/catalog
${BOOK_TITLE}     Example Book Title
${PLACEHOLDER_IMAGE}    http://example.com/placeholder.png

*** Test Cases ***
View Book Cover Image In Catalog - Successful Scenario
    [Documentation]    Verify that the cover image of a selected book is displayed when browsing the catalog.
    [Tags]    req-GENAI-500    type-ok
    Given I am browsing the catalog
    When I select a book
    Then I should see the cover image of the selected book

View Book Cover Image In Catalog - Unsuccessful Scenario
    [Documentation]    Verify that an error message is displayed when the catalog service is down and a book is selected.
    [Tags]    req-GENAI-500    type-nok
    Given I am browsing the catalog
    And the catalog service is down
    When I select a book
    Then I should not see the cover image of the selected book
    And I should see an error message indicating the service is unavailable

No Cover Image Available - Successful Scenario
    [Documentation]    Verify that a placeholder image is displayed when a book with no cover image is selected.
    [Tags]    req-GENAI-500    type-ok
    Given I am browsing the catalog
    When I select a book with no cover image available
    Then I should see a placeholder image indicating no cover image is available

No Cover Image Available - Unsuccessful Scenario
    [Documentation]    Verify that an error message is displayed when the placeholder image service is down and a book with no cover image is selected.
    [Tags]    req-GENAI-500    type-nok
    Given I am browsing the catalog
    And the placeholder image service is down
    When I select a book with no cover image available
    Then I should not see a placeholder image indicating no cover image is available
    And I should see an error message indicating the placeholder image service is unavailable

*** Keywords ***
I am browsing the catalog
    New Page    ${CATALOG_URL}
    Wait For Elements State    //div[@class='catalog']    visible

I select a book
    Click    //div[@class='book'][contains(., '${BOOK_TITLE}')]
    Wait For Elements State    //div[@class='book-details']    visible

I should see the cover image of the selected book
    Wait For Elements State    //img[@class='cover-image']    visible

The catalog service is down
    # Simulate the catalog service being down
    Evaluate    window.catalogServiceDown = true;

I should not see the cover image of the selected book
    Wait For Elements State    //img[@class='cover-image']    hidden

I should see an error message indicating the service is unavailable
    Wait For Elements State    //div[@class='error-message'][contains(., 'Service is unavailable')]    visible

I select a book with no cover image available
    Click    //div[@class='book'][contains(., 'No Cover Image Available')]
    Wait For Elements State    //div[@class='book-details']    visible

I should see a placeholder image indicating no cover image is available
    Wait For Elements State    //img[@src='${PLACEHOLDER_IMAGE}']    visible

The placeholder image service is down
    # Simulate the placeholder image service being down
    Evaluate    window.placeholderImageServiceDown = true;

I should not see a placeholder image indicating no cover image is available
    Wait For Elements State    //img[@src='${PLACEHOLDER_IMAGE}']    hidden

I should see an error message indicating the placeholder image service is unavailable
    Wait For Elements State    //div[@class='error-message'][contains(., 'Placeholder image service is unavailable')]    visible
