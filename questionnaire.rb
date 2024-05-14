require "pstore" # https://github.com/ruby/pstore

STORE_NAME = "tendable.pstore"
store = PStore.new(STORE_NAME)

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

def do_prompt(store)
  answers = {}
  QUESTIONS.each do |key, question|
    print "#{question} (Yes/No): "
    answer = gets.chomp.downcase
    answers[key] = answer == "yes" || answer == "y"
  end
  store.transaction { store[:answers] = answers }
end

def do_report(store)
  store.transaction do
    all_answers = store[:all_answers] || []
    all_answers << store[:answers]
    store[:all_answers] = all_answers

    total_yes_count = all_answers.sum { |answers| answers.count { |_, v| v } }
    total_questions = QUESTIONS.size * all_answers.size
    overall_rating = total_yes_count.to_f / total_questions * 100

    current_yes = store[:answers].count { |_, v| v }
    current_rating = current_yes.to_f / QUESTIONS.size * 100

    puts "\nCurrent Run Rating: #{current_rating.round(2)}%"
    puts "Overall Rating: #{overall_rating.round(2)}%"
  end
end

do_prompt(store)
do_report(store)
