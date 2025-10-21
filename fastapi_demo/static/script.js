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
document.addEventListener('DOMContentLoaded', fetchBooks);
bookForm.addEventListener('submit', addBook);
editForm.addEventListener('submit', updateBook);
closeModalBtn.addEventListener('click', closeModal);
window.addEventListener('click', (e) => {
    if (e.target === editModal) {
        closeModal();
    }
});

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
            ${book.favorite ? '<div class="favorite-indicator"><svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="heart" class="svg-inline--fa fa-heart" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"></path></svg> Favorite</div>' : ''}
            <h3 class="book-title">${book.title}</h3>
            <p class="book-author">by ${book.author}</p>
            <p class="book-pages">
                <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="file-alt" class="svg-inline--fa fa-file-alt" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512"><path fill="currentColor" d="M224 136V0H24C10.7 0 0 10.7 0 24v464c0 13.3 10.7 24 24 24h336c13.3 0 24-10.7 24-24V160H248c-13.2 0-24-10.8-24-24zm64 236c0 6.6-5.4 12-12 12H108c-6.6 0-12-5.4-12-12v-8c0-6.6 5.4-12 12-12h168c6.6 0 12 5.4 12 12v8zm0-64c0 6.6-5.4 12-12 12H108c-6.6 0-12-5.4-12-12v-8c0-6.6 5.4-12 12-12h168c6.6 0 12 5.4 12 12v8zm0-72v8c0 6.6-5.4 12-12 12H108c-6.6 0-12-5.4-12-12v-8c0-6.6 5.4-12 12-12h168c6.6 0 12 5.4 12 12z"></path></svg>
                Pages: ${book.pages}
            </p>
            <span class="book-category">${book.category || 'Fiction'}</span>
            <div class="book-actions">
                <button class="favorite-btn ${book.favorite ? 'active' : ''}" title="Toggle favorite">
                    <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="heart" class="svg-inline--fa fa-heart" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"></path></svg>
                </button>
                <button class="edit-btn" title="Edit book">
                    <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="edit" class="svg-inline--fa fa-edit" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512"><path fill="currentColor" d="M402.6 83.2l90.2 90.2c3.8 3.8 3.8 10 0 13.8L274.4 405.6l-92.8 10.3c-12.4 1.4-22.9-9.1-21.5-21.5l10.3-92.8L388.8 83.2c3.8-3.8 10-3.8 13.8 0zm162-22.9l-48.8-48.8c-15.2-15.2-39.9-15.2-55.2 0l-35.4 35.4c-3.8 3.8-3.8 10 0 13.8l90.2 90.2c3.8 3.8 10 3.8 13.8 0l35.4-35.4c15.2-15.3 15.2-40 0-55.2zM384 346.2V448H64V128h229.8c3.2 0 6.2-1.3 8.5-3.5l40-40c7.6-7.6 2.2-20.5-8.5-20.5H48C21.5 64 0 85.5 0 112v352c0 26.5 21.5 48 48 48h352c26.5 0 48-21.5 48-48V306.2c0-10.7-12.9-16-20.5-8.5l-40 40c-2.2 2.3-3.5 5.3-3.5 8.5z"></path></svg>
                </button>
                <button class="delete-btn" title="Delete book">
                    <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="trash" class="svg-inline--fa fa-trash" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path fill="currentColor" d="M432 32H312l-9.4-18.7A24 24 0 0 0 281.1 0H166.8a23.72 23.72 0 0 0-21.4 13.3L136 32H16A16 16 0 0 0 0 48v32a16 16 0 0 0 16 16h416a16 16 0 0 0 16-16V48a16 16 0 0 0-16-16zM53.2 467a48 48 0 0 0 47.9 45h245.8a48 48 0 0 0 47.9-45L416 128H32z"></path></svg>
                </button>
            </div>
        `;
        
        // Add event listeners for buttons
        bookCard.querySelector('.favorite-btn').addEventListener('click', (e) => toggleFavorite(e, book));
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

// Toggle book favorite status
async function toggleFavorite(event, book) {
    const button = event.currentTarget;
    const newFavoriteStatus = !book.favorite;
    
    try {
        const response = await fetch(`${API_URL}/${book.id}/favorite`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ favorite: newFavoriteStatus })
        });
        
        if (!response.ok) {
            throw new Error('Failed to update favorite status');
        }
        
        const updatedBook = await response.json();
        
        // Update book in state
        const bookIndex = state.books.findIndex(b => b.id === book.id);
        if (bookIndex !== -1) {
            state.books[bookIndex].favorite = updatedBook.favorite;
        }
        
        // Update UI 
        button.classList.toggle('active', updatedBook.favorite);
        
        // Update favorite indicator in the book card
        const bookCard = button.closest('.book-card');
        const existingIndicator = bookCard.querySelector('.favorite-indicator');
        
        if (updatedBook.favorite && !existingIndicator) {
            // Add favorite indicator
            const indicator = document.createElement('div');
            indicator.className = 'favorite-indicator';
            // Use a text + SVG fallback for better browser compatibility
            indicator.innerHTML = '<svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="heart" class="svg-inline--fa fa-heart" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"></path></svg> Favorite';
            bookCard.insertBefore(indicator, bookCard.firstChild);
        } else if (!updatedBook.favorite && existingIndicator) {
            // Remove favorite indicator
            existingIndicator.remove();
        }
        
        // Show notification
        showNotification(`Book ${updatedBook.favorite ? 'added to' : 'removed from'} favorites`, 'success');
    } catch (error) {
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
document.head.appendChild(notificationStyles);