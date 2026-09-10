class CreateInstagramCaptions < ActiveRecord::Migration[8.1]
  def change
    create_table :instagram_captions do |t|
      t.string :type_name, null: false
      t.string :text, null: false
      t.string :url
      t.string :filter
      t.string :caption_url

      t.timestamps
    end
  end
end
