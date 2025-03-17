import { mount } from '@vue/test-utils';
import CommentsSection from '../static/comments.js';

describe('CommentsSection', () => {
    let wrapper;

    beforeEach(() => {
        wrapper = mount(CommentsSection, {
            propsData: { bookId: 1 }
        });
    });

    it('fetches comments on mount', async () => {
        const fetchSpy = jest.spyOn(wrapper.vm, 'fetchComments');
        await wrapper.vm.$nextTick();
        expect(fetchSpy).toHaveBeenCalled();
    });

    it('displays an error message when submitting an empty comment', async () => {
        wrapper.setData({ newComment: '' });
        await wrapper.vm.submitComment();
        expect(wrapper.vm.errorMessage).toBe('Comment cannot be empty');
    });

    it('submits a comment successfully', async () => {
        wrapper.setData({ newComment: 'Great book!' });
        const submitSpy = jest.spyOn(wrapper.vm, 'submitComment');
        await wrapper.vm.submitComment();
        expect(submitSpy).toHaveBeenCalled();
        expect(wrapper.vm.newComment).toBe('');
    });
});
