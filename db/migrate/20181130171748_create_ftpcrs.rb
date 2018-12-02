class CreateFtpcrs < ActiveRecord::Migration[5.2]
  def change
    create_table :ftpcrs do |t|
      t.string :host
      t.string :username
      t.string :password
      t.string :source_folder
      t.string :destination_folder

      t.timestamps
    end
  end
end
