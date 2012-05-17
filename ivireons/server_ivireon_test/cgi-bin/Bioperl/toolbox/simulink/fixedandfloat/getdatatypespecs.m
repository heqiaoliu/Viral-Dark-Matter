function DataTypeVec = getdatatypespecs( DataType, Scaling, DblOver, RadixGroup,specialActionCode, DataTypeMode, ScalingMode)
%GETDATATYPESPECS is for internal use only by Simulink
%
%  Combine various data type specs to form a complete specification vector
%  that is expected by Fixed Point Block S-Functions
%   
%   DataTypeVec(1) = UseDbl;
%   DataTypeVec(2) = MantBits;
%   DataTypeVec(3) = IsSigned;
%   DataTypeVec(4) = FixExp;
%   DataTypeVec(5) = Slope;
%   DataTypeVec(6) = Bias;
%   DataTypeVec(7) = RadixGroup;
%

% Copyright 1994-2010 The MathWorks, Inc.
% $Revision: 1.12.2.13 $  
% $Date: 2010/04/05 22:46:00 $

if nargin < 5 
  specialActionCode = 0;
end

if nargin < 6 
  DataTypeMode = 1;
end

if nargin < 7 
  ScalingMode = 0;
end
%
% default data type
%  needed to handle case when data type is specified by a variable
%  but the variable is undefined.
%
if isempty(DataType)
    DataType = uint(8);
end
%
% set indices of DataTypeVec elements
%
%    iUseDbl      = 1;
%    iMantBits    = 2;
%    iIsSigned    = 3; 
%    iFixExp      = 4;
%    iSlope       = 5;
%    iBias        = 6;
%    iRadixGroup  = 7;

% The values for the iUseDbl element MUST agree with a C enum in
% the fixedpoint module.  Currently, that enum is in a200_fixpt_types.c
% with definition.
%  typedef enum {
%
      FXP_DT_FIXPT         = 0;
      FXP_DT_SCALED_DOUBLE = 1;
      FXP_DT_DOUBLE        = 2;
      FXP_DT_SINGLE        = 3;
      FXP_DT_BOOLEAN       = 4;
      FXP_DT_CUSTOM_FLOAT  = 5;
%      
%  } fxpModeDataType;
%

% presize DataTypeVec with default choices
%    DataTypeVec(iUseDbl)     = FXP_DT_FIXPT;
%    DataTypeVec(iMantBits)   = 0;
%    DataTypeVec(iIsSigned)   = 0;
%    DataTypeVec(iFixExp)     = 0;
%    DataTypeVec(iSlope)      = 1;
%    DataTypeVec(iBias)       = 0;
%    DataTypeVec(iRadixGroup) = 0; best precision off
%
DataTypeVec = [FXP_DT_FIXPT 0 0 0 1 0 0];

if  DataTypeMode ~= 1 && ScalingMode ~= 1
    % the popup list always maintain Specified via dialog as 1
    % see sfix_dot.cpp, sfix_dtprop function for example 
    return;
end

isUnspecifiedScaling = 0;


DataType = translateTlcDataTypeRecord( DataType );

% 
% handle fixpt structure
%

