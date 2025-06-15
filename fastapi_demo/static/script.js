// DOM Elements
const bookForm = document.getElementById('book-form');
const booksList = document.getElementById('books-list');
const editModal = document.getElementById('edit-modal');
const closeModalBtn = document.querySelector('.close');
const editForm = document.getElementById('edit-form');
const searchInput = document.getElementById('search-input');
const searchBtn = document.getElementById('search-btn');
const categoryFilter = document.getElementById('category-filter');
const sortBySelect = document.getElementById('sort-by');
const sortDirectionBtn = document.getElementById('sort-direction');
const shownCountEl = document.getElementById('shown-count');
const totalCountEl = document.getElementById('total-count');
const loadMoreBtn = document.getElementById('load-more');

// Simple console log without overriding fetch
console.log('Books app initialized');

// API Base URL - use absolute path to avoid any browser path issues
const API_URL = window.location.origin + '/books';

// Cross-browser compatibility flag
const IS_BRAVE = navigator.brave?.isBrave?.() || navigator.userAgent.includes('Brave') || false;
console.log('Browser detection - Brave:', IS_BRAVE);

// Cross-browser XHR function instead of fetch API for maximum compatibility
function xhrRequest(url, method, data) {
    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        xhr.open(method, url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Accept', 'application/json');
        
        xhr.onload = function() {
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    const response = JSON.parse(xhr.responseText);
                    resolve(response);
                } catch (e) {
                    resolve(xhr.responseText);
                }
            } else {
                reject({
                    status: xhr.status,
                    statusText: xhr.statusText
                });
            }
        };
        
        xhr.onerror = function() {
            reject({
                status: xhr.status,
                statusText: 'Network Error'
            });
        };
        
        if (data) {
            xhr.send(JSON.stringify(data));
        } else {
            xhr.send();
        }
    });
}

// App State
const state = {
    books: [],
    filteredBooks: [],
    filters: {
        search: '',
        category: 'all',
        favorite: false
    },
    sort: {
        by: 'title',
        ascending: true
    },
    pagination: {
        page: 1,
        limit: 12,
        hasMore: false
    }
};

// Event Listeners
document.addEventListener('DOMContentLoaded', () => {
    console.log('Page loaded, URL:', window.location.href);
    fetchBooks();
    initializeBasket();
});
bookForm.addEventListener('submit', addBook);
editForm.addEventListener('submit', updateBook);
closeModalBtn.addEventListener('click', closeModal);
window.addEventListener('click', (e) => {
    if (e.target === editModal) {
        closeModal();
    }
});

// Debug: Monitor URL changes
let lastUrl = window.location.href;
setInterval(() => {
    if (lastUrl !== window.location.href) {
        console.log('URL changed from', lastUrl, 'to', window.location.href);
        lastUrl = window.location.href;
    }
}, 500);

// Favorite filter buttons
const allBooksFilter = document.getElementById('all-books-filter');
const favoriteFilter = document.getElementById('favorite-filter');

allBooksFilter.addEventListener('click', () => {
    allBooksFilter.classList.add('active');
    favoriteFilter.classList.remove('active');
    state.filters.favorite = false;
    applyFiltersAndSort();
});

favoriteFilter.addEventListener('click', () => {
    favoriteFilter.classList.add('active');
    allBooksFilter.classList.remove('active');
    state.filters.favorite = true;
    applyFiltersAndSort();
});

// Filter and sort event listeners
searchInput.addEventListener('input', debounce(() => {
    state.filters.search = searchInput.value.trim().toLowerCase();
    applyFiltersAndSort();
}, 300));

searchBtn.addEventListener('click', () => {
    state.filters.search = searchInput.value.trim().toLowerCase();
    applyFiltersAndSort();
});

categoryFilter.addEventListener('change', () => {
    state.filters.category = categoryFilter.value;
    applyFiltersAndSort();
});

sortBySelect.addEventListener('change', () => {
    state.sort.by = sortBySelect.value;
    applyFiltersAndSort();
});

sortDirectionBtn.addEventListener('click', () => {
    state.sort.ascending = !state.sort.ascending;
    sortDirectionBtn.querySelector('i').className = state.sort.ascending 
        ? 'fas fa-sort-up' 
        : 'fas fa-sort-down';
    applyFiltersAndSort();
});

loadMoreBtn.addEventListener('click', () => {
    state.pagination.page++;
    displayBooks(state.filteredBooks);
});

