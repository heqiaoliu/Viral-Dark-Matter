function [DataType,IsScaledDouble] = fixdt( varargin )
%  FIXDT Create an object describing a fixed-point or floating-point data type
%
%  This data type object can be passed to Simulink blocks that support
%  fixed-point data types.
%
%  Usage 1: Fixed-Point Data Type With Unspecified scaling
%          Scaling would typically be determined by another block parameter.
%
%   FIXDT( Signed, WordLength )
%
%  Usage 2: Fixed-Point Data Type With Binary point scaling
%
%   FIXDT( Signed, WordLength, FractionLength )
%
%  Usage 3: Slope and Bias scaling
%
%   FIXDT( Signed, WordLength, TotalSlope, Bias )
%  or
%   FIXDT( Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias )
%
%  Usage 4: Data Type Name String
%
%   FIXDT( DataTypeNameString )
%  or
%   [DataTypeObject,IsScaledDouble] = FIXDT( DataTypeNameString )
%     
%   The data type name string is the same string that would be displayed on 
%   signal lines in a Simulink model.  The optional setting to display port 
%   data types is found under the Simulink Format menu.
%
%   Examples using standard data types:
%
%      fixdt('double');
%      fixdt('single');
%      fixdt('uint8');
%      fixdt('uint16');
%      fixdt('uint32');
%      fixdt('int8');
%      fixdt('int16');
%      fixdt('int32');
%      fixdt('boolean');
%
%   Key to fixed-point data type names: 
%
%      Simulink data type names are required to be valid matlab 
%      identifiers.  Fixed-point data types are encoded using 
%      the following rules.
%          
%      Container
%
%        'ufix#'  unsigned with # bits  Ex. ufix3   is unsigned   3 bits
%        'sfix#'  signed   with # bits  Ex. sfix128 is signed   128 bits
%        'flts#'  scaled double data type override of sfix#
%        'fltu#'  scaled double data type override of ufix#
%
%      Number encoding
%
%        'n'      minus sign,           Ex. 'n31' equals -31
%        'p'      decimal point         Ex. '1p5' equals 1.5
%        'e'      power of 10 exponent  Ex. '125e18' equals 125*(10^(18))
%
%      Scaling Terms from the fixed-point scaling equation
% 
%           RealWorldValue = S * StoredInteger + B
%        'S'      TotalSlope              default value is 1
%        'B'      Bias                    default value is 0
%
%         or if S is not given, 
%           RealWorldValue = F * 2^E * StoredInteger + B
%
%        'E'      FixedExponent           default value is 0
%        'F'      SlopeAdjustmentFactor   default value is 1
%
%      Compressed scaling encodings are used when normal encodings 
%      for Slope or Bias produce a data type name that would exceed
%      the character limit.  The compressed encoding for Slope begins with
%      'T' or 't' and is a 12 character substring.  The compressed
%      encoding for Bias begins with 'C','c','D', or 'd' and is a 12 character
%      substring.
%
%     Examples:
%
%     % using integers with non-standard number of bits
%
%        fixdt('ufix1');       % Unsigned  1 bit
%        fixdt('sfix77');      % Signed   77 bits
%
%     % using binary point scaling
%
%        fixdt('sfix32_En31');    % Fraction length 31  
%
%     % using slope and bias scaling
%
%        fixdt('ufix16_S5');          % TotalSlope 5 
%        fixdt('sfix16_B7');          % Bias 7
%        fixdt('ufix16_F1p5_En50');   % SlopeAdjustmentFactor 1.5  FixedExponent -50
%        fixdt('ufix16_S5_B7');       % TotalSlope 5, Bias 7
%        fixdt('sfix8_Bn125e18');     % Bias -125*10^18
%
%   Scaled Doubles
%
%     Scaled doubles data types are a testing and debugging feature.  Scaled
%     doubles occur when two conditions are met.  First, an integer or 
%     fixed-point data type is entered into a Simulink  block's mask.  Second,
%     the dominant parent subsystem has data type override setting of scaled 
%     doubles.  When this happens, a data type like 'sfix16_En7' is overridden
%     with a scaled doubles data type 'flts16_En7'.  
%        The first output of FIXDT will be the same whether the original 
%     data type 'sfix16_En7' is passed in or it's scaled doubles version
%     'flts16_En7' is passed in.  The optional second output argument 
%     is true if and only if the input is a scaled doubles data type.
%
%  Usage 5: Data Type Object converted to eval ready string
%
%   stringReadyForEval = FIXDT( DataTypeObject )
%
%   The string that is returned is useful for configuring data types on blocks.
%
%   Examples: 
%
%       dataTypeObject   = fixdt(1,16,15);
%       stringReadyForEval = fixdt(dataTypeObject);
%       eval(stringReadyForEval);
%
%       open_system('fxpdemo_dbl2fix');
%       set_param('fxpdemo_dbl2fix/Dbl-to-FixPt','OutDataTypeStr',stringReadyForEval);
%
%   See also SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2010 The MathWorks, Inc.
% $Revision: 1.1.6.15 $  $Date: 2010/04/05 22:45:57 $

