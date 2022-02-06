# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe "actortype to taxonomy relationships", type: :request do
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
  describe "get one actortype/taxonomy relationship" do
    let!(:actortype_taxonomy) { FactoryBot.create(:actortype_taxonomy) }
    it "returns the actortype/taxonomy releationship requested" do
      get "/actortype_taxonomies/#{actortype_taxonomy.id}", headers: auth_headers

      expected_json =
        {"data" =>
          {"id" => actortype_taxonomy.id.to_s,
           "type" => "actortype_taxonomies",
           "attributes" =>
            {"created_at" => actortype_taxonomy.created_at.in_time_zone.iso8601,
             "updated_at" => actortype_taxonomy.updated_at.in_time_zone.iso8601,
             "actortype_id" => actortype_taxonomy.actortype_id,
             "taxonomy_id" => actortype_taxonomy.taxonomy_id}}}

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end

  describe "get all the actortype/taxonomy relationships" do
    let(:actortype_1) { FactoryBot.create(:actortype) }
    let(:actortype_2) { FactoryBot.create(:actortype) }
    let(:taxonomy_1) { FactoryBot.create(:taxonomy) }
    let(:taxonomy_2) { FactoryBot.create(:taxonomy) }
    let!(:actortype_taxonomy_1) { FactoryBot.create(:actortype_taxonomy, actortype_id: actortype_1.id, taxonomy_id: taxonomy_1.id) }
    let!(:actortype_taxonomy_2) { FactoryBot.create(:actortype_taxonomy, actortype_id: actortype_1.id, taxonomy_id: taxonomy_2.id) }
    let!(:actortype_taxonomy_3) { FactoryBot.create(:actortype_taxonomy, actortype_id: actortype_2.id, taxonomy_id: taxonomy_1.id) }

    it "returns all the linkable actortype/taxonomies" do
      get "/actortype_taxonomies", headers: auth_headers

      expected_json =
        {"data" =>
          [
            {"id" => actortype_taxonomy_1.id.to_s,
             "type" => "actortype_taxonomies",
             "attributes" =>
              {"created_at" => actortype_taxonomy_1.created_at.in_time_zone.iso8601,
               "updated_at" => actortype_taxonomy_1.updated_at.in_time_zone.iso8601,
               "actortype_id" => actortype_taxonomy_1.actortype_id,
               "taxonomy_id" => actortype_taxonomy_1.taxonomy_id}},
            {"id" => actortype_taxonomy_2.id.to_s,
             "type" => "actortype_taxonomies",
             "attributes" =>
              {"created_at" => actortype_taxonomy_2.created_at.in_time_zone.iso8601,
               "updated_at" => actortype_taxonomy_2.updated_at.in_time_zone.iso8601,
               "actortype_id" => actortype_taxonomy_2.actortype_id,
               "taxonomy_id" => actortype_taxonomy_2.taxonomy_id}},
            {"id" => actortype_taxonomy_3.id.to_s,
             "type" => "actortype_taxonomies",
             "attributes" =>
              {"created_at" => actortype_taxonomy_3.created_at.in_time_zone.iso8601,
               "updated_at" => actortype_taxonomy_3.updated_at.in_time_zone.iso8601,
               "actortype_id" => actortype_taxonomy_3.actortype_id,
               "taxonomy_id" => actortype_taxonomy_3.taxonomy_id}}
          ]}

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end
end