// Debounce function
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Filter and sort books
function applyFiltersAndSort() {
    // Reset pagination
    state.pagination.page = 1;
    
    // Filter books
    state.filteredBooks = state.books.filter(book => {
        // Search filter
        const matchesSearch = state.filters.search === '' || 
            book.title.toLowerCase().includes(state.filters.search) || 
            book.author.toLowerCase().includes(state.filters.search);
        
        // Category filter
        const matchesCategory = state.filters.category === 'all' || 
            book.category === state.filters.category;
        
        // Favorite filter
        const matchesFavorite = !state.filters.favorite || book.favorite === true;
        
        return matchesSearch && matchesCategory && matchesFavorite;
    });
    
    // Sort books
    state.filteredBooks.sort((a, b) => {
        let valueA, valueB;
        
        // Get values to compare based on sort criteria
        if (state.sort.by === 'pages') {
            valueA = a.pages;
            valueB = b.pages;
        } else {
            valueA = a[state.sort.by].toLowerCase();
            valueB = b[state.sort.by].toLowerCase();
        }
        
        // Compare values
        if (valueA < valueB) return state.sort.ascending ? -1 : 1;
        if (valueA > valueB) return state.sort.ascending ? 1 : -1;
        return 0;
    });
    
    // Display filtered and sorted books
    displayBooks(state.filteredBooks);
}

