Vue.component('comments-section', {
    data() {
        return {
            comments: [],
            newComment: '',
            errorMessage: '',
            bookId: 1, // Assuming bookId is 1 for demo purposes
            userId: 1  // Assuming userId is 1 for demo purposes
        };
    },
    mounted() {
        this.fetchComments();
    },
    methods: {
        async fetchComments() {
            try {
                const response = await fetch(`/books/${this.bookId}/comments`);
                if (!response.ok) throw new Error('Failed to fetch comments');
                const newComments = await response.json();
                this.comments = newComments;
            } catch (error) {
                console.error(error);
                this.errorMessage = 'Error fetching comments';
            }
        },
        async submitComment() {
            if (!this.newComment.trim()) {
                this.errorMessage = 'Comment cannot be empty';
                return;
            }
            try {
                const response = await fetch(`/books/${this.bookId}/comments`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ book_id: this.bookId, user_id: this.userId, content: this.newComment })
                });
                if (!response.ok) throw new Error('Failed to add comment');
                const comment = await response.json();
                this.comments.push(comment);
                this.newComment = '';
                this.errorMessage = '';
            } catch (error) {
                console.error(error);
                this.errorMessage = 'Error adding comment';
            }
        }
    },
    template: `
        <div class="comments-section">
            <h2>Comments</h2>
            <div v-if="errorMessage" class="error">{{ errorMessage }}</div>
            <ul id="comments-list">
                <li v-for="comment in comments" :key="comment.id">{{ comment.content }}</li>
            </ul>
            <form @submit.prevent="submitComment">
                <div class="form-group">
                    <label for="comment-content">Leave a Comment</label>
                    <textarea v-model="newComment" required></textarea>
                </div>
                <button type="submit" class="btn"><i class="fas fa-comment"></i> Submit Comment</button>
            </form>
        </div>
    `
});

new Vue({
    el: '#app'
});
