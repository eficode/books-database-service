*** Settings ***
Documentation    This test suite verifies the functionality of the sales analysis dashboard and report generation features.
Library          Browser

*** Variables ***
${SALES_DASHBOARD_URL}    https://example.com/sales-dashboard
${USERNAME}               sales_manager
${PASSWORD}               password123

*** Test Cases ***
View YTD Sales Data
    [Documentation]    Verify that a sales manager can view YTD sales data comparison.
    [Tags]    req-GENAI-263    type-ok
    Given I am a sales manager
    When I access the sales analysis dashboard
    Then I should see a comparison of YTD sales data for the current year and the previous year

View YTD Sales Data with No Access
    [Documentation]    Verify that a sales manager without access sees an error message.
    [Tags]    req-GENAI-263    type-nok
    Given I am a sales manager
    And I do not have access to the sales analysis dashboard
    When I attempt to access the sales analysis dashboard
    Then I should see an error message indicating that I do not have access

Filter Sales Data by Various Parameters
    [Documentation]    Verify that sales data updates according to applied filters.
    [Tags]    req-GENAI-263    type-ok
    Given I am a sales manager
    When I apply filters such as date range, product category, and region
    Then the sales data should update accordingly to reflect the filtered criteria

Filter Sales Data with Invalid Parameters
    [Documentation]    Verify that an error message is shown for invalid filters.
    [Tags]    req-GENAI-263    type-nok
    Given I am a sales manager
    And I apply invalid filters such as an incorrect date range or non-existent product category
    When I apply the filters
    Then I should see an error message indicating that the filters are invalid

Generate Sales Performance Report
    [Documentation]    Verify that a sales performance report includes insights and trends.
    [Tags]    req-GENAI-263    type-ok
    Given I am a sales manager
    When I generate a sales performance report
    Then the report should include insights and trends explaining the YTD sales performance

Generate Sales Performance Report with No Data
    [Documentation]    Verify that a message is shown when no data is available for the selected period.
    [Tags]    req-GENAI-263    type-nok
    Given I am a sales manager
    And there is no sales data available for the selected period
    When I generate a sales performance report
    Then I should see a message indicating that there is no data available for the selected period

*** Keywords ***
I am a sales manager
    Browser.New Page    ${SALES_DASHBOARD_URL}
    Browser.Fill Text    username_field    ${USERNAME}
    Browser.Fill Text    password_field    ${PASSWORD}
    Browser.Click    login_button
    Browser.Wait For Elements State    Sales Dashboard    visible

I do not have access to the sales analysis dashboard
    Browser.New Page    ${SALES_DASHBOARD_URL}
    Browser.Fill Text    username_field    ${USERNAME}
    Browser.Fill Text    password_field    wrong_password
    Browser.Click    login_button
    Browser.Wait For Elements State    Access Denied    visible

I access the sales analysis dashboard
    Browser.Click    sales_analysis_dashboard_link
    Browser.Wait For Elements State    YTD Sales Data    visible

I attempt to access the sales analysis dashboard
    Browser.Click    sales_analysis_dashboard_link
    Browser.Wait For Elements State    Access Denied    visible

I apply filters such as date range, product category, and region
    Browser.Click    filter_button
    Browser.Fill Text    date_range_field    01/01/2023 - 12/31/2023
    Browser.Select Options By    product_category_field    label    Electronics
    Browser.Select Options By    region_field    label    North America
    Browser.Click    apply_filters_button
    Browser.Wait For Elements State    Filtered Sales Data    visible

I apply invalid filters such as an incorrect date range or non-existent product category
    Browser.Click    filter_button
    Browser.Fill Text    date_range_field    01/01/2025 - 12/31/2025
    Browser.Select Options By    product_category_field    label    NonExistentCategory
    Browser.Click    apply_filters_button
    Browser.Wait For Elements State    Invalid Filters Error    visible

I generate a sales performance report
    Browser.Click    generate_report_button
    Browser.Wait For Elements State    Sales Performance Report    visible

There is no sales data available for the selected period
    Set Variable    ${NO_DATA_PERIOD}    01/01/1900 - 12/31/1900
    Browser.Click    generate_report_button
    Browser.Wait For Elements State    No Data Available    visible

I should see a comparison of YTD sales data for the current year and the previous year
    Browser.Wait For Elements State    YTD Sales Comparison    visible

I should see an error message indicating that I do not have access
    Browser.Wait For Elements State    Access Denied Message    visible

The sales data should update accordingly to reflect the filtered criteria
    Browser.Wait For Elements State    Filtered Sales Data    visible

I should see an error message indicating that the filters are invalid
    Browser.Wait For Elements State    Invalid Filters Error    visible

The report should include insights and trends explaining the YTD sales performance
    Browser.Wait For Elements State    Sales Performance Insights    visible

I should see a message indicating that there is no data available for the selected period
    Browser.Wait For Elements State    No Data Available Message    visible
