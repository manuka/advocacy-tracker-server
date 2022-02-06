# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe "actor to measure relationships", type: :request do
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
  describe "get one actor/measure relationship" do
    let!(:actor_measure) { FactoryBot.create(:actor_measure, created_by: user, updated_by: user) }
    it "returns the actor/measure releationship requested" do
      get "/actor_measures/#{actor_measure.id}", headers: auth_headers

      expected_json =
        {"data" =>
          {"id" => actor_measure.id.to_s,
           "type" => "actor_measures",
           "attributes" =>
            {
              "actor_id" => actor_measure.actor_id,
              "created_at" => actor_measure.created_at.in_time_zone.iso8601,
              "created_by_id" => user.id,
              "date_end" => "2021-11-02",
              "date_start" => "2021-11-02",
              "measure_id" => actor_measure.measure_id,
              "updated_at" => actor_measure.updated_at.in_time_zone.iso8601,
              "updated_by_id" => user.id,
              "value" => "3.14"
            }}}

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end

  describe "get all the actor/measure relationships" do
    let(:actor_1) { FactoryBot.create(:actor) }
    let(:actor_2) { FactoryBot.create(:actor) }
    let(:measure_1) { FactoryBot.create(:measure) }
    let(:measure_2) { FactoryBot.create(:measure) }
    let!(:actor_measure_1) { FactoryBot.create(:actor_measure, actor: actor_1, measure: measure_1, created_by: user, updated_by: user) }
    let!(:actor_measure_2) { FactoryBot.create(:actor_measure, actor: actor_1, measure: measure_2, created_by: user, updated_by: user) }
    let!(:actor_measure_3) { FactoryBot.create(:actor_measure, actor: actor_2, measure: measure_1, created_by: user, updated_by: user) }

    it "returns all the linkable actor/taxonomies" do
      get "/actor_measures", headers: auth_headers

      expected_json =
        {"data" =>
          [
            {"id" => actor_measure_1.id.to_s,
             "type" => "actor_measures",
             "attributes" =>
              {
                "actor_id" => actor_measure_1.actor_id,
                "created_at" => actor_measure_1.created_at.in_time_zone.iso8601,
                "created_by_id" => user.id,
                "date_end" => "2021-11-02",
                "date_start" => "2021-11-02",
                "measure_id" => actor_measure_1.measure_id,
                "updated_at" => actor_measure_1.updated_at.in_time_zone.iso8601,
                "updated_by_id" => user.id,
                "value" => "3.14"
              }},
            {"id" => actor_measure_2.id.to_s,
             "type" => "actor_measures",
             "attributes" =>
              {
                "actor_id" => actor_measure_2.actor_id,
                "created_at" => actor_measure_2.created_at.in_time_zone.iso8601,
                "created_by_id" => user.id,
                "date_end" => "2021-11-02",
                "date_start" => "2021-11-02",
                "measure_id" => actor_measure_2.measure_id,
                "updated_at" => actor_measure_2.updated_at.in_time_zone.iso8601,
                "updated_by_id" => user.id,
                "value" => "3.14"
              }},
            {"id" => actor_measure_3.id.to_s,
             "type" => "actor_measures",
             "attributes" =>
              {
                "actor_id" => actor_measure_3.actor_id,
                "created_at" => actor_measure_3.created_at.in_time_zone.iso8601,
                "created_by_id" => user.id,
                "date_end" => "2021-11-02",
                "date_start" => "2021-11-02",
                "measure_id" => actor_measure_3.measure_id,
                "updated_at" => actor_measure_3.updated_at.in_time_zone.iso8601,
                "updated_by_id" => user.id,
                "value" => "3.14"
              }}
          ]}

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json).to eq(expected_json)
    end
  end
end
