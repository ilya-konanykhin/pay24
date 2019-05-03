require 'builder'

module Pay24
  module Errors
    attr_reader :code, :message, :result_code

    # фатальные ошибки начинаются с ERROR_, остальные - с других символов
    SUCCESS                                   = :ok                               # non-fatal
    TEMPORARY_ERROR                           = :temporary_error                  # non-fatal
    ERROR_INVALID_USER_ID_FORMAT              = :user_id_does_not_match_format    #     fatal
    ERROR_USER_NOT_FOUND                      = :user_not_found                   #     fatal
    ERROR_PAYMENT_DENIED_BY_PROVIDER          = :payment_denied_by_provider       #     fatal
    ERROR_PAYMENT_DENIED_FOR_TECHNICAL_REASON = :payment_denied_tech_reason       #     fatal
    ERROR_INACTIVE_USER                       = :inactive_user                    #     fatal
    PAYMENT_PROCESSING_NOT_FINISHED           = :payment_processing_not_finished  # non-fatal
    ERROR_SUM_IS_TOO_SMALL                    = :sum_is_too_small                 #     fatal
    ERROR_SUM_IS_TOO_LARGE                    = :sum_is_too_large                 #     fatal
    ERROR_CANNOT_CHECK_USER_ACCOUNT_STATE     = :cannot_check_account_state       #     fatal
    ERROR_INTERNAL                            = :internal_error                   #     fatal
  end
end
