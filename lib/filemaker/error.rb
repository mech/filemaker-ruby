module Filemaker
  module Error
    class CommunicationError < StandardError; end
    class AuthenticationError < StandardError; end
    class ParameterError < StandardError; end
    class CoerceError < StandardError; end

    class FilemakerError < StandardError
      attr_reader :code

      def initialize(code, message = nil)
        @code = code
        super(message)
      end
    end

    class SystemError < FilemakerError; end

    class UnknownError < SystemError; end
    class UserCancelledError < SystemError; end
    class MemoryError < SystemError; end
    class CommandNotAvailableError < SystemError; end
    class CommandUnknownError < SystemError; end
    class CommandInvalidError < SystemError; end
    class FileReadOnlyError < SystemError; end
    class OutOfMemoryError < SystemError; end
    class EmptyResultError < SystemError; end
    class InsufficientPrivilegesError < SystemError; end
    class RequestedDataMissingError < SystemError; end

    class MissingError < FilemakerError; end
    class FileMissingError < MissingError; end
    class RecordMissingError < MissingError; end
    class FieldMissingError < MissingError; end
    class ScriptMissingError < MissingError; end
    class LayoutMissingError < MissingError; end
    class TableMissingError < MissingError; end

    class SecurityError < FilemakerError; end
    class RecordAccessDeniedError < SecurityError; end
    class FieldCannotBeModifiedError < SecurityError; end
    class FieldAccessDeniedError < SecurityError; end

    class ConcurrencyError < FilemakerError; end
    class FileLockedError < ConcurrencyError; end
    class RecordInUseError < ConcurrencyError; end
    class TableInUseError < ConcurrencyError; end
    class RecordModificationIdMismatchError < ConcurrencyError; end

    class FindCriteriaEmptyError < FilemakerError; end

    def self.raise_error_by_code(code)
      msg = error_message_by_code(code)
      error_class = find_error_class_by_code(code)
      raise error_class.new(code, msg)
    end

    def self.error_message_by_code(code)
      "FileMaker Error: #{code} (#{DESCRIPTION.fetch(code.to_s) { '??' }})"
    end

    def self.find_error_class_by_code(code)
      case code
      when -1  then UnknownError
      when 1..99
        if code == 1; UserCancelledError
        elsif code == 2; MemoryError
        elsif code == 3; CommandNotAvailableError
        elsif code == 4; CommandUnknownError
        elsif code == 5; CommandInvalidError
        elsif code == 6; FileReadOnlyError
        elsif code == 7; OutOfMemoryError
        elsif code == 8; EmptyResultError
        elsif code == 9; InsufficientPrivilegesError
        elsif code == 10; RequestedDataMissingError
        else SystemError; end
      when 100..199
        if code == 100; FileMissingError
        elsif code == 101; RecordMissingError
        elsif code == 102; FieldMissingError
        elsif code == 104; ScriptMissingError
        elsif code == 105; LayoutMissingError
        elsif code == 106; TableMissingError
        else MissingError; end
      when 200..299
        if code == 200; RecordAccessDeniedError
        elsif code == 201; FieldCannotBeModifiedError
        elsif code == 202; FieldAccessDeniedError
        else SecurityError; end
      when 300..399
        if code == 300; FileLockedError
        elsif code == 301; RecordInUseError
        elsif code == 302; TableInUseError
        elsif code == 306; RecordModificationIdMismatchError
        else ConcurrencyError; end
      when 400 then FindCriteriaEmptyError
      else
        UnknownError
      end
    end

    DESCRIPTION = {
      '-1'  => 'Unknown error',
      '1'   => 'User cancelled action',
      '2'   => 'Memory error',
      '3'   => 'Command is unavailable (for example, wrong operating system, wrong mode, etc.)',
      '4'   => 'Command is unknown',
      '5'   => 'Command is invalid (for example, a Set Field script step does not have a calculation specified)',
      '6'   => 'File is read-only',
      '7'   => 'Running out of memory',
      '8'   => 'Empty result',
      '9'   => 'Insufficient privileges',
      '10'  => 'Requested data is missing',
      '11'  => 'Name is not valid',
      '12'  => 'Name already exists',
      '13'  => 'File or object is in use',
      '14'  => 'Out of range',
      '15'  => 'Can\'t divide by zero',
      '16'  => 'Operation failed, request retry (for example, a user query)',
      '17'  => 'Attempt to convert foreign character set to UTF-16 failed',
      '18'  => 'Client must provide account information to proceed',
      '19'  => 'String contains characters other than A-Z, a-z, 0-9 (ASCII)',
      '20'  => 'Command or operation cancelled by triggered script',
      '21'  => 'Request not supported (for example, when creating a hard link on a file system that does not support hard links)',
      '100' => 'File is missing',
      '101' => 'Record is missing',
      '102' => 'Field is missing',
      '103' => 'Relationship is missing',
      '104' => 'Script is missing',
      '105' => 'Layout is missing',
      '106' => 'Table is missing',
      '107' => 'Index is missing',
      '108' => 'Value list is missing',
      '109' => 'Privilege set is missing',
      '110' => 'Related tables are missing',
      '111' => 'Field repetition is invalid',
      '112' => 'Window is missing',
      '113' => 'Function is missing',
      '114' => 'File reference is missing',
      '115' => 'Menu set is missing',
      '116' => 'Layout object is missing',
      '117' => 'Data source is missing',
      '118' => 'Theme is missing',
      '130' => 'Files are damaged or missing and must be reinstalled',
      '131' => 'Language pack files are missing (such as Starter Solutions)',
      '200' => 'Record access is denied',
      '201' => 'Field cannot be modified',
      '202' => 'Field access is denied',
      '203' => 'No records in file to print, or password doesn’t allow print access',
      '204' => 'No access to field(s) in sort order',
      '205' => 'User does not have access privileges to create new records; import will overwrite existing data',
      '206' => 'User does not have password change privileges, or file is not modifiable',
      '207' => 'User does not have sufficient privileges to change database schema, or file is not modifiable',
      '208' => 'Password does not contain enough characters',
      '209' => 'New password must be different from existing one',
      '210' => 'User account is inactive',
      '211' => 'Password has expired',
      '212' => 'Invalid user account and/or password. Please try again',
      '213' => 'User account and/or password does not exist',
      '214' => 'Too many login attempts',
      '215' => 'Administrator privileges cannot be duplicated',
      '216' => 'Guest account cannot be duplicated',
      '217' => 'User does not have sufficient privileges to modify administrator account',
      '218' => 'Password and verify password do not match',
      '300' => 'File is locked or in use',
      '301' => 'Record is in use by another user',
      '302' => 'Table is in use by another user',
      '303' => 'Database schema is in use by another user',
      '304' => 'Layout is in use by another user',
      '306' => 'Record modification ID does not match',
      '307' => 'Transaction could not be locked because of a communication error with the host',
      '308' => 'Theme is locked and in use by another user',
      '400' => 'Find criteria are empty'
    }
  end
end