if isstruct(DataType)
  %
  % handle the different classes
  %
  switch DataType.Class
    %
    % handle fixed point radix OR slope-n-bias scaling
    %
   case 'FIX'
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = DataType.IsSigned;
    if RadixGroup == 0
      if ~isempty(Scaling)
        [fslope,fixexp] = log2( Scaling(1) );
        fslope = fslope * 2;
        fixexp = fixexp - 1;
        DataTypeVec(4) = fixexp;
        DataTypeVec(5) = fslope;
        %
        % if second Scaling term is present it specifies the bias
        % otherwise bias stays at default of zero
        %
        if length(Scaling) > 1
          DataTypeVec(6) = Scaling(2);
        end
      else
        isUnspecifiedScaling = 1;
      end
    else
      DataTypeVec(7) = RadixGroup;
    end
    %
    % handle fixed point integer scaling
    %
   case 'INT'
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = DataType.IsSigned;
    %
    % handle fixed point fractional scaling
    %
   case 'FRAC'
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = DataType.IsSigned;
    DataTypeVec(4) = DataType.IsSigned-DataType.MantBits+DataType.GuardBits;
    %
    % handle floating point doubles
    %
   case 'DOUBLE'
    DataTypeVec(1) = FXP_DT_DOUBLE;
    %
    % handle floating point singles
    %
   case 'SINGLE'
    DataTypeVec(1) = FXP_DT_SINGLE;
    %
    % handle floating point custom
    %
   case 'FLOAT'
    % USE_CUSTOM_FLOAT
    DataTypeVec(1) = FXP_DT_CUSTOM_FLOAT - 1 + DataType.ExpBits;
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = 1;
    %
    % handle error
    %
    otherwise
      
      DAStudio.error('Shared:numericType:fixptDataTypeClassNotSupported');
  end  

% else if string
elseif ischar(DataType)
  switch DataType
   
   case 'double'
    DataTypeVec(1) = FXP_DT_DOUBLE;
   
   case 'single'
    DataTypeVec(1) = FXP_DT_SINGLE;
   
   case 'boolean'
    DataTypeVec(1) = FXP_DT_BOOLEAN;
   
   case 'int32'
    DataTypeVec(2) = 32;
    DataTypeVec(3) = 1;

   case 'int16'
    DataTypeVec(2) = 16;
    DataTypeVec(3) = 1;
   
   case 'int8'
    DataTypeVec(2) = 8;
    DataTypeVec(3) = 1;
   
   case 'uint32'
    DataTypeVec(2) = 32;
    DataTypeVec(3) = 0;
   
   case 'uint16'
    DataTypeVec(2) = 16;
    DataTypeVec(3) = 0;

   case 'uint8'
    DataTypeVec(2) = 8;
    DataTypeVec(3) = 0;
   
   otherwise
    try
      resDataType = evalin('base', DataType);
      DataTypeVec = getdatatypespecs(resDataType, Scaling, DblOver, RadixGroup, specialActionCode);
      return;
    catch %#ok
      DAStudio.error('Shared:numericType:fixdtUnrecognizedDataTypeNameStr',DataType);
    end  
  end
    
% else if Simulink.AliasType  
elseif isa(DataType, 'Simulink.AliasType')

  switch DataType.BaseType
   
   case 'double'
    DataTypeVec(1) = FXP_DT_DOUBLE;
   
   case 'single'
    DataTypeVec(1) = FXP_DT_SINGLE;
   
   case 'boolean'
    DataTypeVec(1) = FXP_DT_BOOLEAN;
   
   case 'int32'
    DataTypeVec(2) = 32;
    DataTypeVec(3) = 1;

   case 'int16'
    DataTypeVec(2) = 16;
    DataTypeVec(3) = 1;
   
   case 'int8'
    DataTypeVec(2) = 8;
    DataTypeVec(3) = 1;
   
   case 'uint32'
    DataTypeVec(2) = 32;
    DataTypeVec(3) = 0;
   
   case 'uint16'
    DataTypeVec(2) = 16;
    DataTypeVec(3) = 0;

   case 'uint8'
    DataTypeVec(2) = 8;
    DataTypeVec(3) = 0;
   
   otherwise
    try
      resDataType = evalin('base', DataType.BaseType);
      DataTypeVec = getdatatypespecs(resDataType, Scaling, DblOver, RadixGroup, specialActionCode);
      return;
    catch  %#ok
      DAStudio.error('Shared:numericType:fixdtUnrecognizedAliasDataTypeNameStr',DataType.BaseType);
    end  
  end    
  
