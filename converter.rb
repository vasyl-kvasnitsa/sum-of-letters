require 'byebug'

class Converter

  class LettersNotFound < Exception; end

  EN = :en
  UK = :uk
  RU = :ru

  AVAILABLE_ALPHABETS = { EN => 'english', UK => 'українська', RU => 'русский' }

  ALPHABETS = {
    EN => %w(a b c d e f g h i j k l m n o p q r s t u v w x y z),
    UK => %w(а б в г ґ д е є ж з и і ї й к л м н о п р с т у ф х ц ч ш щ ь ю я),
    RU => %w(а б в г д е ж з и й к л м н о п р с т у ф х ц ч ш щ ъ ы ь э ю я)
  }

  COUNT_OF_LARIANTS = 22

  def matching
    locale_arrays = ALPHABETS[@locale].each_slice(9).to_a

    raise LettersNotFound unless @word.chars.all? { |ch| ALPHABETS[@locale].include?(ch) }

    @result = @word.chars.map { |ch| locale_arrays.find { |array| array.include?(ch) }&.index(ch).to_i + 1 }

    @word.chars.map.each_with_index { |l, i| "#{l} -> #{@result[i]}" }.join("\n")
  end

  def sum_of_letters
    sum = @result.sum

    adjust_result_to_lariants(sum)
  end

  private

  def initialize(word, locale)
    @word = word.gsub(/\s+/, "").downcase
    @locale = locale

    @result = []
  end

  def adjust_result_to_lariants(sum)
    sum > COUNT_OF_LARIANTS ? adjust_result_to_lariants(sum - COUNT_OF_LARIANTS) : sum
  end
end