// Simplified fetch books function with XHR for maximum browser compatibility
async function fetchBooks() {
    console.log('Fetching books from API...');
    
    try {
        // Clear any existing books display first
        const booksList = document.getElementById('books-list');
        if (booksList) {
            while (booksList.firstChild) {
                booksList.removeChild(booksList.firstChild);
            }
            
            // Add loading indicator
            const loading = document.createElement('p');
            loading.textContent = 'Loading books...';
            loading.className = 'loading-indicator';
            booksList.appendChild(loading);
        }
        
        // Use our XHR function instead of fetch
        let books = [];
        try {
            books = await xhrRequest(API_URL, 'GET');
            console.log('Received books from API:', books.length);
        } catch (error) {
            console.error('API error:', error);
            books = [];
        }
        
        // Ensure books is an array
        if (!Array.isArray(books)) {
            console.error('Books is not an array, using empty array instead');
            books = [];
        }
        
        // Store in state
        state.books = books;
        
        // Add sample books if needed
        if (state.books.length === 0) {
            console.log('No books found, adding sample books');
            
            const sampleBooks = [
                { title: 'To Kill a Mockingbird', author: 'Harper Lee', pages: 281, category: 'Fiction' },
                { title: '1984', author: 'George Orwell', pages: 328, category: 'Science Fiction' },
                { title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', pages: 180, category: 'Fiction' }
            ];
            
            for (const book of sampleBooks) {
                try {
                    const newBook = await xhrRequest(API_URL + '/', 'POST', book);
                    if (newBook) {
                        state.books.push(newBook);
                    }
                } catch (err) {
                    console.error('Error adding sample book:', err);
                }
            }
        }
        
        // Update filtered books
        state.filteredBooks = [...state.books];
        
        // Remove loading indicator
        if (booksList) {
            while (booksList.firstChild) {
                booksList.removeChild(booksList.firstChild);
            }
        }
        
        // Display books
        displayBooks(state.filteredBooks);
        
    } catch (error) {
        console.error('Error in fetchBooks function:', error);
        showNotification('Error fetching books', 'error');
    }
}

// Browser-compatible display books function
function displayBooks(books) {
    console.log('Display books function called with', books?.length || 0, 'books');
    
    // Get DOM elements
    const booksList = document.getElementById('books-list');
    const shownCountEl = document.getElementById('shown-count');
    const totalCountEl = document.getElementById('total-count');
    const loadMoreBtn = document.getElementById('load-more');
    
    // Safety check for DOM elements
    if (!booksList) {
        console.error('Error: books-list element not found!');
        return;
    }
    
    // Safety check for books array
    if (!Array.isArray(books)) {
        console.error('Books is not an array:', typeof books);
        books = [];
    }
    
    // Start with a clean slate - this is important for browser compatibility
    while (booksList.firstChild) {
        booksList.removeChild(booksList.firstChild);
    }
    
    // Update display counts
    if (totalCountEl) totalCountEl.textContent = books.length;
    
    // Get pagination slice
    const startIndex = 0;
    const endIndex = state.pagination.page * state.pagination.limit;
    const booksToShow = books.slice(startIndex, endIndex);
    
    // Update shown count and load more button
    if (shownCountEl) shownCountEl.textContent = booksToShow.length;
    
    state.pagination.hasMore = endIndex < books.length;
    if (loadMoreBtn) {
        loadMoreBtn.style.display = state.pagination.hasMore ? 'flex' : 'none';
    }
    
    // If no books, show message
    if (books.length === 0) {
        const noBooks = document.createElement('p');
        noBooks.className = 'no-books';
        noBooks.textContent = 'No books found. Try adjusting your filters or add a new book.';
        booksList.appendChild(noBooks);
        return;
    }
    
    // Add book cards one by one
    booksToShow.forEach(book => {
        if (!book || typeof book !== 'object') {
            console.error('Invalid book object:', book);
            return;
        }
        
        // Create book card with pure DOM methods - avoids SVG issues in Brave
        const bookCard = document.createElement('div');
        bookCard.classList.add('book-card');
        if (book.id) {
            bookCard.setAttribute('data-id', book.id);
        }
        
        // If book is favorite, add the indicator
        if (book.favorite) {
            const favIndicator = document.createElement('div');
            favIndicator.className = 'favorite-indicator';
            favIndicator.textContent = '❤️ Favorite';
            bookCard.appendChild(favIndicator);
        }
        
        // Add title
        const titleEl = document.createElement('h3');
        titleEl.className = 'book-title';
        titleEl.textContent = book.title || 'Untitled';
        bookCard.appendChild(titleEl);
        
        // Add author
        const authorEl = document.createElement('p');
        authorEl.className = 'book-author';
        authorEl.textContent = 'by ' + (book.author || 'Unknown');
        bookCard.appendChild(authorEl);
        
        // Add pages info
        const pagesEl = document.createElement('p');
        pagesEl.className = 'book-pages';
        pagesEl.textContent = 'Pages: ' + (book.pages || 0);
        bookCard.appendChild(pagesEl);
        
        // Add price
        const priceEl = document.createElement('p');
        priceEl.className = 'book-price';
        priceEl.textContent = '$' + (book.price || 9.99).toFixed(2);
        bookCard.appendChild(priceEl);
        
        // Add category
        const categoryEl = document.createElement('span');
        categoryEl.className = 'book-category';
        categoryEl.textContent = book.category || 'Fiction';
        bookCard.appendChild(categoryEl);
        
        // Add action buttons
        const actionsDiv = document.createElement('div');
        actionsDiv.className = 'book-actions';
        
        // Favorite button
        const favBtn = document.createElement('button');
        favBtn.className = 'favorite-btn' + (book.favorite ? ' active' : '');
        favBtn.title = 'Toggle favorite';
        favBtn.textContent = '❤️';
        actionsDiv.appendChild(favBtn);
        
        // Buy button
        const buyBtn = document.createElement('button');
        buyBtn.className = 'buy-btn add-to-basket-btn';
        buyBtn.title = 'Add to basket';
        buyBtn.innerHTML = '<i class="fas fa-shopping-cart"></i>';
        actionsDiv.appendChild(buyBtn);
        
        // Send as Gift button
        const giftBtn = document.createElement('button');
        giftBtn.className = 'gift-btn';
        giftBtn.title = 'Send as Gift';
        giftBtn.innerHTML = '<i class="fas fa-gift"></i>';
        giftBtn.textContent = 'Send as Gift';
        actionsDiv.appendChild(giftBtn);
        
        // Edit button
        const editBtn = document.createElement('button');
        editBtn.className = 'edit-btn';
        editBtn.title = 'Edit book';
        editBtn.textContent = '✏️';
        actionsDiv.appendChild(editBtn);
        
        // Delete button
        const deleteBtn = document.createElement('button');
        deleteBtn.className = 'delete-btn';
        deleteBtn.title = 'Delete book';
        deleteBtn.textContent = '🗑️';
        actionsDiv.appendChild(deleteBtn);
        
        bookCard.appendChild(actionsDiv);
        
        // Add event listeners for buttons
        bookCard.querySelector('.favorite-btn').addEventListener('click', (e) => toggleFavorite(e, book));
        bookCard.querySelector('.buy-btn').addEventListener('click', () => addToBasket(book));
        bookCard.querySelector('.gift-btn').addEventListener('click', () => openGiftModal(book));
        bookCard.querySelector('.edit-btn').addEventListener('click', () => openEditModal(book));
        bookCard.querySelector('.delete-btn').addEventListener('click', () => deleteBook(book.id));
        
        booksList.appendChild(bookCard);
    });
}

// Add a new book with XHR
async function addBook(e) {
    e.preventDefault();
    
    // Get form values
    const titleEl = document.getElementById('title');
    const authorEl = document.getElementById('author');
    const pagesEl = document.getElementById('pages');
    const priceEl = document.getElementById('price');
    const categoryEl = document.getElementById('category');
    
    if (!titleEl || !authorEl || !pagesEl || !priceEl || !categoryEl) {
        showNotification('Form elements not found', 'error');
        return;
    }
    
    const title = titleEl.value.trim();
    const author = authorEl.value.trim();
    const pages = parseInt(pagesEl.value);
    const price = parseFloat(priceEl.value);
    const category = categoryEl.value;
    
    // Validate form
    if (!title || !author || isNaN(pages) || pages <= 0 || isNaN(price) || price < 0 || !category) {
        showNotification('Please fill in all fields correctly', 'error');
        return;
    }
    
    // Create book object
    const newBook = { title, author, pages, price, category };
    
    try {
        // Use XHR to add book
        const book = await xhrRequest(API_URL + '/', 'POST', newBook);
        
        if (!book) {
            throw new Error('Failed to add book');
        }
        
        // Reset form
        const form = document.getElementById('book-form');
        if (form) {
            form.reset();
        }
        
        // Show notification and refresh books
        showNotification('Book added successfully!', 'success');
        fetchBooks();
    } catch (error) {
        console.error('Error adding book:', error);
        showNotification('Error adding book', 'error');
    }
}

// Open edit modal with book data
function openEditModal(book) {
    document.getElementById('edit-id').value = book.id;
    document.getElementById('edit-title').value = book.title;
    document.getElementById('edit-author').value = book.author;
    document.getElementById('edit-pages').value = book.pages;
    document.getElementById('edit-price').value = book.price || 9.99;
    
    // Set category if it exists
    if (book.category) {
        document.getElementById('edit-category').value = book.category;
    }
    
    editModal.style.display = 'block';
}

// Close edit modal
function closeModal() {
    editModal.style.display = 'none';
}

// Update book with XHR
async function updateBook(e) {
    e.preventDefault();
    
    // Get form values with validation checks
    const idEl = document.getElementById('edit-id');
    const titleEl = document.getElementById('edit-title');
    const authorEl = document.getElementById('edit-author');
    const pagesEl = document.getElementById('edit-pages');
    const priceEl = document.getElementById('edit-price');
    const categoryEl = document.getElementById('edit-category');
    
    if (!idEl || !titleEl || !authorEl || !pagesEl || !priceEl || !categoryEl) {
        showNotification('Form elements not found', 'error');
        return;
    }
    
    const id = idEl.value;
    const title = titleEl.value.trim();
    const author = authorEl.value.trim();
    const pages = parseInt(pagesEl.value);
    const price = parseFloat(priceEl.value);
    const category = categoryEl.value;
    
    // Validate form values
    if (!id || !title || !author || isNaN(pages) || pages <= 0 || isNaN(price) || price < 0 || !category) {
        showNotification('Please fill in all fields correctly', 'error');
        return;
    }
    
    // Create updated book object
    const updatedBook = { title, author, pages, price, category };
    
    try {
        // Use XHR to update the book
        const result = await xhrRequest(`${API_URL}/${id}`, 'PUT', updatedBook);
        
        if (!result) {
            throw new Error('Failed to update book');
        }
        
        // Close modal
        closeModal();
        
        // Show success notification and refresh book list
        showNotification('Book updated successfully!', 'success');
        fetchBooks();
    } catch (error) {
        console.error('Error updating book:', error);
        showNotification('Error updating book', 'error');
    }
}

// Delete book with XHR
async function deleteBook(id) {
    // Confirm deletion
    if (!id || !confirm('Are you sure you want to delete this book?')) {
        return;
    }
    
    try {
        // Use XHR to delete the book
        const result = await xhrRequest(`${API_URL}/${id}`, 'DELETE');
        
        // Refresh book list and show confirmation
        fetchBooks();
        showNotification('Book deleted successfully!', 'success');
    } catch (error) {
        console.error('Error deleting book:', error);
        showNotification('Error deleting book', 'error');
    }
}

// Shopping basket state and functionality
let basketState = {
    items: [],
    total: 0
};

// Initialize basket on page load
async function initializeBasket() {
    await fetchBasket();
    setupBasketEventListeners();
}

// Fetch current basket from API
async function fetchBasket() {
    try {
        const basket = await xhrRequest('/basket/', 'GET');
        basketState = basket;
        updateBasketUI();
    } catch (error) {
        console.error('Error fetching basket:', error);
    }
}

// Update basket UI elements
function updateBasketUI() {
    const basketCount = document.getElementById('basket-count');
    if (basketCount) {
        const itemCount = basketState.items ? basketState.items.reduce((sum, item) => sum + item.quantity, 0) : 0;
        basketCount.textContent = itemCount;
    }
}

// Add book to basket
async function addToBasket(book) {
    try {
        const response = await xhrRequest('/basket/add', 'POST', {
            book_id: book.id,
            quantity: 1
        });
        
        basketState = response;
        updateBasketUI();
        showNotification(`"${book.title}" added to basket!`, 'success');
    } catch (error) {
        console.error('Error adding to basket:', error);
        showNotification('Error adding book to basket', 'error');
    }
}

// Open basket modal
function openBasketModal() {
    const modal = document.getElementById('basket-modal');
    if (modal) {
        displayBasketItems();
        modal.style.display = 'block';
    }
}

// Display basket items in modal
function displayBasketItems() {
    const basketItems = document.getElementById('basket-items');
    const totalAmount = document.getElementById('basket-total-amount');
    
    if (!basketItems) return;
    
    // Clear existing items
    basketItems.innerHTML = '';
    
    if (!basketState.items || basketState.items.length === 0) {
        basketItems.innerHTML = '<p class="no-items">Your basket is empty</p>';
        if (totalAmount) totalAmount.textContent = '0.00';
        return;
    }
    
    // Display each item
    basketState.items.forEach(item => {
        const itemEl = document.createElement('div');
        itemEl.className = 'basket-item';
        
        const itemPrice = (item.book.price * item.quantity).toFixed(2);
        
        itemEl.innerHTML = `
            <div class="basket-item-info">
                <div class="basket-item-title">${item.book.title}</div>
                <div class="basket-item-author">by ${item.book.author}</div>
            </div>
            <span class="basket-item-quantity">Qty: ${item.quantity}</span>
            <span class="basket-item-price">$${itemPrice}</span>
            <button class="basket-item-remove" onclick="removeFromBasket(${item.id})">
                <i class="fas fa-times"></i>
            </button>
        `;
        
        basketItems.appendChild(itemEl);
    });
    
    // Update total
    if (totalAmount) {
        totalAmount.textContent = basketState.total ? basketState.total.toFixed(2) : '0.00';
    }
}

// Remove item from basket
async function removeFromBasket(itemId) {
    try {
        const response = await xhrRequest(`/basket/item/${itemId}`, 'DELETE');
        basketState = response;
        updateBasketUI();
        displayBasketItems();
        showNotification('Item removed from basket', 'success');
    } catch (error) {
        console.error('Error removing from basket:', error);
        showNotification('Error removing item', 'error');
    }
}

// Clear basket
async function clearBasket() {
    if (!confirm('Are you sure you want to clear your basket?')) return;
    
    try {
        await xhrRequest('/basket/clear', 'DELETE');
        basketState = { items: [], total: 0 };
        updateBasketUI();
        displayBasketItems();
        showNotification('Basket cleared', 'success');
    } catch (error) {
        console.error('Error clearing basket:', error);
        showNotification('Error clearing basket', 'error');
    }
}

// Complete purchase
async function completePurchase() {
    try {
        const purchase = await xhrRequest('/basket/purchase', 'POST');
        
        // Show purchase confirmation
        showPurchaseConfirmation(purchase);
        
        // Close basket modal
        document.getElementById('basket-modal').style.display = 'none';
        
        // Reset basket state
        basketState = { items: [], total: 0 };
        updateBasketUI();
        
    } catch (error) {
        console.error('Error completing purchase:', error);
        showNotification('Error completing purchase', 'error');
    }
}

// Show purchase confirmation modal
function showPurchaseConfirmation(purchase) {
    const modal = document.getElementById('purchase-modal');
    const summary = document.getElementById('purchase-summary');
    
    if (!modal || !summary) return;
    
    // Create purchase summary
    let summaryHTML = '<h3>Order Summary</h3>';
    purchase.items.forEach(item => {
        summaryHTML += `
            <div class="purchase-item">
                <span>${item.book.title} (x${item.quantity})</span>
                <span>$${(item.book.price * item.quantity).toFixed(2)}</span>
            </div>
        `;
    });
    summaryHTML += `<div class="total">Total: $${purchase.total.toFixed(2)}</div>`;
    
    summary.innerHTML = summaryHTML;
    modal.style.display = 'block';
}

// Setup basket event listeners
function setupBasketEventListeners() {
    // Shopping basket button
    const basketBtn = document.getElementById('shopping-basket-btn');
    if (basketBtn) {
        basketBtn.addEventListener('click', openBasketModal);
    }
    
    // Basket modal close button
    const closeBasket = document.getElementById('close-basket');
    if (closeBasket) {
        closeBasket.addEventListener('click', () => {
            document.getElementById('basket-modal').style.display = 'none';
        });
    }
    
    // Clear basket button
    const clearBtn = document.getElementById('clear-basket-btn');
    if (clearBtn) {
        clearBtn.addEventListener('click', clearBasket);
    }
    
    // Buy now button
    const buyNowBtn = document.getElementById('buy-now-btn');
    if (buyNowBtn) {
        buyNowBtn.addEventListener('click', completePurchase);
    }
    
    // Purchase modal close buttons
    const closePurchase = document.getElementById('close-purchase');
    const closePurchaseBtn = document.getElementById('close-purchase-btn');
    
    if (closePurchase) {
        closePurchase.addEventListener('click', () => {
            document.getElementById('purchase-modal').style.display = 'none';
        });
    }
    
    if (closePurchaseBtn) {
        closePurchaseBtn.addEventListener('click', () => {
            document.getElementById('purchase-modal').style.display = 'none';
        });
    }
    
    // Close modals when clicking outside
    window.addEventListener('click', (e) => {
        const basketModal = document.getElementById('basket-modal');
        const purchaseModal = document.getElementById('purchase-modal');
        
        if (e.target === basketModal) {
            basketModal.style.display = 'none';
        }
        if (e.target === purchaseModal) {
            purchaseModal.style.display = 'none';
        }
    });
}

// Toggle book favorite status with XHR
async function toggleFavorite(event, book) {
    const button = event.currentTarget;
    const newFavoriteStatus = !book.favorite;
    
    try {
        // Use our XHR function
        const updatedBook = await xhrRequest(
            `${API_URL}/${book.id}/favorite`, 
            'PATCH',
            { favorite: newFavoriteStatus }
        );
        
        if (!updatedBook) {
            throw new Error('Failed to update favorite status');
        }
        
        // Update book in state
        const bookIndex = state.books.findIndex(b => b.id === book.id);
        if (bookIndex !== -1) {
            state.books[bookIndex].favorite = updatedBook.favorite;
        }
        
        // Update UI - toggle active class
        if (button) {
            if (updatedBook.favorite) {
                button.classList.add('active');
            } else {
                button.classList.remove('active');
            }
        }
        
        // Update favorite indicator
        if (button) {
            const bookCard = button.closest('.book-card');
            if (bookCard) {
                // Look for existing indicator
                const existingIndicator = bookCard.querySelector('.favorite-indicator');
                
                if (updatedBook.favorite && !existingIndicator) {
                    // Create and add favorite indicator
                    const indicator = document.createElement('div');
                    indicator.className = 'favorite-indicator';
                    indicator.textContent = '❤️ Favorite';
                    bookCard.insertBefore(indicator, bookCard.firstChild);
                } else if (!updatedBook.favorite && existingIndicator) {
                    // Remove favorite indicator
                    existingIndicator.remove();
                }
            }
        }
        
        // Show notification
        showNotification(`Book ${updatedBook.favorite ? 'added to' : 'removed from'} favorites`, 'success');
    } catch (error) {
        console.error('Error toggling favorite:', error);
        showNotification('Error updating favorite status', 'error');
    }
}

// Show notification
function showNotification(message, type) {
    // Check if a notification already exists and remove it
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }
    
    // Create notification element
    const notification = document.createElement('div');
    notification.classList.add('notification', type);
    notification.textContent = message;
    
    // Add notification to body
    document.body.appendChild(notification);
    
    // Remove notification after 3 seconds
    setTimeout(() => {
        notification.classList.add('hide');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}

// Add notification styles
const notificationStyles = document.createElement('style');
notificationStyles.innerHTML = `
    .notification {
        position: fixed;
        top: 1rem;
        right: 1rem;
        padding: 0.75rem 1.5rem;
        border-radius: 4px;
        color: white;
        font-weight: 500;
        box-shadow: 0 3px 8px rgba(0, 0, 0, 0.2);
        z-index: 1001;
        transition: all 0.3s ease;
    }
    
    .notification.success {
        background-color: #28a745;
    }
    
    .notification.error {
        background-color: #dc3545;
    }
    
    .notification.hide {
        opacity: 0;
        transform: translateY(-10px);
    }
    
    .no-books {
        text-align: center;
        color: #6c757d;
        font-style: italic;
        padding: 2rem 0;
    }
`;

// Gift modal functionality
let currentGiftBook = null;

function openGiftModal(book) {
    currentGiftBook = book;
    const modal = document.getElementById('gift-modal');
    const bookInfo = document.getElementById('gift-book-info');
    
    // Display book information
    bookInfo.innerHTML = `
        <div class="selected-book">
            <h3>${book.title}</h3>
            <p>by ${book.author}</p>
            <p>Category: ${book.category}</p>
            <p>Price: $${book.price}</p>
        </div>
    `;
    
    // Reset form and messages
    document.getElementById('gift-form').reset();
    document.getElementById('gift-message').style.display = 'none';
    document.getElementById('confirm-details-btn').style.display = 'inline-block';
    document.getElementById('confirm-gift-order-btn').style.display = 'none';
    
    modal.style.display = 'block';
}

function confirmGiftDetails() {
    const recipientName = document.getElementById('recipient_name').value.trim();
    const recipientAddress = document.getElementById('recipient_address').value.trim();
    const recipientCountry = document.getElementById('recipient_country').value.trim();
    const dataConsent = document.getElementById('data-consent').checked;
    
    if (!recipientName || !recipientAddress || !recipientCountry) {
        showGiftMessage('details are incomplete', 'error');
        return;
    }
    
    // Check GDPR consent
    if (!dataConsent) {
        showGiftMessage('explicit consent is required to process recipient data', 'error');
        return;
    }
    
    // Show confirmation message
    showGiftMessage('book will be sent as a gift', 'confirmation');
    
    // Show the confirm order button
    document.getElementById('confirm-details-btn').style.display = 'none';
    document.getElementById('confirm-gift-order-btn').style.display = 'inline-block';
}

async function confirmGiftOrder() {
    if (!currentGiftBook) {
        showGiftMessage('No book selected', 'error');
        return;
    }
    
    const recipientName = document.getElementById('recipient_name').value.trim();
    const recipientAddress = document.getElementById('recipient_address').value.trim();
    const recipientCountry = document.getElementById('recipient_country').value.trim();
    const dataConsent = document.getElementById('data-consent').checked;
    
    const giftData = {
        book_id: currentGiftBook.id,
        recipient_name: recipientName,
        recipient_address: recipientAddress,
        recipient_country: recipientCountry,
        consent_given: dataConsent
    };
    
    try {
        const response = await xhrRequest('/gifts/', 'POST', giftData);
        if (response) {
            showGiftMessage('added to the gift orders queue', 'success');
            showGiftMessage('email confirmation', 'info');
            
            // Close modal after successful order
            setTimeout(() => {
                closeGiftModal();
            }, 2000);
        }
    } catch (error) {
        console.error('Error creating gift order:', error);
        if (error.status === 400) {
            showGiftMessage('explicit consent is required to process recipient data', 'error');
        } else {
            showGiftMessage('book is out of stock', 'error');
        }
    }
}

function showGiftMessage(message, type) {
    const messageDiv = document.getElementById('gift-message');
    messageDiv.className = `gift-message ${type}-message`;
    messageDiv.textContent = message;
    messageDiv.style.display = 'block';
}

function closeGiftModal() {
    const modal = document.getElementById('gift-modal');
    modal.style.display = 'none';
    currentGiftBook = null;
}

// Add event listeners when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Gift modal event listeners
    const giftModal = document.getElementById('gift-modal');
    const closeGiftBtn = document.getElementById('close-gift');
    const confirmDetailsBtn = document.getElementById('confirm-details-btn');
    const confirmOrderBtn = document.getElementById('confirm-gift-order-btn');
    
    if (closeGiftBtn) {
        closeGiftBtn.addEventListener('click', closeGiftModal);
    }
    
    if (confirmDetailsBtn) {
        confirmDetailsBtn.addEventListener('click', confirmGiftDetails);
    }
    
    if (confirmOrderBtn) {
        confirmOrderBtn.addEventListener('click', confirmGiftOrder);
    }
    
    // Close modal when clicking outside
    if (giftModal) {
        giftModal.addEventListener('click', function(e) {
            if (e.target === giftModal) {
                closeGiftModal();
            }
        });
    }
    
    // GDPR Rights modal event listeners
    const gdprRightsModal = document.getElementById('gdpr-rights-modal');
    const closeGdprRightsBtn = document.getElementById('close-gdpr-rights');
    
    if (closeGdprRightsBtn) {
        closeGdprRightsBtn.addEventListener('click', closeGDPRRightsModal);
    }
    
    if (gdprRightsModal) {
        gdprRightsModal.addEventListener('click', function(e) {
            if (e.target === gdprRightsModal) {
                closeGDPRRightsModal();
            }
        });
    }
});

