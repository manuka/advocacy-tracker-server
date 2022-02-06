# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe "measuretype to taxonomy relationships", type: :request do
  let(:auth_headers) do
    {
      "access-token" => token.token,
      "client" => token.client,
      "uid" => user.uid
    }
  end
  let!(:user) { FactoryBot.create(:user, :admin, password: "password") }
  let!(:token) { user.create_token }

  before { user.save }
  describe "get one measuretype/taxonomy relationship" do
    let!(:measuretype_taxonomy) { FactoryBot.create(:measuretype_taxonomy) }
    it "returns the measuretype/taxonomy releationship requested" do
      get "/measuretype_taxonomies/#{measuretype_taxonomy.id}", headers: auth_headers

      expected_json =
        {"data" =>
          {"id" => measuretype_taxonomy.id.to_s,
           "type" => "measuretype_taxonomies",
           "attributes" =>
            {"created_at" => measuretype_taxonomy.created_at.in_time_zone.iso8601,
             "updated_at" => measuretype_taxonomy.updated_at.in_time_zone.iso8601,
             "measuretype_id" => measuretype_taxonomy.measuretype_id,
             "taxonomy_id" => measuretype_taxonomy.taxonomy_id}}}

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end

  describe "get all the measuretype/taxonomy relationships" do
    let(:measuretype_1) { FactoryBot.create(:measuretype) }
    let(:measuretype_2) { FactoryBot.create(:measuretype) }
    let(:taxonomy_1) { FactoryBot.create(:taxonomy) }
    let(:taxonomy_2) { FactoryBot.create(:taxonomy) }
    let!(:measuretype_measuretype_1) { FactoryBot.create(:measuretype_taxonomy, measuretype_id: measuretype_1.id, taxonomy_id: taxonomy_1.id) }
    let!(:measuretype_measuretype_2) { FactoryBot.create(:measuretype_taxonomy, measuretype_id: measuretype_1.id, taxonomy_id: taxonomy_2.id) }
    let!(:measuretype_measuretype_3) { FactoryBot.create(:measuretype_taxonomy, measuretype_id: measuretype_2.id, taxonomy_id: taxonomy_1.id) }

    it "returns all the linkable measuretype/taxonomies" do
      get "/measuretype_taxonomies", headers: auth_headers

      expected_json =
        {"data" =>
          [
            {"id" => measuretype_measuretype_1.id.to_s,
             "type" => "measuretype_taxonomies",
             "attributes" =>
              {"created_at" => measuretype_measuretype_1.created_at.in_time_zone.iso8601,
               "updated_at" => measuretype_measuretype_1.updated_at.in_time_zone.iso8601,
               "measuretype_id" => measuretype_measuretype_1.measuretype_id,
               "taxonomy_id" => measuretype_measuretype_1.taxonomy_id}},
            {"id" => measuretype_measuretype_2.id.to_s,
             "type" => "measuretype_taxonomies",
             "attributes" =>
              {"created_at" => measuretype_measuretype_2.created_at.in_time_zone.iso8601,
               "updated_at" => measuretype_measuretype_2.updated_at.in_time_zone.iso8601,
               "measuretype_id" => measuretype_measuretype_2.measuretype_id,
               "taxonomy_id" => measuretype_measuretype_2.taxonomy_id}},
            {"id" => measuretype_measuretype_3.id.to_s,
             "type" => "measuretype_taxonomies",
             "attributes" =>
              {"created_at" => measuretype_measuretype_3.created_at.in_time_zone.iso8601,
               "updated_at" => measuretype_measuretype_3.updated_at.in_time_zone.iso8601,
               "measuretype_id" => measuretype_measuretype_3.measuretype_id,
               "taxonomy_id" => measuretype_measuretype_3.taxonomy_id}}
          ]}

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end
end