IsScaledDouble = false;

DataType = Simulink.NumericType;

% check the input argument in form as expected
if nargin == 0
    DAStudio.error('Shared:numericType:fixdtAtLeastOneInput'); 
end

if nargin > 7
    DAStudio.error('Shared:numericType:fixdtInputArgsMustBeNoMoreThanSeven');
end
% input one args
if nargin == 1
    [DataType,IsScaledDouble] = resolveNonNumericInput(DataType, varargin{1});
    return;
end

% input two args, cannot have property-value pair
if nargin == 2
    [SignednessBool, WordLength] = checkInputSignAndWL(varargin{1}, varargin{2});

    DataType.DataTypeMode = 'Fixed-point: unspecified scaling';
    
    DataType.SignednessBool = SignednessBool;
    
    DataType.WordLength = WordLength;
end
      
if nargin >= 3
    % detect if there is property value pairs
    propIndex = nargin - 1;
    if strcmpi(varargin{propIndex}, 'DataTypeOverride')
        % explicitly set DataTypeOverride property
        valueIndex = propIndex -1;
        try
            [DataType,IsScaledDouble] = fixdt(varargin{1:valueIndex});
            propVal = parseDTOPropValuePair(varargin{nargin});
            DataType.DataTypeOverride = propVal;
            return;
        catch exMsg
            throw(exMsg);
        end
    else
        % either property not in the right place, or it is not set
        % explicitly
%         if strmatch('DataTypeOverride', varargin)
%             DAStudio.error('Shared:numericType:fixdtTwoInputFormat');            
%         else
            valueIndex = nargin;
%         end % handle all other cases as before        
    end
              
  if valueIndex == 3
      % could be one case: fixdt(sig, wl, fl)     
      thirdInputArg = varargin{3}; 
      
      [SignednessBool, WordLength] = checkInputSignAndWL(varargin{1}, varargin{2});
      DataType.DataTypeMode = 'Fixed-point: binary point scaling';
      
      DataType.SignednessBool = SignednessBool;
          
      DataType.WordLength = WordLength;

      if isnumeric(thirdInputArg)
          DataType.FractionLength = thirdInputArg;
          return;
      else
          DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',thirdInputArg);
      end
  end
  
  if valueIndex == 4
      % case: fixdt(sig, wl, totalslope, bias)
      thirdInputArg = varargin{3}; 
      fourthInputArg = varargin{4}; 

      [SignednessBool, WordLength] = checkInputSignAndWL(varargin{1}, varargin{2});

      DataType.DataTypeMode = 'Fixed-point: slope and bias scaling';
      
      DataType.SignednessBool = SignednessBool;
          
      DataType.WordLength = WordLength;

      if isnumeric(thirdInputArg)
          DataType.Slope = thirdInputArg;
      else
          DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',thirdInputArg);
      end
      
      if isnumeric(fourthInputArg)
          DataType.Bias = fourthInputArg;
          return;
      else
          DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',fourthInputArg);
      end
  end
  
  if valueIndex == 5
      % case: fixdt(sig, wl, slopeAdjust, exp, bias)
      thirdInputArg = varargin{3}; 
      fourthInputArg = varargin{4}; 
      fifthInputArg = varargin{5}; 

      [SignednessBool, WordLength] = checkInputSignAndWL(varargin{1}, varargin{2});

      DataType.DataTypeMode = 'Fixed-point: slope and bias scaling';
      
      DataType.SignednessBool = SignednessBool;
          
      DataType.WordLength = WordLength;

      if isnumeric(thirdInputArg) && isnumeric(fourthInputArg)
          DataType.Slope = double(varargin{3}) * 2^double(varargin{4});
      elseif ~isnumeric(thirdInputArg)
          DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',thirdInputArg);
      elseif ~isnumeric(fourthInputArg)
          DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',fourthInputArg);
      end
      
      if isnumeric(fifthInputArg)
          DataType.Bias = fifthInputArg;
          return;
      else
          DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',fifthInputArg);
      end
  end
 
  if valueIndex > 5 % more than 7 arg
          DAStudio.error('Shared:numericType:fixdtInputArgsMustBeNoMoreThanFive');
  end
