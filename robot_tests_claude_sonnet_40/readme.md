# LLM: Claude Sonnet 4.0

## Prompt 1

You are a professional DevOps and Test Automation developer. Can you generate Robot Framework acceptance tests with Browser Library in Gherkin syntax? Create `books_ui.robot` for UI tests, `books_api.robot` for API tests, and `resources/common.resource` for all common keywords under the `robot_tests` folder. Create separate keyword files for UI and API tests. Use instructions from YAML files as well.

## Test Execution and Fixing

Most of the tests are failing. To fix them prompt as follows:  

### Prompt 2

Can you run all the tests, and if any test fails, run that test separately to find out why it’s failing? Then fix the test and run it again. Go through all the tests like this. Don’t touch the app code — only modify the tests or test keywords.
