<template>
<template>
  <div class="liked-books">
    <h2>Liked Books</h2>
    <div v-if="likedBooks.length === 0" class="no-liked-books">
      <p>You have not liked any books yet.</p>
    </div>
    <div v-else class="books-list">
      <div v-for="book in likedBooks" :key="book.id" class="book-item">
        <img :src="book.cover_image" alt="Cover Image" class="book-cover" />
        <div class="book-info">
          <h3>{{ book.title }}</h3>
          <p>by {{ book.author }}</p>
        </div>
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
.liked-books {
  padding: 1rem;
}

.no-liked-books {
  text-align: center;
  color: #6c757d;
  font-style: italic;
}

.books-list {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.book-item {
  background-color: #fff;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1rem;
  width: 200px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.book-cover {
  width: 100%;
  height: auto;
  border-radius: 4px;
}

.book-info {
  margin-top: 0.5rem;
}

.book-info h3 {
  font-size: 1.1rem;
  margin-bottom: 0.3rem;
}

.book-info p {
  color: #6c757d;
  font-size: 0.9rem;
}
</style>
