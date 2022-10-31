require "rails_helper"

RSpec.describe Followup, type: :model do
  subject { build(:followup) }

  it { is_expected.to belong_to(:case_contact) }
  it { is_expected.to belong_to(:creator).class_name("User") }

  it "only allows 1 followup in requested status" do
    case_contact = build_stubbed(:case_contact)
    create(:followup, status: :requested, case_contact: case_contact)
    invalid_followup = build(:followup, status: :requested, case_contact: case_contact)

    expect(invalid_followup).to be_invalid
  end

  it "allows followup to be flipped to resolved" do
    followup = create(:followup, status: :requested)

    expect(followup.resolved!).to be_truthy
  end

  describe ".in_organization" do
    # this needs to run first so it is generated using a new "default" organization
    let!(:followup_first_org) { create(:followup) }

    # then these lets are generated for the org_to_search organization
    let!(:second_org) { create(:casa_org) }
    let!(:casa_case) { create(:casa_case, casa_org: second_org) }
    let!(:casa_case_another) { create(:casa_case, casa_org: second_org) }
    let!(:case_contact) { create(:case_contact, casa_case: casa_case) }
    let!(:case_contact_another) { create(:case_contact, casa_case: casa_case_another) }
    let!(:followup_second_org) { create(:followup, case_contact: case_contact) }
    let!(:followup_second_org_another) { create(:followup, case_contact: case_contact_another) }

    subject { described_class.in_organization(second_org) }

    it "should include followups from same organization" do
      expect(subject).to contain_exactly(followup_second_org, followup_second_org_another)
    end

    it "should exclude followups from other organizations" do
      expect(subject).to_not include(followup_first_org)
    end
  end
end
