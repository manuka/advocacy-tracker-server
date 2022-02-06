class DropSdgtargets < ActiveRecord::Migration[6.1]
  def change
    drop_table "sdgtarget_categories", force: :cascade do |t|
      t.integer "sdgtarget_id"
      t.integer "category_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "created_by_id"
    end

    drop_table "sdgtarget_indicators", force: :cascade do |t|
      t.integer "sdgtarget_id"
      t.integer "indicator_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "created_by_id"
      t.index ["indicator_id"], name: "index_sdgtarget_indicators_on_indicator_id"
      t.index ["sdgtarget_id"], name: "index_sdgtarget_indicators_on_sdgtarget_id"
    end

    drop_table "sdgtarget_measures", force: :cascade do |t|
      t.integer "sdgtarget_id"
      t.integer "measure_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "created_by_id"
      t.index ["measure_id"], name: "index_sdgtarget_measures_on_measure_id"
      t.index ["sdgtarget_id"], name: "index_sdgtarget_measures_on_sdgtarget_id"
    end

    drop_table "sdgtarget_recommendations", force: :cascade do |t|
      t.integer "sdgtarget_id"
      t.integer "recommendation_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "created_by_id"
      t.index ["recommendation_id"], name: "index_sdgtarget_recommendations_on_recommendation_id"
      t.index ["sdgtarget_id"], name: "index_sdgtarget_recommendations_on_sdgtarget_id"
    end

    drop_table "sdgtargets", force: :cascade do |t|
      t.string "reference"
      t.text "title"
      t.text "description"
      t.boolean "draft", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "updated_by_id"
      t.integer "created_by_id"
      t.index ["draft"], name: "index_sdgtargets_on_draft"
    end

    remove_column :taxonomies, :groups_sdgtargets_default, :integer
  end
end
