describe RubocopAnalysisStatusWorker do
  let(:build) { create :build }

  describe "#perform" do
    before do
      ResqueSpec.reset!
    end

    it "adds an entry to the queue" do
      RubocopAnalysisStatusWorker.create build_id: build.id
      expect(RubocopAnalysisStatusWorker).to have_queue_size_of(1)
    end
  end
end
