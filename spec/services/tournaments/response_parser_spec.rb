require 'rails_helper'

RSpec.describe Tournaments::ResponseParser, type: :service do
  describe '.parse' do
    let(:user) { create :user, uid: 1 }
    let(:user2) { create :user, uid: 2 }
    let!(:tournament) { create :tournament, round: 1 }
    let!(:question) { create :question, round: 1, for_tournament: true, answers: ['ok', 'yes'] }
    let(:answer) { 'oki' }

    subject { described_class.parse(answer, user).message }

    context 'user_already_answered' do
      let!(:correct_user) { create :correct_user, uid: user.uid, round: 1 }

      it { is_expected.to eq I18n.t('tournament.already_answered') }
    end

    context 'previously_lost' do
      let!(:correct_user) { create :correct_user, uid: user.uid, round: 1 }
      let!(:question) { create :question, round: 3, for_tournament: true, answers: ['correct answer', 'correctly answering'] }

      before { tournament.update(round: 3) }

      context 'correct answer' do
        let(:answer) { 'correct answer' }

        it 'correctly parses answer but not marking user as correct' do
          expect { subject }.not_to change { CorrectUser.count }
          expect(subject).to eq I18n.t('tournament.correct_answer.non_scoring')
        end
      end

      context 'incorrect answer' do
        let(:answer) { 'wrong answer' }

        it { is_expected.to eq I18n.t('tournament.incorrect_answer') }
      end
    end

    context 'correct_answer and answer_in_time' do
      it 'accepts correct answer and show proper message' do
        expect { subject }.to change { CorrectUser.count }.by 1
        expect(subject).to eq I18n.t('tournament.correct_answer.continue')
      end
    end

    context 'correct_answer but too late' do
      let!(:correct_user) { create :correct_user, uid: user2.uid, round: 1 }

      before { tournament.update(max_correct_users_count: 1) }

      it { is_expected.to eq I18n.t('tournament.correct_answer.too_late', number: tournament.max_correct_users_count + 1) }
    end

    context 'incorrect answer' do
      let(:answer) { 'wrong' }

      it { is_expected.to eq I18n.t('tournament.incorrect_answer') }
    end
  end
end
