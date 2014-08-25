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
  end

end
