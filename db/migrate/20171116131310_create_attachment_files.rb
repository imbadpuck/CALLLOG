class CreateAttachmentFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :attachment_files do |t|

      t.timestamps
    end
  end
end
