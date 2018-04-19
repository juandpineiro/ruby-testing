require 'date'

class Hotel
  attr_accessor :guests, :revenue, :payments

  def initialize
    @guests = {}  # guests = { guest_name: room_number }
    @occupied_rooms = []
    @rate = 100 
    @payments = {} # Separate hash to keep dates even when guest is removed
                   # payments = { guest_name: { ci_date: date, 
                   #                            co_date: date, 
                   #                            total: payment} }
    @revenue = 0
  end

  def check_in_guest(guest_name, room_number, date)
    return false if @occupied_rooms.include?(room_number)
    @guests.store(guest_name, room_number)
    ci_date = Date::strptime(date, "%d-%m-%Y")
    @payments.store(guest_name, {check_in_date: ci_date})
    @occupied_rooms << room_number
    true
  end

  def register_payment(guest_name, date)
    ci_date = @payments[guest_name][:check_in_date]
    co_date = Date::strptime(date, "%d-%m-%Y")
    days = co_date.mjd - ci_date.mjd
    @payments[guest_name][:check_out_date] = co_date
    @payments[guest_name][:total] = @rate * days
    @revenue += @payments[guest_name][:total]
  end
  
  def check_out_guest(guest_name, date)
    self.register_payment(guest_name, date)
    @occupied_rooms.delete(@guests[guest_name])
    @guests.delete(guest_name)
  end

  def revenue_report(days=nil)
    if days.nil?
      return "All-time revenue: #{@revenue} $"
    else
      in_range = 0
      @payments.each do |k, v|
        if (Date.today - v[:check_out_date]) <= days
          in_range += v[:total]
        end 
      end
      return "Total revenue of the last #{days} days: #{in_range} $"
    end
  end
end