// GDPR Rights Functions
function showGDPRRights() {
    const modal = document.getElementById('gdpr-rights-modal');
    modal.style.display = 'block';
}

function closeGDPRRightsModal() {
    const modal = document.getElementById('gdpr-rights-modal');
    modal.style.display = 'none';
    const responseArea = document.getElementById('gdpr-response');
    responseArea.style.display = 'none';
    responseArea.innerHTML = '';
}

function showGDPRResponse(content) {
    const responseArea = document.getElementById('gdpr-response');
    responseArea.innerHTML = content;
    responseArea.style.display = 'block';
}

async function requestDataAccess() {
    const identifier = prompt('Please enter your name or email address to find your data:');
    if (!identifier) return;
    
    try {
        const response = await xhrRequest('/gifts/gdpr/access', 'POST', {
            request_type: 'access',
            subject_identifier: identifier
        });
        
        if (response && response.length > 0) {
            let content = '<h3>Your Personal Data</h3><div class="data-export">';
            response.forEach(gift => {
                content += `
                    <div class="gift-data">
                        <p><strong>Gift Order #${gift.id}</strong></p>
                        <p>Status: ${gift.status}</p>
                        <p>Created: ${new Date(gift.created_at).toLocaleDateString()}</p>
                        <p>Data will be deleted: ${new Date(gift.data_retention_until).toLocaleDateString()}</p>
                        ${gift.recipient_data ? `
                            <p>Recipient: ${gift.recipient_data.name}</p>
                            <p>Address: ${gift.recipient_data.address}</p>
                            <p>Country: ${gift.recipient_data.country}</p>
                        ` : ''}
                    </div>
                `;
            });
            content += '</div>';
            showGDPRResponse(content);
        } else {
            showGDPRResponse('<p>No personal data found for that identifier.</p>');
        }
    } catch (error) {
        showGDPRResponse('<p>Error retrieving your data. Please contact privacy@bookbridge.com</p>');
    }
}

