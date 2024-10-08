require 'byebug'
require 'telegram/bot'
require_relative 'converter'

class TelegramBot
  TOKEN = ENV['TELEGRAM_BOT_TOKEN']

  PHRASES = {
    Converter::EN => {
      choose_language: 'Choose the language:',
      write_the_word: 'Now write the word you want to convert:',
      no_letters: 'Not all letters are present in English',
      result: 'The result is ',
    },
    Converter::UK => {
      choose_language: 'Виберіть мову:',
      write_the_word: 'Зараз напишіть слово, яке слід конвертувати:',
      no_letters: 'Не всі букви присутні в українській мові',
      result: 'Результат '
    },
    Converter::RU => {
      choose_language: 'Выберите язык:',
      write_the_word: 'Сейчас напишите слово, которое нужно конвертировать:',
      no_letters: 'Не все буквы присутствуют в русском языке',
      result: 'Результат '
    }
  }

  def run
    @language = Converter::EN

    bot.listen do |message|
      case message.text
      when *%w(/start /language)
        languages = keyboard_markup({ keyboard: Converter::AVAILABLE_ALPHABETS.values.map { |l| [button(text: l)] } })
        send_message(message.chat.id, { text: PHRASES.dig(@language, :choose_language), reply_markup: languages })
      when *Converter::AVAILABLE_ALPHABETS.values
        @language = Converter::AVAILABLE_ALPHABETS.find {|_k, v| v == message.text}.first
        send_message(message.chat.id, { text: PHRASES.dig(@language, :write_the_word), reply_markup: keyboard_remove })
      else
        converter = Converter.new(message.text, @language)

        send_message(message.chat.id, { text: converter.matching})
        send_message(message.chat.id, { text: PHRASES.dig(@language, :result) + converter.sum_of_letters.to_s })
      end
    rescue Converter::LettersNotFound
      send_message(message.chat.id, { text: PHRASES.dig(@language, :no_letters) })
      languages = keyboard_markup({ keyboard: Converter::AVAILABLE_ALPHABETS.values.map { |l| [button(text: l)] } })
      send_message(message.chat.id, { text: PHRASES.dig(@language, :choose_language), reply_markup: languages })
    rescue => e
      puts e.message
    end
  end

  private

  def bot
    Telegram::Bot::Client.run(TOKEN) { |bot| return bot }
  end

  def send_message(chat_id, options)
    bot.api.sendMessage(chat_id: chat_id, **options)
  end

  def button(options)
    Telegram::Bot::Types::KeyboardButton.new(options)
  end

  def keyboard_markup(options)
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(**options)
  end

  def keyboard_remove
    Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  end

end
