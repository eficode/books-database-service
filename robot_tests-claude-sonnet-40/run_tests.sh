#!/bin/bash
# Robot Framework Test Execution Script
# Based on GitLab CI/CD pipeline patterns

set -e

# Configuration
ROBOT_RESULTS_DIR="robot_results"
BASE_URL="${BASE_URL:-http://localhost:8000}"
BROWSER="${BROWSER:-chromium}"
HEADLESS="${HEADLESS:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create results directory
mkdir -p "$ROBOT_RESULTS_DIR"

# Check if service is running
log_info "Checking if Books Library service is running..."
if curl -f "$BASE_URL/books/" >/dev/null 2>&1; then
    log_success "Service is running at $BASE_URL"
else
    log_error "Service is not running at $BASE_URL"
    log_info "Please start the service with: docker-compose up -d"
    exit 1
fi

# Function to run tests with specific tags
run_tests() {
    local test_type="$1"
    local include_tags="$2"
    local test_files="$3"
    local output_prefix="$4"
    
    log_info "Running $test_type tests..."
    
    poetry run robot \
        --outputdir "$ROBOT_RESULTS_DIR" \
        --variable BASE_URL:"$BASE_URL" \
        --variable BROWSER:"$BROWSER" \
        --variable HEADLESS:"$HEADLESS" \
        --include "$include_tags" \
        --loglevel INFO \
        --report "$ROBOT_RESULTS_DIR/${output_prefix}_report.html" \
        --log "$ROBOT_RESULTS_DIR/${output_prefix}_log.html" \
        --output "$ROBOT_RESULTS_DIR/${output_prefix}_output.xml" \
        $test_files
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        log_success "$test_type tests passed!"
    else
        log_error "$test_type tests failed with exit code $exit_code"
        return $exit_code
    fi
}

# Parse command line arguments
case "${1:-all}" in
    "smoke")
        log_info "Running smoke tests only..."
        run_tests "Smoke" "smoke" "robot_tests/" "smoke"
        ;;
    "critical")
        log_info "Running critical tests only..."
        run_tests "Critical" "critical" "robot_tests/" "critical"
        ;;
    "api")
        log_info "Running API tests only..."
        run_tests "API" "api" "robot_tests/books_api.robot" "api"
        ;;
    "ui")
        log_info "Running UI tests only..."
        run_tests "UI" "ui" "robot_tests/books_ui.robot" "ui"
        ;;
    "quick")
        log_info "Running quick test suite (smoke + critical)..."
        run_tests "Smoke" "smoke" "robot_tests/" "smoke" && \
        run_tests "Critical" "critical" "robot_tests/" "critical"
        ;;
    "all")
        log_info "Running complete test suite..."
        
        # Run tests in order: smoke -> critical -> all
        log_info "Step 1: Running smoke tests..."
        run_tests "Smoke" "smoke" "robot_tests/" "smoke"
        
        log_info "Step 2: Running critical tests..."
        run_tests "Critical" "critical" "robot_tests/" "critical"
        
        log_info "Step 3: Running all tests..."
        poetry run robot \
            --outputdir "$ROBOT_RESULTS_DIR" \
            --variable BASE_URL:"$BASE_URL" \
            --variable BROWSER:"$BROWSER" \
            --variable HEADLESS:"$HEADLESS" \
            --loglevel INFO \
            --report "$ROBOT_RESULTS_DIR/complete_report.html" \
            --log "$ROBOT_RESULTS_DIR/complete_log.html" \
            --output "$ROBOT_RESULTS_DIR/complete_output.xml" \
            robot_tests/
        
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            log_success "All tests passed!"
        else
            log_error "Some tests failed with exit code $exit_code"
            exit $exit_code
        fi
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [test_type]"
        echo ""
        echo "Test types:"
        echo "  smoke     - Run smoke tests only"
        echo "  critical  - Run critical tests only"
        echo "  api       - Run API tests only"
        echo "  ui        - Run UI tests only"
        echo "  quick     - Run smoke + critical tests"
        echo "  all       - Run complete test suite (default)"
        echo "  help      - Show this help message"
        echo ""
        echo "Environment variables:"
        echo "  BASE_URL  - Application base URL (default: http://localhost:8000)"
        echo "  BROWSER   - Browser to use for UI tests (default: chromium)"
        echo "  HEADLESS  - Run browser in headless mode (default: true)"
        echo ""
        echo "Examples:"
        echo "  $0 smoke"
        echo "  BASE_URL=http://localhost:3000 $0 api"
        echo "  HEADLESS=false $0 ui"
        exit 0
        ;;
    *)
        log_error "Unknown test type: $1"
        log_info "Use '$0 help' for usage information"
        exit 1
        ;;
esac

log_success "Test execution completed!"
log_info "Results available in: $ROBOT_RESULTS_DIR/"