async function requestDataCorrection() {
    const giftId = prompt('Please enter the Gift Order ID you want to correct:');
    if (!giftId) return;
    
    const name = prompt('New recipient name:');
    const address = prompt('New recipient address:');
    const country = prompt('New recipient country:');
    
    if (!name || !address || !country) {
        alert('All fields are required for data correction.');
        return;
    }
    
    try {
        const response = await xhrRequest(`/gifts/gdpr/rectify/${giftId}`, 'PUT', {
            book_id: 1, // This would need to be provided or looked up
            recipient_name: name,
            recipient_address: address,
            recipient_country: country,
            consent_given: true
        });
        
        showGDPRResponse('<p>Your data has been successfully corrected.</p>');
    } catch (error) {
        showGDPRResponse('<p>Error correcting your data. Please contact privacy@bookbridge.com</p>');
    }
}

async function requestDataDeletion() {
    const giftId = prompt('Please enter the Gift Order ID you want to delete:');
    if (!giftId) return;
    
    const confirmed = confirm('Are you sure you want to permanently delete this gift order and all associated personal data? This action cannot be undone.');
    if (!confirmed) return;
    
    try {
        const response = await xhrRequest(`/gifts/gdpr/erase/${giftId}`, 'DELETE');
        showGDPRResponse('<p>Your personal data has been permanently deleted.</p>');
    } catch (error) {
        showGDPRResponse('<p>Error deleting your data. Please contact privacy@bookbridge.com</p>');
    }
}

