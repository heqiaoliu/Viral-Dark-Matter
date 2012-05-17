function numtype = util_get_numerictype(fixdtType)
   
    DataTypeMode = fixdtType.DataTypeMode;
    Signed = fixdtType.Signed;
    WordLength = fixdtType.WordLength;
    
    if strcmp(DataTypeMode,'Fixed-point: binary point scaling')        
        FractionLength = fixdtType.FractionLength;
        numtype = numerictype(Signed,WordLength,FractionLength);
    elseif strcmp(DataTypeMode,'Fixed-point: slope and bias scaling')
        Slope = fixdtType.Slope;
        Bias = fixdtType.Bias;
        numtype = numerictype(Signed,WordLength,Slope,Bias);
    else
        error('SLDV:UtilGetNumerictype',...
              'The data type mode ''%s'' is not recognized as binary point or  slope and bias scaling',DataTypeMode);        
    end
    
end