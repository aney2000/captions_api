class DropUsers < ActiveRecord::Migration[8.1]
  def up
    drop_table :users, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
