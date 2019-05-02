require 'builder'

# Модель для вывода результата обработчика.
#
# code            код результата
# message_code    комментарий
# result_code     названия результата
#
module Pay24
  class Result
    include Pay24::Errors

    attr_reader :code, :message, :result_code

    # назание неточно, тут не только ошибки. MESSAGES_TO_PAYMENT_GATEWAY
    ERRORS = {
      SUCCESS => {
        message: 'OK',
        code:    0,
      },
      TEMPORARY_ERROR => {
        message: 'Временная ошибка. Повторите запрос позже',
        code:    1,
      },
      ERROR_INVALID_USER_ID_FORMAT => {
        message: 'Неверный формат идентификатора абонента',
        code:    4,
      },
      ERROR_USER_NOT_FOUND => {
        message: 'Идентификатор абонента не найден (Нет такого пользователя)',
        code:    5,
      },
      ERROR_PAYMENT_DENIED_BY_PROVIDER => {
        message: 'Прием платежа запрещен провайдером',
        code:    7,
      },
      ERROR_PAYMENT_DENIED_FOR_TECHNICAL_REASON => {
        message: 'Прием платежа запрещен по техническим причинам',
        code:    8,
      },
      ERROR_INACTIVE_USER => {
        message: 'Счет абонента не активен',
        code:    79,
      },
      PAYMENT_PROCESSING_NOT_FINISHED => {
        message: 'Проведение платежа не окончено (При отмене платежа – отмена еще не подтверждена. Система отправит повторный запрос через некоторое время.)',
        code:    90,
      },
      ERROR_SUM_IS_TOO_SMALL => {
        message: 'Сумма слишком мала',
        code:    241,
      },
      ERROR_SUM_IS_TOO_LARGE => {
        message: 'Сумма слишком велика',
        code:    242,
      },
      ERROR_CANNOT_CHECK_USER_ACCOUNT_STATE => {
        message: 'Невозможно проверить состояние счета',
        code:    243,
      },
      ERROR_INTERNAL => {
        message: 'Другая ошибка провайдера',
        code:    300,
      },
    }.freeze

    NON_FATAL_ERRORS = %i{ ok temporary_error payment_processing_not_finished }.freeze

    def initialize(result_code)
      @result_code = result_code
      @message     = ERRORS.try(:[], result_code).try(:[], :message)
      @code        = ERRORS.try(:[], result_code).try(:[], :code)
    end

    def failure?
      !success?
    end

    def success?
      @result_code.to_sym.in? NON_FATAL_ERRORS
    end

  end
end