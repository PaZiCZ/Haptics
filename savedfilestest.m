function savedfilestest(saveFolder)
    filelistXlsx = dir(fullfile(saveFolder, '*.xlsx'));
    filelistCsv = dir(fullfile(saveFolder, '*.csv'));
    ValidateXlsx(filelistXlsx);
    ValidateCsv(filelistCsv);
end