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

// API Base URL
const API_URL = '/books';

// App State
const state = {
    books: [],
    filteredBooks: [],
    filters: {
        search: '',
        category: 'all'
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
document.addEventListener('DOMContentLoaded', fetchBooks);
bookForm.addEventListener('submit', addBook);
editForm.addEventListener('submit', updateBook);
closeModalBtn.addEventListener('click', closeModal);
window.addEventListener('click', (e) => {
    if (e.target === editModal) {
        closeModal();
    }
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
        
        return matchesSearch && matchesCategory;
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

// Fetch all books from API
async function fetchBooks() {
    try {
        const response = await fetch(API_URL);
        
        if (!response.ok) {
            throw new Error('Failed to fetch books');
        }
        
        state.books = await response.json();
        
        // Add sample books if no books exist
        if (state.books.length === 0) {
            console.log('No books found, adding sample books...');
            
            // Add sample books
            const sampleBooks = [
                { title: 'To Kill a Mockingbird', author: 'Harper Lee', pages: 281, category: 'Fiction' },
                { title: '1984', author: 'George Orwell', pages: 328, category: 'Science Fiction' },
                { title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', pages: 180, category: 'Fiction' }
            ];
            
            for (const book of sampleBooks) {
                const bookResponse = await fetch(API_URL + '/', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(book)
                });
                
                if (bookResponse.ok) {
                    const newBook = await bookResponse.json();
                    state.books.push(newBook);
                }
            }
        }
        
        // Initialize filtered books
        state.filteredBooks = [...state.books];
        
        // Display books
        displayBooks(state.filteredBooks);
    } catch (error) {
        console.error('Error fetching books:', error);
        showNotification('Error fetching books', 'error');
    }
}

// Display books in the UI
function displayBooks(books) {
    // Update counts
    totalCountEl.textContent = state.filteredBooks.length;
    
    // Apply pagination
    const startIndex = 0;
    const endIndex = state.pagination.page * state.pagination.limit;
    const booksToShow = books.slice(startIndex, endIndex);
    
    // Update shown count
    shownCountEl.textContent = booksToShow.length;
    
    // Show/hide load more button
    state.pagination.hasMore = endIndex < books.length;
    loadMoreBtn.style.display = state.pagination.hasMore ? 'flex' : 'none';
    
    // Clear book list if on first page
    if (state.pagination.page === 1) {
        booksList.innerHTML = '';
    }
    
    if (books.length === 0) {
        booksList.innerHTML = '<p class="no-books">No books found. Try adjusting your filters or add a new book.</p>';
        return;
    }
    
    booksToShow.forEach(book => {
        // Skip if book card already exists
        if (state.pagination.page > 1 && document.querySelector(`.book-card[data-id="${book.id}"]`)) {
            return;
        }
        
        const bookCard = document.createElement('div');
        bookCard.classList.add('book-card');
        bookCard.dataset.id = book.id;
        
        bookCard.innerHTML = `
            <h3 class="book-title">${book.title}</h3>
            <p class="book-author">by ${book.author}</p>
            <p class="book-pages"><i class="fas fa-file-alt"></i> Pages: ${book.pages}</p>
            <span class="book-category">${book.category || 'Fiction'}</span>
            <div class="book-actions">
                <button class="edit-btn" title="Edit book"><i class="fas fa-edit"></i></button>
                <button class="delete-btn" title="Delete book"><i class="fas fa-trash"></i></button>
            </div>
        `;
        
        // Add event listeners for edit and delete buttons
        bookCard.querySelector('.edit-btn').addEventListener('click', () => openEditModal(book));
        bookCard.querySelector('.delete-btn').addEventListener('click', () => deleteBook(book.id));
        
        booksList.appendChild(bookCard);
    });
}

// Add a new book
async function addBook(e) {
    e.preventDefault();
    
    const title = document.getElementById('title').value.trim();
    const author = document.getElementById('author').value.trim();
    const pages = parseInt(document.getElementById('pages').value);
    const category = document.getElementById('category').value;
    
    if (!title || !author || !pages || !category) {
        showNotification('Please fill in all fields', 'error');
        return;
    }
    
    const newBook = { title, author, pages, category };
    
    try {
        const response = await fetch(API_URL + '/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(newBook)
        });
        
        if (!response.ok) {
            throw new Error('Failed to add book');
        }
        
        const book = await response.json();
        
        // Reset form
        bookForm.reset();
        
        // Fetch and display all books after adding
        fetchBooks();
        showNotification('Book added successfully!', 'success');
    } catch (error) {
        showNotification('Error adding book', 'error');
    }
}

// Open edit modal with book data
function openEditModal(book) {
    document.getElementById('edit-id').value = book.id;
    document.getElementById('edit-title').value = book.title;
    document.getElementById('edit-author').value = book.author;
    document.getElementById('edit-pages').value = book.pages;
    
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

// Update book
async function updateBook(e) {
    e.preventDefault();
    
    const id = document.getElementById('edit-id').value;
    const title = document.getElementById('edit-title').value.trim();
    const author = document.getElementById('edit-author').value.trim();
    const pages = parseInt(document.getElementById('edit-pages').value);
    const category = document.getElementById('edit-category').value;
    
    if (!title || !author || !pages || !category) {
        showNotification('Please fill in all fields', 'error');
        return;
    }
    
    const updatedBook = { title, author, pages, category };
    
    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(updatedBook)
        });
        
        if (!response.ok) {
            throw new Error('Failed to update book');
        }
        
        // Close modal
        closeModal();
        
        // Fetch and display all books after updating
        fetchBooks();
        
        showNotification('Book updated successfully!', 'success');
    } catch (error) {
        showNotification('Error updating book', 'error');
    }
}

// Delete book
async function deleteBook(id) {
    if (!confirm('Are you sure you want to delete this book?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) {
            throw new Error('Failed to delete book');
        }
        
        // Fetch and display all books after deleting
        fetchBooks();
        
        showNotification('Book deleted successfully!', 'success');
    } catch (error) {
        showNotification('Error deleting book', 'error');
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
document.head.appendChild(notificationStyles);