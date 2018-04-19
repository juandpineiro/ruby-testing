require 'rspec'
require 'date'
require './hotel.rb'

describe Hotel do
  let(:hotel) { Hotel.new }

  # Less than 30 days ago
  let(:ci_date) { (Date.today - 10).strftime("%d-%m-%Y") }
  let(:co_date) { (Date.today - 8).strftime("%d-%m-%Y") }

  # Less than 60 days ago
  let(:old_ci_date) { (Date.today - 45).strftime("%d-%m-%Y") }
  let(:old_co_date) { (Date.today - 43).strftime("%d-%m-%Y") }

  # More than 60 days ago
  let(:older_ci_date) { (Date.today - 75).strftime("%d-%m-%Y") }
  let(:older_co_date) { (Date.today - 73).strftime("%d-%m-%Y") }
 
  describe 'checking in a guest' do
    context 'room is available' do
      it 'allows check-in' do
        expect(hotel.check_in_guest('George Harrison', 302, ci_date)).to be true
      end
 
      it "adds the guest to the hotel's guest list" do
        hotel.check_in_guest('Joe Satriani', 444, ci_date)
        expect(hotel.guests).to include 'Joe Satriani'
      end

      it 'keeps track of the check-in date' do
        hotel.check_in_guest('Steve Vai', 123, ci_date)
        expect(hotel.payments['Steve Vai'][:check_in_date]
          .strftime('%d-%m-%Y')).to eq ci_date
      end
    end
 
    context 'room is not available' do
      it 'disallows check-in' do
        hotel.check_in_guest('Prince', 555, ci_date)
        expect(hotel.check_in_guest('Eddie Van Halen', 555, ci_date))
          .to be false
      end
 
      it "does not add the guest to the hotel's guest list" do
        hotel.check_in_guest('Dave Mustaine', 777, ci_date)
        hotel.check_in_guest('Cliff Burton', 777, ci_date)
        expect(hotel.guests).not_to include 'Cliff Burton'
      end
    end
  end
 
  describe 'checking out a guest' do
    it "removes the guest from the hotel's guest list" do
      hotel.check_in_guest('David Gilmour', 323, ci_date)
      hotel.check_out_guest('David Gilmour', co_date)
      expect(hotel.guests).not_to include 'David Gilmour'
    end
 
    it 'frees up the room' do
      hotel.check_in_guest('Roger Waters', 232, ci_date)
      hotel.check_out_guest('Roger Waters', co_date)
      expect(hotel.check_in_guest('Syd Barrett', 232, ci_date)).to be true
    end

    it 'receives payment' do
      hotel.check_in_guest('Carlos Santana', 666, ci_date)
      hotel.check_out_guest('Carlos Santana', co_date)
      expect(hotel.payments['Carlos Santana'][:total]).to eq 200
    end

    it 'keeps track of the check-out date' do
      hotel.check_in_guest('Paul Gilbert', 123, ci_date)
      hotel.check_out_guest('Paul Gilbert', co_date)
      expect(hotel.payments['Paul Gilbert'][:check_out_date]
        .strftime('%d-%m-%Y')).to eq co_date
    end
  end

  describe 'reporting revenue' do
    it 'reports all-time total revenue by default' do
      hotel.check_in_guest('James Hetfield', 001, ci_date)
      hotel.check_in_guest('Lars Ulrich', 002, old_ci_date)
      hotel.check_in_guest('Kirk Hammet', 003, older_ci_date)
      hotel.check_out_guest('James Hetfield', co_date)
      hotel.check_out_guest('Lars Ulrich', old_co_date)
      hotel.check_out_guest('Kirk Hammet', older_co_date)
      expect(hotel.revenue_report).to eq "All-time revenue: 600 $"
    end

    it 'reports total revenue of the last n days (60 days in this case)' do
      hotel.check_in_guest('James Hetfield', 001, ci_date)
      hotel.check_in_guest('Lars Ulrich', 002, old_ci_date)
      hotel.check_in_guest('Kirk Hammet', 003, older_ci_date)
      hotel.check_out_guest('James Hetfield', co_date)
      hotel.check_out_guest('Lars Ulrich', old_co_date)
      hotel.check_out_guest('Kirk Hammet', older_co_date)
      expect(hotel.revenue_report(60))
        .to eq "Total revenue of the last 60 days: 400 $"
    end
  end
end