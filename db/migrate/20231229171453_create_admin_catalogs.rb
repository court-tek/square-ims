class CreateAdminCatalogs < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_catalogs do |t|

      t.timestamps
    end
  end
end
