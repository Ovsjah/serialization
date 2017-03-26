require 'csv'
require 'date'
require 'erb'

def number_edit(number)
  number = number.gsub(/\D/, '')
  if number.size == 10
    number
  elsif number.size == 11 && number[0] == '1'
    number = number[1..-1]
  else
    number = 'bad number'
  end
end

def convert(date)
  r_date = DateTime.strptime(date, '%m/%d/%y %H:%M')
end

def find_max_reg_rate(rate)
  max_rate = rate.select { |k, v| rate[k] == rate.values.max }
  
  if max_rate.all? { |k, _v| k.is_a? Integer }
    return max_rate.size > 1 ? "The pick registration hours are #{max_rate.keys.join(', ')}" : "The pick registration hour is #{max_rate.keys.join}"
  else
    return max_rate.size > 1 ? "The pick registration days are #{max_rate.keys.join(', ')}" : "The pick registration day is #{max_rate.keys.join}"
  end
  
end

def save_scratch(form_scratch)
  Dir.mkdir('output') unless Dir.exists?('output')
  
  filename = "output/scratch_info.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_scratch
  end
end  

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
template_scratch = File.read('form_scratch.erb')
erb_template = ERB.new(template_scratch)

reg_rate_hour = Hash.new(0)
reg_rate_day = Hash.new(0)
name_phone = Hash.new

contents.each do |row|
  name = [row[:first_name], row[:last_name]].join(' ')
  phone_num = number_edit(row[:homephone])
  name_phone[name] = phone_num 
  reg_rate_hour[convert(row[:regdate]).hour] += 1
  day = convert(row[:regdate])
  reg_rate_day[day.strftime('%A')] += 1
end

find_max_reg_rate(reg_rate_hour)
find_max_reg_rate(reg_rate_day)
form_scratch = erb_template.result(binding)
save_scratch(form_scratch)
