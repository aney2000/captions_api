class CreateCaptions < ActiveRecord::Migration[8.1]
  def change
    create_table :captions do |t|
      t.string :url, null: false
      t.string :caption_url, null: true
      t.string :text, null: false

      t.timestamps
    end
  end
end
