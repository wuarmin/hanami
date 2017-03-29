RSpec.describe "Components: model.disconnector", type: :cli do
  context "with hanami-model" do
    it "disconnects model" do
      with_project do
        require Pathname.new(Dir.pwd).join("config", "environment")
        expect(Hanami::Model).to receive(:disconnect)

        Hanami::Components.resolve('model.disconnector')
      end
    end
  end
end