end

function encodedValue  = getCodeValue(curCodeStr,mantissa_positive,exp_positive)
    
setSymbols = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

nSymbols = length(setSymbols);

expV1 = find(curCodeStr(2)==setSymbols) - 1;
expV2 = find(curCodeStr(3)==setSymbols) - 1;

expValue = expV1 * nSymbols + expV2;

mantissaValue = 0;

for i=4:12

    mantissaValue = mantissaValue * nSymbols;

    curV = find(curCodeStr(i)==setSymbols) - 1;
    
    mantissaValue = mantissaValue + curV;
end    

if ~exp_positive

    expValue = -expValue;
end

if ~mantissa_positive
    
    mantissaValue = -mantissaValue;
end

encodedValue = mantissaValue * 2^(expValue);


function [encodedSlope, encodedBias, remainDataTypeNameStr] = getEncodedSlopeBias(dataTypeNameStr,pos)
    
encodedSlope = [];
encodedBias = [];
remainDataTypeNameStr = dataTypeNameStr;

specialCodes = 'TtCcDd';

nSpecialCodes = length(specialCodes);

codeFound = 1;

codeSet = {};

while codeFound

    iFirstSpecialCode = realmax;

    for iCode = 1:nSpecialCodes

        ii = (pos-1) + find( specialCodes(iCode) == remainDataTypeNameStr(pos:end) );
    
        if ~isempty(ii)
            
            iFirstSpecialCode = min( iFirstSpecialCode, ii(1) );
        end
    end
    
    if iFirstSpecialCode < realmax
        
        codeSet{end+1} = remainDataTypeNameStr( iFirstSpecialCode + (0:11) ); %#ok
        
        remainDataTypeNameStr( iFirstSpecialCode + (0:11) ) = [];
   
        if iFirstSpecialCode > 1

            if '_' == remainDataTypeNameStr( iFirstSpecialCode-1 )
                
                remainDataTypeNameStr( iFirstSpecialCode-1 ) = [];
            end
        end
    else
        codeFound = 0;
    end
end

for iFound = 1:length(codeSet)
    
    curCode = codeSet{iFound};

    switch curCode(1)
        
      case 'T'
        encodedSlope = getCodeValue(curCode,1,1);
      case 't'
        encodedSlope = getCodeValue(curCode,1,0);
      case 'C'
        encodedBias  = getCodeValue(curCode,1,1);
      case 'c'
        encodedBias  = getCodeValue(curCode,1,0);
      case 'D'
        encodedBias  = getCodeValue(curCode,0,1);
      case 'd'
        encodedBias  = getCodeValue(curCode,0,0);
    end        
end        


