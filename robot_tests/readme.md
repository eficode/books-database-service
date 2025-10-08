
LLM: Claude Sonnet 4

Promp:
    You are professional DevOps and Test automation developer. Can you generate Robot Framework acceptance tests with browser-library in Gherkin syntax. Create books_ui.robot for UI tests and books_api.robot for API tests and resources/common.resource for all common keywords under robot_tests -folder. Create own keyword files for UI and API tests. Use also instructios from yaml-files.

Most of tests are failing. To fix them:
Prompt:
    Can you run all the tests, and if any test fails, run that test separately to find out why it’s failing. Then fix the test and run it again. Go through all the tests like this. Don’t touch the app code — only modify the tests or test keywords.