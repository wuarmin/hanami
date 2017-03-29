RSpec.describe "Components: model.disconnector", type: :cli do
  context "without hanami-model" do
    it "disconnects model" do
      project_without_hanami_model do
        require Pathname.new(Dir.pwd).join("config", "environment")

        Hanami::Components.resolve('model.disconnector')
        expect(Hanami::Components['model.disconnector']).to be(nil)
      end
    end
  end
end
