*** Settings ***
Documentation     Test dashboard UI sorting functionality
Resource          resources/common.resource
Library           Browser
Suite Setup       Setup Test Environment  
Suite Teardown    Teardown Test Environment

*** Variables ***
${DASHBOARD_URL}    http://localhost:8000/dashboard

*** Test Cases ***
User Can Access Sales Dashboard
    [Documentation]    User should be able to navigate to sales dashboard
    New Browser    chromium    headless=True
    New Page    ${BASE_URL}
    Click    text="Sales Dashboard"
    Wait For Elements State    h1:has-text("Sales Dashboard")    visible
    Get Text    h1    contains    Sales Dashboard
    Close Browser

Dashboard Shows Most Sold Books Table
    [Documentation]    Dashboard should display a table with sold books
    New Browser    chromium    headless=True
    New Page    ${DASHBOARD_URL}
    Wait For Elements State    h2:has-text("Most Sold Books")    visible
    # Wait for table to be populated (it's loaded via JavaScript)
    Wait For Elements State    table    visible    timeout=10s
    ${headers}=    Get Elements    table thead th
    Length Should Be    ${headers}    7
    Close Browser

User Can Sort Books By Title Ascending
    [Documentation]    User should be able to sort sold books by title in ascending order
    New Browser    chromium    headless=True
    New Page    ${DASHBOARD_URL}
    Wait For Elements State    table    visible    timeout=10s
    
    # Click on sort by title button  
    Click    button:has-text("Title")
    Sleep    1s
    
    # Verify sorting indicator shows ascending
    Wait For Elements State    .sort-btn.active:has-text("Title")    visible
    
    # Get first few book titles and verify they're sorted
    ${titles}=    Get Elements    table tbody tr td:nth-child(2)
    ${title1}=    Get Text    ${titles}[0]
    ${title2}=    Get Text    ${titles}[1]
    Should Be True    '${title1}' < '${title2}'
    Close Browser

User Can Sort Books By Title Descending
    [Documentation]    User should be able to sort sold books by title in descending order
    New Browser    chromium    headless=True
    New Page    ${DASHBOARD_URL}
    Wait For Elements State    table    visible    timeout=10s
    
    # Click twice to get descending order
    Click    button:has-text("Title")
    Sleep    0.5s
    Click    button:has-text("Title")
    Sleep    1s
    
    # Verify sorting indicator shows descending
    Wait For Elements State    .sort-btn.active:has-text("Title")    visible
    
    # Get first few book titles and verify they're sorted
    ${titles}=    Get Elements    table tbody tr td:nth-child(2)
    ${title1}=    Get Text    ${titles}[0]
    ${title2}=    Get Text    ${titles}[1]
    Should Be True    '${title1}' > '${title2}'
    Close Browser

User Can Return To Default Sorting
    [Documentation]    User should be able to return to default sorting (most sold)
    New Browser    chromium    headless=True
    New Page    ${DASHBOARD_URL}
    Wait For Elements State    table    visible    timeout=10s
    
    # Sort by title first
    Click    button:has-text("Title")
    Sleep    1s
    
    # Click on "Most Sold" to return to default
    Click    button:has-text("Most Sold")
    Sleep    1s
    
    # Verify first book has highest sales
    ${first_sold}=    Get Text    table tbody tr:first-child td:nth-child(6)
    ${second_sold}=    Get Text    table tbody tr:nth-child(2) td:nth-child(6)
    ${first_num}=    Convert To Integer    ${first_sold}
    ${second_num}=    Convert To Integer    ${second_sold}
    Should Be True    ${first_num} >= ${second_num}
    Close Browser

Dashboard Updates After New Purchase
    [Documentation]    Dashboard should update when new purchases are made
    [Tags]    purchase    disabled
    New Browser    chromium    headless=True
    
    # First check current dashboard state
    New Page    ${DASHBOARD_URL}
    Wait For Elements State    table    visible    timeout=10s
    ${initial_total}=    Get Text    #total-books-sold
    
    # Go to main page and make a purchase
    New Page    ${BASE_URL}
    Wait For Elements State    .books-grid    visible
    
    # Add first book to basket
    Click    .book-card:first-child button:has-text("Add to Basket")
    Sleep    0.5s
    
    # Open basket and purchase
    Click    #shopping-basket-btn
    Wait For Elements State    #basket-modal    visible
    Click    #buy-now-btn
    Wait For Elements State    text="Thank you for your purchase!"    visible
    Click    #close-purchase-btn
    
    # Go back to dashboard and verify update
    Go To    ${DASHBOARD_URL}
    Wait For Elements State    table    visible    timeout=10s
    ${new_total}=    Get Text    #total-books-sold
    ${initial_num}=    Convert To Integer    ${initial_total}
    ${new_num}=    Convert To Integer    ${new_total}
    Should Be True    ${new_num} > ${initial_num}
    Close Browser