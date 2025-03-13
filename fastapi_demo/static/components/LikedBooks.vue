<template>
<template>
    <div>
        <h2>Liked Books</h2>
        <div v-if="likedBooks.length === 0" class="no-books">
            You have not liked any books yet.
        </div>
        <div v-else>
            <div v-for="book in likedBooks" :key="book.id" class="book-card">
                <h3>{{ book.title }}</h3>
                <p>by {{ book.author }}</p>
                <img :src="book.cover_image" alt="Cover Image" class="cover-image"/>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            likedBooks: []
        };
    },
    created() {
        this.fetchLikedBooks();
    },
    methods: {
        async fetchLikedBooks() {
            try {
                const response = await fetch('/books/liked');
                if (!response.ok) {
                    throw new Error('Failed to fetch liked books');
                }
                this.likedBooks = await response.json();
            } catch (error) {
                console.error('Error fetching liked books:', error);
            }
        }
    }
};
</script>

<style scoped>
.no-books {
    text-align: center;
    color: #6c757d;
    font-style: italic;
    padding: 2rem 0;
}

.book-card {
    border: 1px solid #ddd;
    padding: 1rem;
    margin-bottom: 1rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.cover-image {
    max-width: 100px;
    height: auto;
    display: block;
    margin: 0.5rem 0;
}
</style>
