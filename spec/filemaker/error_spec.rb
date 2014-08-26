describe Filemaker::Error do

  context '-1 to 100 errors' do
    it 'raises UnknownError for -1' do
      expect do
        Filemaker::Error.raise_error_by_code(-1)
      end.to raise_error Filemaker::Error::UnknownError
    end

    it 'raises UserCancelledError for 1' do
      expect do
        Filemaker::Error.raise_error_by_code(1)
      end.to raise_error Filemaker::Error::UserCancelledError
    end

    it 'raises MemoryError for 2' do
      expect do
        Filemaker::Error.raise_error_by_code(2)
      end.to raise_error Filemaker::Error::MemoryError
    end

    it 'raises CommandNotAvailableError for 3' do
      expect do
        Filemaker::Error.raise_error_by_code(3)
      end.to raise_error Filemaker::Error::CommandNotAvailableError
    end

    it 'raises CommandUnknownError for 4' do
      expect do
        Filemaker::Error.raise_error_by_code(4)
      end.to raise_error Filemaker::Error::CommandUnknownError
    end

    it 'raises CommandInvalidError for 5' do
      expect do
        Filemaker::Error.raise_error_by_code(5)
      end.to raise_error Filemaker::Error::CommandInvalidError
    end

    it 'raises FileReadOnlyError for 6' do
      expect do
        Filemaker::Error.raise_error_by_code(6)
      end.to raise_error Filemaker::Error::FileReadOnlyError
    end

    it 'raises OutOfMemoryError for 7' do
      expect do
        Filemaker::Error.raise_error_by_code(7)
      end.to raise_error Filemaker::Error::OutOfMemoryError
    end

    it 'raises EmptyResultError for 8' do
      expect do
        Filemaker::Error.raise_error_by_code(8)
      end.to raise_error Filemaker::Error::EmptyResultError
    end

    it 'raises InsufficientPrivilegesError for 9' do
      expect do
        Filemaker::Error.raise_error_by_code(9)
      end.to raise_error Filemaker::Error::InsufficientPrivilegesError
    end

    it 'raises RequestedDataMissingError for 10' do
      expect do
        Filemaker::Error.raise_error_by_code(10)
      end.to raise_error Filemaker::Error::RequestedDataMissingError
    end
  end

  context '100 to 199 errors' do
    it 'raises FileMissingError for 100' do
      expect do
        Filemaker::Error.raise_error_by_code(100)
      end.to raise_error Filemaker::Error::FileMissingError
    end

    it 'raises RecordMissingError for 101' do
      expect do
        Filemaker::Error.raise_error_by_code(101)
      end.to raise_error Filemaker::Error::RecordMissingError
    end

    it 'raises FieldMissingError for 102' do
      expect do
        Filemaker::Error.raise_error_by_code(102)
      end.to raise_error Filemaker::Error::FieldMissingError
    end

    it 'raises ScriptMissingError for 104' do
      expect do
        Filemaker::Error.raise_error_by_code(104)
      end.to raise_error Filemaker::Error::ScriptMissingError
    end

    it 'raises LayoutMissingError for 105' do
      expect do
        Filemaker::Error.raise_error_by_code(105)
      end.to raise_error Filemaker::Error::LayoutMissingError
    end

    it 'raises TableMissingError for 106' do
      expect do
        Filemaker::Error.raise_error_by_code(106)
      end.to raise_error Filemaker::Error::TableMissingError
    end

    it 'raises MissingError for 116' do
      expect do
        Filemaker::Error.raise_error_by_code(106)
      end.to raise_error Filemaker::Error::MissingError
    end
  end

  context '200 to 299 errors' do
    it 'raises RecordAccessDeniedError for 200' do
      expect do
        Filemaker::Error.raise_error_by_code(200)
      end.to raise_error Filemaker::Error::RecordAccessDeniedError
    end

    it 'raises FieldCannotBeModifiedError for 201' do
      expect do
        Filemaker::Error.raise_error_by_code(201)
      end.to raise_error Filemaker::Error::FieldCannotBeModifiedError
    end

    it 'raises FieldAccessDeniedError for 202' do
      expect do
        Filemaker::Error.raise_error_by_code(202)
      end.to raise_error Filemaker::Error::FieldAccessDeniedError
    end
  end

  context '300 to 399 errors' do
    it 'raises FileLockedError for 300' do
      expect do
        Filemaker::Error.raise_error_by_code(300)
      end.to raise_error Filemaker::Error::FileLockedError
    end

    it 'raises FileLockedError for 301' do
      expect do
        Filemaker::Error.raise_error_by_code(301)
      end.to raise_error Filemaker::Error::RecordInUseError
    end

    it 'raises TableInUseError for 302' do
      expect do
        Filemaker::Error.raise_error_by_code(302)
      end.to raise_error Filemaker::Error::TableInUseError
    end

    it 'raises RecordModificationIdMismatchError for 306' do
      expect do
        Filemaker::Error.raise_error_by_code(306)
      end.to raise_error Filemaker::Error::RecordModificationIdMismatchError
    end
  end

  context '400 to 499 errors' do
    it 'raises FindCriteriaEmptyError for 400' do
      expect do
        Filemaker::Error.raise_error_by_code(400)
      end.to raise_error Filemaker::Error::FindCriteriaEmptyError
    end

    it 'raises NoRecordsFoundError for 401' do
      expect do
        Filemaker::Error.raise_error_by_code(401)
      end.to raise_error Filemaker::Error::NoRecordsFoundError
    end
  end

  context '500 to 599 errors' do
    it 'raises DateValidationError for 500' do
      expect do
        Filemaker::Error.raise_error_by_code(500)
      end.to raise_error Filemaker::Error::DateValidationError
    end

    it 'raises TimeValidationError for 501' do
      expect do
        Filemaker::Error.raise_error_by_code(501)
      end.to raise_error Filemaker::Error::TimeValidationError
    end

    it 'raises NumberValidationError for 502' do
      expect do
        Filemaker::Error.raise_error_by_code(502)
      end.to raise_error Filemaker::Error::NumberValidationError
    end

    it 'raises RangeValidationError for 503' do
      expect do
        Filemaker::Error.raise_error_by_code(503)
      end.to raise_error Filemaker::Error::RangeValidationError
    end

    it 'raises UniquenessValidationError for 504' do
      expect do
        Filemaker::Error.raise_error_by_code(504)
      end.to raise_error Filemaker::Error::UniquenessValidationError
    end

    it 'raises ExistingValidationError for 505' do
      expect do
        Filemaker::Error.raise_error_by_code(505)
      end.to raise_error Filemaker::Error::ExistingValidationError
    end

    it 'raises ValueListValidationError for 506' do
      expect do
        Filemaker::Error.raise_error_by_code(506)
      end.to raise_error Filemaker::Error::ValueListValidationError
    end

    it 'raises CalculationValidationError for 507' do
      expect do
        Filemaker::Error.raise_error_by_code(507)
      end.to raise_error Filemaker::Error::CalculationValidationError
    end

    it 'raises InvalidFindModeValueValidationError for 508' do
      expect do
        Filemaker::Error.raise_error_by_code(508)
      end.to raise_error Filemaker::Error::InvalidFindModeValueValidationError
    end

    it 'raises MaximumCharactersValidationError for 511' do
      expect do
        Filemaker::Error.raise_error_by_code(511)
      end.to raise_error Filemaker::Error::MaximumCharactersValidationError
    end
  end

  context '800 to 899 errors' do
    it 'raises UnableToCreateFileError for 800' do
      expect do
        Filemaker::Error.raise_error_by_code(800)
      end.to raise_error Filemaker::Error::UnableToCreateFileError
    end

    it 'raises UnableToCreateTempFileError for 801' do
      expect do
        Filemaker::Error.raise_error_by_code(801)
      end.to raise_error Filemaker::Error::UnableToCreateTempFileError
    end

    it 'raises UnableToOpenFileError for 802' do
      expect do
        Filemaker::Error.raise_error_by_code(802)
      end.to raise_error Filemaker::Error::UnableToOpenFileError
    end
  end

end