async function withdrawConsent() {
    const giftId = prompt('Please enter the Gift Order ID for which you want to withdraw consent:');
    if (!giftId) return;
    
    const confirmed = confirm('Withdrawing consent will schedule your data for deletion within 30 days. Do you want to continue?');
    if (!confirmed) return;
    
    try {
        const response = await xhrRequest(`/gifts/gdpr/consent/${giftId}`, 'PUT', {
            consent_given: false,
            consent_timestamp: new Date().toISOString()
        });
        
        showGDPRResponse('<p>Your consent has been withdrawn. Your data will be deleted within 30 days.</p>');
    } catch (error) {
        showGDPRResponse('<p>Error withdrawing consent. Please contact privacy@bookbridge.com</p>');
    }
}

async function viewRetentionInfo() {
    try {
        const response = await xhrRequest('/gifts/gdpr/retention-info', 'GET');
        
        if (response && response.length > 0) {
            let content = '<h3>Data Retention Information</h3><div class="retention-info">';
            response.forEach(info => {
                content += `
                    <div class="retention-item">
                        <p><strong>Gift Order #${info.gift_id}</strong></p>
                        <p>Created: ${new Date(info.created_at).toLocaleDateString()}</p>
                        <p>Will be deleted: ${new Date(info.retention_until).toLocaleDateString()}</p>
                        <p>Days remaining: ${info.days_remaining}</p>
                        <p>Auto-delete: ${info.auto_delete_enabled ? 'Enabled' : 'Disabled'}</p>
                    </div>
                `;
            });
            content += '</div>';
            showGDPRResponse(content);
        } else {
            showGDPRResponse('<p>No data retention information available.</p>');
        }
    } catch (error) {
        showGDPRResponse('<p>Error retrieving retention information. Please contact privacy@bookbridge.com</p>');
    }
}

document.head.appendChild(notificationStyles);