class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks, comment: 'タスク' do |t|
      t.string :content, comment: '内容'

      t.timestamps
    end
  end
end
