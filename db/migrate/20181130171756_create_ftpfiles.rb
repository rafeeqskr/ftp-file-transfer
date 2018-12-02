class CreateFtpfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :ftpfiles do |t|
      t.references :ftpcr, foreign_key: true
      t.string :file_name

      t.timestamps
    end
  end
end
