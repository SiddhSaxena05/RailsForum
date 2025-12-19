class AddTrigramIndexToUsersEmail < ActiveRecord::Migration[7.1]
  def up
    # Create hash index on lowercased email for fast exact lookups
    # Hash indexes are optimized for equality comparisons (=)
    # Using raw SQL to create hash index on lower(email) for case-insensitive exact matching
    execute <<-SQL
      CREATE INDEX index_users_on_email_hash 
      ON users USING hash (lower(email));
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS index_users_on_email_hash;
    SQL
  end
end