function [DataType,IsScaledDouble] = ResolveFixPtType(dataTypeNameStr)
  
  DataType = Simulink.NumericType;

  pos = 1;
  
  signed   = 0;
  slope    = 1;
  fraction = 1;
  exponent = 0;
  bias     = 0;
  IsScaledDouble = false;
  
  switch dataTypeNameStr(pos)
   case 's'
    signed = 1;
    pos = 5;
   case 'u'
    signed = 0;
    pos = 5;
   case 'f'
    pos = 4;
    IsScaledDouble = true;
    if (dataTypeNameStr(pos) == 's')
      signed  = 1;
      pos = 5;
    elseif (dataTypeNameStr(pos) == 'u')
      pos = 5;
    else
      % must be a custom float
      IsScaledDouble = false;
      DataType = eval(['float(',strrep(dataTypeNameStr(pos:end),'E',','),')']);
      return
    end
   otherwise
    DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',dataTypeNameStr);
  end

  [encodedSlope, encodedBias, dataTypeNameStr] = getEncodedSlopeBias(dataTypeNameStr,pos);

  end_pos = length(dataTypeNameStr);
  
  sep = findstr(dataTypeNameStr(pos:end), '_');
  
  if isempty(sep)
    next_pos = end_pos;
  else
    next_pos = pos+sep(1)-2;   
  end
   
  try 
    WordLength = eval(dataTypeNameStr(pos:next_pos));
  catch %#ok
    WordLength = 0;
  end
  
  pos = next_pos + 2;
  
  while (pos < end_pos) 
    sep = findstr(dataTypeNameStr(pos:end), '_');
    
    if isempty(sep)
      next_pos = end_pos;
    else
      next_pos = pos+sep(1)-2;
    end 
  
    switch dataTypeNameStr(pos)
     case 'S'
      slope = ...
	  eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
     case 'E'
      exponent = ...
	  eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
     case 'B'
      bias = ...
	  eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
     case 'F'
      fraction = ...
	  eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
     otherwise
          DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',dataTypeNameStr);
    end
    pos = next_pos + 2;
  end

  if ~isempty(encodedSlope)

      slope = encodedSlope;
      fraction = 1;
      exponent = 0;
  end
  
  if ~isempty(encodedBias)

      bias = encodedBias;
  end
  
  if ( slope == 1 && fraction == 1 && bias == 0 )
    
    DataType.DataTypeMode = 'Fixed-point: binary point scaling';
    
    DataType.SignednessBool = signed;
    
    DataType.WordLength = WordLength;
    
    DataType.FixedExponent = exponent;
    
  else
    
    DataType.DataTypeMode = 'Fixed-point: slope and bias scaling';
    
    DataType.SignednessBool = signed;
    
    DataType.WordLength = WordLength;
    
    TotalSlope = slope * fraction * 2^exponent;
    
    [fff,eee] = log2( TotalSlope );
    
    fff = 2 * fff;
    eee = eee - 1;
    
    DataType.FixedExponent = eee;
    
    DataType.SlopeAdjustmentFactor = fff;
    
    DataType.Bias = bias;
    
  end


function [strForEval,IsScaledDouble] = DataTypeObjToStrForEval(dataTypeObj)

  IsScaledDouble = 1;
  
  if isempty(dataTypeObj.SignednessBool)
      sign = '[]';
  elseif dataTypeObj.SignednessBool
      sign = '1';
  else
      sign = '0';
  end
  
  if strcmpi(dataTypeObj.DataTypeOverride, 'inherit')
      DTOProp = '';
  else
      DTOProp = [',', '''DataTypeOverride''', ',', '''Off'''];
  end
      
  
  switch dataTypeObj.DataTypeModeNoWarning

   case 'Fixed-point: unspecified scaling'

    strForEval = sprintf('fixdt(%s,%d%s)', ...
                         sign, ...
                         dataTypeObj.WordLength, ...
                         DTOProp);
    
   case 'Fixed-point: slope and bias scaling'

     SlopeStr1 = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(dataTypeObj.Slope);
     
     SlopeAdjustStr = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(dataTypeObj.SlopeAdjustmentFactor);

     SlopeStr2 = sprintf('%s,%d', ...
                         SlopeAdjustStr, ...
                         dataTypeObj.FixedExponent);
     
     if length(SlopeStr1) <= ( length(SlopeStr2) + 4 )
         SlopeStr = SlopeStr1;
     else
         SlopeStr = SlopeStr2;
     end
     
     BiasStr = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(dataTypeObj.Bias);

     strForEval = sprintf('fixdt(%s,%d,%s,%s%s)', ...
                          sign, ...
                          dataTypeObj.WordLength, ...
                          SlopeStr, ...
                          BiasStr, ...
                          DTOProp);
    
   case 'Fixed-point: binary point scaling'

    strForEval = sprintf('fixdt(%s,%d,%d%s)', ...
                         sign, ...
                         dataTypeObj.WordLength, ...
                         dataTypeObj.FractionLength, ...
                         DTOProp);
   
   case 'Double'

    strForEval = sprintf('fixdt(%s%s)', ...
                    '''double''', DTOProp);
   
   case 'Single'
    
    strForEval = sprintf('fixdt(%s%s)', ...
                    '''single''', DTOProp);
   
   case 'Boolean'

    strForEval = sprintf('fixdt(%s%s)', ...
                    '''boolean''', DTOProp);
   
   otherwise

    DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeObj');
  end  

