class AddTrigramIndexToUsersEmail < ActiveRecord::Migration[7.1]
  def up
    # Create B-tree index on lowercased email for fast prefix searches
    # This index speeds up searches like: WHERE email ILIKE 'pattern%'
    # Using raw SQL to create index on lower(email) for case-insensitive prefix matching
    execute <<-SQL
      CREATE INDEX index_users_on_email_btree_prefix 
      ON users USING btree (lower(email) varchar_pattern_ops);
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS index_users_on_email_btree_prefix;
    SQL
  end
end
