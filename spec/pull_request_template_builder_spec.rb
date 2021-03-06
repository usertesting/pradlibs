require 'spec_helper'

module PradLibs
  describe PullRequestTemplateBuilder do
    good_url = "https://github.com/usertesting/orders/pull/4635"
    params =
      {
        token:       "example token",
        team_id:     "T0000",
        team_domain: "example domain",
        channel_id:   "C0000000000",
        channel_name: "code_review",
        user_id:      "U0000000000",
        user_name:    "User",
        command:      "/pr",
        text:         good_url,
        response_url: "www.example.com"
      }

    before :all do
      @args = Arguments.new good_url
      @args.parse!
      @pr = @args.pr
    end

    before :each do
      allow(@pr).to receive(:body).and_return(
        "#{@pr.html_url}
        # Purpose
        here's a purpose, yo

        # Implementation
        we implemented it like this!

        # Trello Card
        and it was related to a link like https://trello.com/card-blah

        # Notifications
        @usertesting/fake-team This team is so awesome it doesn't exist"
      )
    end

    subject { PullRequestTemplateBuilder.new @pr, params }

    it 'is initializable with a pull request object' do
      expect(subject).to be_a PullRequestTemplateBuilder
    end

    describe '#purpose' do
      it 'is the part of the PR body between *Purpose* and the next *' do
        expect(subject.purpose).to match /here's a purpose, yo\s*/
      end
    end

    describe '#implementation' do
      it 'is the part of the PR body between *Implementation* and the next *' do
        expect(subject.implementation).to match /we implemented it/
      end
    end

    describe '#trello_card_url' do
      it 'is the part of the PR body between *Trello Card:* and the next *' do
        expect(subject.trello_card_url).to match /trello\.com/
      end
    end

    describe '#has_trello_card?' do
      it 'is true if #trello_card_url parsed' do
        expect(subject.has_trello_card?).to be true
      end
    end

    describe '#get_teams' do
      it 'returns the teams matched' do
        expect(subject.get_teams).to eq ['fake-team']
      end
    end
  end
end
