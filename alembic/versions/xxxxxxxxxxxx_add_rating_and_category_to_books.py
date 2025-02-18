from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'xxxxxxxxxxxx'
down_revision = 'previous_revision_id'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('books', sa.Column('rating', sa.Float(), nullable=True))
    op.add_column('books', sa.Column('category', sa.String(), nullable=True))


def downgrade():
    op.drop_column('books', 'rating')
    op.drop_column('books', 'category')