elseif isnumerictype(DataType) || isa(DataType, 'Simulink.NumericType')
  %
  % handle the different classes
  %
  switch DataType.DataTypeModeNoWarning
    %
    % handle fixed point radix OR slope-n-bias scaling
    %
   case 'Fixed-point: unspecified scaling'
    DataTypeVec(2) = DataType.WordLength;
    DataTypeVec(3) = double(DataType.getSpecifiedSign);
    if RadixGroup == 0
      if ~isempty(Scaling)
        [fslope,fixexp] = log2( Scaling(1) );
        fslope = fslope * 2;
        fixexp = fixexp - 1;
        DataTypeVec(4) = fixexp;
        DataTypeVec(5) = fslope;
        %
        % if second Scaling term is present it specifies the bias
        % otherwise bias stays at default of zero
        %
        if length(Scaling) > 1
          DataTypeVec(6) = Scaling(2);
        end
      else
        isUnspecifiedScaling = 1;
      end
    else
      DataTypeVec(7) = RadixGroup;
    end
    %
    % handle fixed point integer scaling
    %
   case 'Fixed-point: slope and bias scaling'
    DataTypeVec(2) = DataType.WordLength;
    DataTypeVec(3) = double(DataType.getSpecifiedSign);
    DataTypeVec(4) = DataType.FixedExponent;
    DataTypeVec(5) = DataType.SlopeAdjustmentFactor;
    DataTypeVec(6) = DataType.Bias;
    %
    % handle fixed point fractional scaling
    %
   case 'Fixed-point: binary point scaling'
    DataTypeVec(2) = DataType.WordLength;
    DataTypeVec(3) = double(DataType.getSpecifiedSign);
    DataTypeVec(4) = DataType.FixedExponent;
    %
    % handle floating point doubles
    %
   case 'Double'
    DataTypeVec(1) = FXP_DT_DOUBLE;
    %
    % handle floating point singles
    %
   case 'Single'
    DataTypeVec(1) = FXP_DT_SINGLE;
    %
    % handle boolean
    %
   case 'Boolean'
    DataTypeVec(1) = FXP_DT_BOOLEAN;
   otherwise
    DAStudio.error('Shared:numericType:fixptDataTypeClassNotSupported');
  end  
elseif ( nargin == 1 && ...
         isnumeric(DataTypeVec) && ...
         ( ( length(DataType) ==  length(DataTypeVec)    ) || ...
           ( length(DataType) == (length(DataTypeVec)-1) ) ) && ...
         ( ( size(DataType,1) == 1 ) || ...
           ( size(DataType,2) == 1 ) ) )
  %
  % Allow DataTypeVec like [FXP_DT_FIXPT 0 0 0 1 0 0] to be converted to
  % data type object.
  %
  DataTypeVec = double(DataType);
  specialActionCode = 1;
else
  DAStudio.error('Shared:numericType:fixptDataTypeClassNotSupported');
end

% Make sure IsSigned has value 0 or 1, not something like 73
DataTypeVec(3) = DataTypeVec(3) ~= 0;

if (DataTypeVec(1) == FXP_DT_FIXPT           || ...
    DataTypeVec(1) == FXP_DT_SCALED_DOUBLE )

    FXP_MAX_BITS = 128;
  
    if DataTypeVec(2) <= DataTypeVec(3)

      DataTypeVec(2) = DataTypeVec(3) + 1; %#ok
      DAStudio.error('Shared:numericType:getdatatypespecTooFewBits');
    
      
    elseif DataTypeVec(2) > FXP_MAX_BITS

      DataTypeVec(2) = FXP_MAX_BITS; %#ok
      DAStudio.error('Shared:numericType:getdatatypespecTooManyBits');
      
    end

    if DataTypeVec(5) <= 0
      
      DataTypeVec(5) = 1; %#ok
      DAStudio.error('Shared:numericType:getdatatypespecSlopeMustBePositive');
      
    end
end


