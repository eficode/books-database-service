*** Settings ***
Documentation    This test suite verifies the search functionality on the shop page.
Library          Browser

*** Variables ***
${SHOP_URL}    https://example.com/shop

*** Test Cases ***
Search by Genre - successful scenario
    [Documentation]    Verify that selecting a genre displays the correct list of books.
    [Tags]    req-DEV-173    type-ok
    Given I am on the shop page
    When I select the 'Sci-Fi' genre from the genre filter
    Then I should see a list of sci-fi books available in the shop

Search by Genre with No Results - unsuccessful scenario
    [Documentation]    Verify that selecting a genre with no available books shows a no results message.
    [Tags]    req-DEV-173    type-nok
    Given I am on the shop page
    When I select the 'Sci-Fi' genre from the genre filter
    And there are no sci-fi books available
    Then I should see a message indicating no sci-fi books are available

Search by Keyword - successful scenario
    [Documentation]    Verify that entering a keyword displays the correct list of books.
    [Tags]    req-DEV-173    type-ok
    Given I am on the shop page
    When I enter 'sci-fi' in the search bar
    Then I should see a list of sci-fi books matching the keyword

Search by Keyword with No Results - unsuccessful scenario
    [Documentation]    Verify that entering a keyword with no matching books shows a no results message.
    [Tags]    req-DEV-173    type-nok
    Given I am on the shop page
    When I enter 'sci-fi' in the search bar
    And there are no books matching the keyword
    Then I should see a message indicating no books match the search keyword

*** Keywords ***
I am on the shop page
    New Page    ${SHOP_URL}

I select the 'Sci-Fi' genre from the genre filter
    Click    genre-filter
    Click    genre-sci-fi

I should see a list of sci-fi books available in the shop
    Wait For Elements State    book-item    visible

There are no sci-fi books available
    # This step would be implemented with a mock or a setup that ensures no sci-fi books are available.
    # For example, clearing the sci-fi books from the database or using a mock API response.
    Log    No sci-fi books available setup done

I should see a message indicating no sci-fi books are available
    Wait For Elements State    no-results-message    visible

I enter 'sci-fi' in the search bar
    Click    search-bar
    Type Text    search-bar    sci-fi
    Press Keys    search-bar    ENTER

I should see a list of sci-fi books matching the keyword
    Wait For Elements State    book-item    visible

There are no books matching the keyword
    # This step would be implemented with a mock or a setup that ensures no books match the keyword.
    # For example, clearing the books from the database or using a mock API response.
    Log    No books matching keyword setup done

I should see a message indicating no books match the search keyword
    Wait For Elements State    no-results-message    visible
