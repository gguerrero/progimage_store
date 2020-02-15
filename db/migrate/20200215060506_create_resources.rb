class CreateResources < ActiveRecord::Migration[6.0]
  def change
    create_table :resources, id: :uuid do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