if specialActionCode
  %
  % The specialActionCode has following meanings
  %    Value 0 means never return an object (just a vector). 
  %    Value 1 means return an object with scaling (default scaling if necessary).
  %    Value 2 means return an object with or without scaling based on input args
  %    Value 3 means just determine if scaling is specified.
  %    Value 4 means return a string that can be evaluated to a data type specification
  %
  if specialActionCode == 3
    %
    % Dialogs of masked or DDG based core Simulink blocks, manage the
    % visibility of things related to data types using the callbacks.
    % The callbacks determine if the Scaling Edit Field is need by calling
    % this function to determine if the Data Type Edit Field gives the scaling
    % info or not.  This specialActionCode case supports that use.
    %
    DataTypeVec = ~isUnspecifiedScaling;
    return;
  end

  getStringForEval = ( 4 == specialActionCode );

  switch DataTypeVec(1)
    
   case FXP_DT_FIXPT

    allowUnspecifiedScaling = ( 2 == specialActionCode || getStringForEval );
    
    if isUnspecifiedScaling && allowUnspecifiedScaling

      % Return object with unspecified scaling
      DataTypeVec = fixdt( DataTypeVec(3), ...
                           DataTypeVec(2));
    
    elseif ( ( 1.0 == DataTypeVec(5) ) && ...
             ( 0.0 == DataTypeVec(6) ) )
      
      % Return object with scaling
      DataTypeVec = fixdt( DataTypeVec(3), ...
                           DataTypeVec(2), ...
                           -DataTypeVec(4));
    
    else
      
      % Return object with scaling
      DataTypeVec = fixdt( DataTypeVec(3), ...
                           DataTypeVec(2), ...
                           DataTypeVec(5), ...
                           DataTypeVec(4), ...
                           DataTypeVec(6));
    end
    
   case FXP_DT_SCALED_DOUBLE

    DAStudio.error('Shared:numericType:getdatatypespecNoScaledDoubles');

   case FXP_DT_DOUBLE

    DataTypeVec = fixdt('double');
    
   case FXP_DT_SINGLE
    
    DataTypeVec = fixdt('single');
    
   case FXP_DT_BOOLEAN
    
    DataTypeVec = fixdt('boolean');
    
   otherwise

    expBits   = DataTypeVec(1) - FXP_DT_CUSTOM_FLOAT + 1;
    totalBits = DataTypeVec(2) + expBits + 1;

    if getStringForEval
        DataTypeVec = sprintf('float(%d,%d)',totalBits,expBits);
    else
        DataTypeVec = float(totalBits,expBits);
    end

  end

  if getStringForEval && ~ischar(DataTypeVec)

      DataTypeVec = fixdt(DataTypeVec);
  end
  
end


function outDt = translateTlcDataTypeRecord( inDt )

if isstruct(inDt) && isfield(inDt,'RequiredBits')

    builtinNames = { 
        'double'
        'single'
        'int8'
        'uint8'
        'int16'
        'uint16'
        'int32'
        'uint32'
        'boolean'
        };
    
    if isfield(inDt,'DTName') && any(strcmp(inDt.DTName,builtinNames))
        
        outDt = fixdt(inDt.DTName);
        
    elseif isfield(inDt,'Id') && ( 0 <= inDt.Id ) && ( inDt.Id <= 8 )
        
        outDt = fixdt(builtinNames{inDt.Id+1});
        
    elseif isfield(inDt,'NativeType') && strcmp(inDt.NativeType,'real_T')
            
        outDt = fixdt('double');
            
    elseif isfield(inDt,'NativeType') && strcmp(inDt.NativeType,'real32_T')
            
        outDt = fixdt('single');
            
    else
        
        outDt = fixdt(inDt.IsSigned,inDt.RequiredBits,inDt.FracSlope,inDt.FixedExp,inDt.Bias);
    end
    
else
    
    outDt = inDt;

end
