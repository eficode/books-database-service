#!/bin/bash

# Local Robot Framework Test Execution Script
# This script provides various options for running Robot Framework tests locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BROWSER="chromium"
HEADLESS="true"
BASE_URL="http://localhost:8000"
OUTPUT_DIR="robot_results"
INCLUDE_TAGS=""
EXCLUDE_TAGS=""
TEST_SUITE=""
PARALLEL_PROCESSES=""
VERBOSE=""

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Robot Framework Test Execution Script for Books Library

OPTIONS:
    -h, --help              Show this help message
    -b, --browser BROWSER   Browser to use (chromium, firefox, webkit) [default: chromium]
    -H, --headed            Run in headed mode (show browser window)
    -u, --url URL           Base URL of the application [default: http://localhost:8000]
    -o, --output DIR        Output directory for results [default: robot_results]
    -i, --include TAGS      Include tests with specific tags (comma-separated)
    -e, --exclude TAGS      Exclude tests with specific tags (comma-separated)
    -s, --suite SUITE       Run specific test suite (ui, api, integration, all)
    -p, --parallel N        Run tests in parallel with N processes
    -v, --verbose           Enable verbose output
    --smoke                 Run only smoke tests
    --quick                 Run smoke and API tests (quick feedback)
    --full                  Run all tests
    --debug                 Run with debug mode enabled
    --dry-run               Show what would be executed without running

EXAMPLES:
    # Run smoke tests
    $0 --smoke

    # Run UI tests in headed mode
    $0 --suite ui --headed

    # Run all tests except performance tests
    $0 --exclude performance

    # Run tests in parallel
    $0 --parallel 4

    # Run with custom URL
    $0 --url http://localhost:3000

    # Run specific test
    $0 --include "crud AND ui"

    # Debug mode
    $0 --debug --headed --suite ui

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if Robot Framework is installed
    if ! command -v robot &> /dev/null; then
        print_error "Robot Framework is not installed. Please run: pip install -r requirements-robot.txt"
        exit 1
    fi
    
    # Check if Browser library is initialized
    if ! python -c "from robot.libraries.Browser import Browser" &> /dev/null; then
        print_warning "Browser library may not be properly initialized. Running initialization..."
        python -m Browser.entry init
    fi
    
    # Check if application is running
    if ! curl -f "$BASE_URL" &> /dev/null; then
        print_warning "Application may not be running at $BASE_URL"
        print_info "Make sure to start the application with: docker-compose up -d"
    fi
    
    print_success "Prerequisites check completed"
}

# Function to build robot command
build_robot_command() {
    local cmd="robot"
    
    # Output directory
    cmd="$cmd --outputdir $OUTPUT_DIR"
    
    # Variables
    cmd="$cmd --variable BROWSER:$BROWSER"
    cmd="$cmd --variable HEADLESS:$HEADLESS"
    cmd="$cmd --variable BASE_URL:$BASE_URL"
    
    # Include/exclude tags
    if [[ -n "$INCLUDE_TAGS" ]]; then
        cmd="$cmd --include $INCLUDE_TAGS"
    fi
    
    if [[ -n "$EXCLUDE_TAGS" ]]; then
        cmd="$cmd --exclude $EXCLUDE_TAGS"
    fi
    
    # Verbose output
    if [[ "$VERBOSE" == "true" ]]; then
        cmd="$cmd --loglevel DEBUG"
    else
        cmd="$cmd --loglevel INFO"
    fi
    
    # Test suite selection
    case "$TEST_SUITE" in
        "ui")
            cmd="$cmd books_ui.robot"
            ;;
        "api")
            cmd="$cmd books_api.robot"
            ;;
        "integration")
            cmd="$cmd integration_tests.robot"
            ;;
        "all"|"")
            cmd="$cmd ."
            ;;
        *)
            cmd="$cmd $TEST_SUITE"
            ;;
    esac
    
    echo "$cmd"
}

# Function to run tests with pabot (parallel)
run_parallel_tests() {
    local processes=$1
    local cmd="pabot --processes $processes"
    
    # Output directory
    cmd="$cmd --outputdir $OUTPUT_DIR"
    
    # Variables
    cmd="$cmd --variable BROWSER:$BROWSER"
    cmd="$cmd --variable HEADLESS:$HEADLESS"
    cmd="$cmd --variable BASE_URL:$BASE_URL"
    
    # Include/exclude tags
    if [[ -n "$INCLUDE_TAGS" ]]; then
        cmd="$cmd --include $INCLUDE_TAGS"
    fi
    
    if [[ -n "$EXCLUDE_TAGS" ]]; then
        cmd="$cmd --exclude $EXCLUDE_TAGS"
    fi
    
    # Test suite
    if [[ -n "$TEST_SUITE" && "$TEST_SUITE" != "all" ]]; then
        case "$TEST_SUITE" in
            "ui")
                cmd="$cmd books_ui.robot"
                ;;
            "api")
                cmd="$cmd books_api.robot"
                ;;
            "integration")
                cmd="$cmd integration_tests.robot"
                ;;
            *)
                cmd="$cmd $TEST_SUITE"
                ;;
        esac
    else
        cmd="$cmd ."
    fi
    
    print_info "Running tests in parallel with $processes processes..."
    print_info "Command: $cmd"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        eval "$cmd"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -b|--browser)
            BROWSER="$2"
            shift 2
            ;;
        -H|--headed)
            HEADLESS="false"
            shift
            ;;
        -u|--url)
            BASE_URL="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -i|--include)
            INCLUDE_TAGS="$2"
            shift 2
            ;;
        -e|--exclude)
            EXCLUDE_TAGS="$2"
            shift 2
            ;;
        -s|--suite)
            TEST_SUITE="$2"
            shift 2
            ;;
        -p|--parallel)
            PARALLEL_PROCESSES="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        --smoke)
            INCLUDE_TAGS="smoke"
            shift
            ;;
        --quick)
            INCLUDE_TAGS="smoke OR api"
            shift
            ;;
        --full)
            TEST_SUITE="all"
            shift
            ;;
        --debug)
            VERBOSE="true"
            HEADLESS="false"
            shift
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_info "Starting Robot Framework test execution..."
    print_info "Browser: $BROWSER"
    print_info "Headless: $HEADLESS"
    print_info "Base URL: $BASE_URL"
    print_info "Output Directory: $OUTPUT_DIR"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Check prerequisites
    if [[ "$DRY_RUN" != "true" ]]; then
        check_prerequisites
    fi
    
    # Change to robot_tests directory
    cd "$(dirname "$0")"
    
    # Run tests
    if [[ -n "$PARALLEL_PROCESSES" ]]; then
        run_parallel_tests "$PARALLEL_PROCESSES"
    else
        local cmd=$(build_robot_command)
        print_info "Command: $cmd"
        
        if [[ "$DRY_RUN" != "true" ]]; then
            eval "$cmd"
            local exit_code=$?
            
            if [[ $exit_code -eq 0 ]]; then
                print_success "All tests passed!"
            else
                print_error "Some tests failed. Check the reports in $OUTPUT_DIR"
            fi
            
            print_info "Test reports available at:"
            print_info "  - Report: $OUTPUT_DIR/report.html"
            print_info "  - Log: $OUTPUT_DIR/log.html"
            
            exit $exit_code
        fi
    fi
}

# Run main function
main