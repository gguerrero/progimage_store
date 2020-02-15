class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images, id: :uuid do |t|
      t.string :description

      t.timestamps
    end
  end
end
