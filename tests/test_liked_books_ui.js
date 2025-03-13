import { mount } from '@vue/test-utils';
import LikedBooks from '../fastapi_demo/static/components/LikedBooks.vue';

describe('LikedBooks.vue', () => {
    it('displays a list of liked books', async () => {
        const wrapper = mount(LikedBooks, {
            data() {
                return {
                    likedBooks: [
                        { id: 1, title: 'Book 1', author: 'Author 1', cover_image: 'cover1.jpg' },
                        { id: 2, title: 'Book 2', author: 'Author 2', cover_image: 'cover2.jpg' }
                    ]
                };
            }
        });

        await wrapper.vm.$nextTick();

        const bookTitles = wrapper.findAll('.book-title');
        expect(bookTitles).toHaveLength(2);
        expect(bookTitles.at(0).text()).toBe('Book 1');
        expect(bookTitles.at(1).text()).toBe('Book 2');
    });

    it('displays a message when no liked books are available', async () => {
        const wrapper = mount(LikedBooks, {
            data() {
                return {
                    likedBooks: []
                };
            }
        });

        await wrapper.vm.$nextTick();

        const noBooksMessage = wrapper.find('.no-liked-books');
        expect(noBooksMessage.exists()).toBe(true);
        expect(noBooksMessage.text()).toBe('You have not liked any books yet.');
    });
});
