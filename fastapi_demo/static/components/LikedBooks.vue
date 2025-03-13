<template>
<template>
  <div class="liked-books">
    <h2>Liked Books</h2>
    <div v-if="books.length === 0" class="no-books">
      You have not liked any books yet.
    </div>
    <ul v-else>
      <li v-for="book in books" :key="book.id" class="book-item">
        <img :src="book.coverImage" alt="Cover Image" class="book-cover" />
        <div class="book-info">
          <h3>{{ book.title }}</h3>
          <p>by {{ book.author }}</p>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      books: [],
    };
  },
  async created() {
    try {
      const response = await fetch('/books/liked');
      if (!response.ok) {
        throw new Error('Failed to fetch liked books');
      }
      this.books = await response.json();
    } catch (error) {
      console.error('Error fetching liked books:', error);
    }
  },
};
</script>

<style scoped>
.liked-books {
  padding: 1rem;
}

.no-books {
  text-align: center;
  color: #6c757d;
  font-style: italic;
}

.book-item {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}

.book-cover {
  width: 50px;
  height: 75px;
  margin-right: 1rem;
}

.book-info h3 {
  margin: 0;
  font-size: 1.2rem;
}

.book-info p {
  margin: 0;
  color: #6c757d;
}
</style>