function [DataType,IsScaledDouble] = getFromBuiltInTypesStr(DataType, dataTypeNameStr)
    
IsScaledDouble = false;
switch lower(dataTypeNameStr)
    
    case 'double'
        DataType.DataTypeMode = 'Double';
        
    case 'single'
        DataType.DataTypeMode = 'Single';
        
    case 'float'
        DataType.DataTypeMode = 'Single';
        
    case 'boolean'
        DataType.DataTypeMode = 'Boolean';
        
    case 'bool'
        DataType.DataTypeMode = 'Boolean';
        
    case 'int32'
        DataType.DataTypeMode = 'Fixed-point: binary point scaling';
        DataType.SignednessBool = true;
        DataType.WordLength = 32;
        DataType.FixedExponent = 0;
        
    case 'int16'
        DataType.DataTypeMode = 'Fixed-point: binary point scaling';
        DataType.SignednessBool = true;
        DataType.WordLength = 16;
        DataType.FixedExponent = 0;
        
    case 'int8'
        DataType.DataTypeMode = 'Fixed-point: binary point scaling';
        DataType.SignednessBool = true;
        DataType.WordLength = 8;
        DataType.FixedExponent = 0;
        
    case 'uint32'
        DataType.DataTypeMode = 'Fixed-point: binary point scaling';
        DataType.SignednessBool = false;
        DataType.WordLength = 32;
        DataType.FixedExponent = 0;
        
    case 'uint16'
        DataType.DataTypeMode = 'Fixed-point: binary point scaling';
        DataType.SignednessBool = false;
        DataType.WordLength = 16;
        DataType.FixedExponent = 0;
        
    case 'uint8'
        DataType.DataTypeMode = 'Fixed-point: binary point scaling';
        DataType.SignednessBool = false;
        DataType.WordLength = 8;
        DataType.FixedExponent = 0;
        
    otherwise
        
        if (strncmp(dataTypeNameStr, 'sfix', 4) || ...
                strncmp(dataTypeNameStr, 'ufix', 4) || ...
                strncmp(dataTypeNameStr, 'flt',  3))
                       
            [DataType,IsScaledDouble] = ResolveFixPtType(dataTypeNameStr);
            
        else
            DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',dataTypeNameStr);
        end
end

function [DataType,IsScaledDouble] = resolveNonNumericInput(DataType, firstInputArg)

IsScaledDouble = false;

if ischar(firstInputArg)
    
    dataTypeNameStr = firstInputArg;
    
    % replace it with function call
    [DataType,IsScaledDouble] = getFromBuiltInTypesStr(DataType, dataTypeNameStr);
    
elseif isnumerictype(firstInputArg) || isa(firstInputArg, 'Simulink.NumericType')
    
    [DataType,IsScaledDouble] = DataTypeObjToStrForEval(firstInputArg);
    
elseif isstruct(firstInputArg)
    
    DataType = getdatatypespecs(firstInputArg,[],0,0,4);
    
else
    
    DAStudio.error('Shared:numericType:fixdtJustOneArgMustBe');
end

function propVal = parseDTOPropValuePair(valArg)
if strcmpi(valArg, 'inherit') || strcmpi(valArg, 'off')
    propVal = valArg; 
else
    DAStudio.error('Shared:numericType:fixdtIncorrectDTOSetting');
end

function [SignednessBool, WordLength] = checkInputSignAndWL(var1, var2)
if (islogical(var1) || isnumeric(var1)) 
    SignednessBool = var1;
else
    DAStudio.error('Shared:numericType:fixdtTwoInputFormat');
end

if isnumeric(var2)
    WordLength =  var2;
else
    DAStudio.error('Shared:numericType:fixdtTwoInputFormat');
end

