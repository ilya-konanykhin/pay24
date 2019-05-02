require 'builder'

# Обработчик входящих платежей Pay24.
#
# transaction_id      целое число длиной до 28 знаков
# sum                 Сумма платежа, дробное число с точностью до сотых, в качестве разделителя используется точка
# transaction_date    дата платежа (дата получения запроса от клиента)
# account             ID пользователя, строка, содержащая буквы, цифры и спецсимволы, длиной до 200 символов.
#
# Передача информации о платеже провайдеру производится системой в 2 этапа:
#   command=check   Проверка возможности совершения платежа. Запись информации о платеже у поставщика
#   command=pay     Подтверждение проведения платежа
#
module Pay24
  class ResponseHandler
    include Pay24::Errors

    attr_reader :command, :account, :transaction_id, :transaction_date, :sum

    EMAIL_REGEX         = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
    IDENTIFICATOR_REGEX = /\A\d+\z/

    REQUEST_HANDLERS = {
      pay:   :osmp_pay,
      check: :check_if_account_is_valid,
    }.freeze

    def initialize(params: {}, find_user_callback: nil, payment_callback: nil)
      @command            = params[:command]
      @account            = params[:account]
      @transaction_id     = params[:txn_id]
      @transaction_date   = params[:txn_date]
      @sum                = params[:sum]
      @find_user_callback = find_user_callback
      @payment_callback   = payment_callback
      freeze
    end

    def command_is_valid?
      @command.to_sym.in?(REQUEST_HANDLERS.keys)
    end

    def payment_command?
      @command.to_sym == :pay
    end

    def run_command
      result_code = if command_is_valid?
                      send(REQUEST_HANDLERS[@command.to_sym]) || ERROR_INTERNAL
                    else
                      ERROR_INTERNAL
                    end

      Pay24::Result.new(result_code)
    end

    def requested_account
      @find_user_callback.(@account) rescue ERROR_CANNOT_CHECK_USER_ACCOUNT_STATE
    end

    def generate_xml(result, comment = '')
      xml = Builder::XmlMarkup.new indent: 2
      xml.instruct!
      xml.response do |req|
        req.result  result.code
        req.comment comment
        if payment_command?
          req.txn_id      @transaction_id
          req.sum         @sum
        end
      end
    end

    private

    def osmp_pay
      return check_if_account_is_valid if check_if_account_is_valid != SUCCESS

      sum         = @sum.to_f.abs
      result_code = nil

      begin
        raise PaymentIsZero, 'Попытка пополнить баланс на 0 единиц через Pay24' if sum.zero?

        @payment_callback.(requested_account, sum)
      rescue => e
        raise e if Rails.env.development? || Rails.env.test?
        result_code = ERROR_INTERNAL
      else
        result_code = SUCCESS
      end

      result_code
    end

    def check_if_account_is_valid
      if @account =~ EMAIL_REGEX || @account =~ IDENTIFICATOR_REGEX
        requested_account.present? ? SUCCESS : ERROR_USER_NOT_FOUND
      else
        ERROR_INVALID_USER_ID_FORMAT
      end
    end

    class PaymentIsZero < StandardError; end
  end
end