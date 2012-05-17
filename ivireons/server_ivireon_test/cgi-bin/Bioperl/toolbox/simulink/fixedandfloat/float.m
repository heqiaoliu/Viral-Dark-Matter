function DataType = float( TotalBits, ExpBits )
%FLOAT Create structure describing a floating point data type
%
%    This data type structure can be passed to the 
%    Simulink Blocks.
%
%    FLOAT( 'single' )
%
%      Returns a MATLAB structure that describes the data type of
%      an IEEE Single (32 total bits, 8 exponent bits).
%
%    FLOAT( 'double' )
%
%      Returns a MATLAB structure that describes the data type of
%      an IEEE Double (64 total bits, 11 exponent bits).
%
%    Note: Support for custom floating point data types has been removed.
%      To handle this removal, either:
%      - Replace calls to FLOAT( TotalBits, ExpBits ) with calls to 
%        FIXDT('double') or FIXDT('single').
%      - Write a function custom_float_user_replacement.m and place this 
%        file on your MATLAB path. This function must take TotalBits and
%        ExpBits as input arguments and return a supported numerictype object,
%        for example, FIXDT('double') or FIXDT('single'). If 
%        custom_float_user_replacement.m exists, calls to 
%        FLOAT( TotalBits, ExpBits ) automatically call 
%        custom_float_user_replacement( TotalBits, ExpBits ) and return the 
%        numerictype object that it outputs. This replacement mechanism will 
%        continue to work in future releases if custom_float_user_replacement.m
%        is on your MATLAB path.
%
%    See also FIXDT.

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.10.2.7 $  
% $Date: 2010/01/25 22:59:06 $


if (nargin == 1)
    if ischar(TotalBits)
        if strcmpi(TotalBits, 'SINGLE')
            DataType = struct('Class','SINGLE');
        elseif strcmpi(TotalBits, 'DOUBLE')
            DataType = struct('Class','DOUBLE');
        else
            DAStudio.error('Shared:numericType:floatUnrecognizedDataTypeName',TotalBits);
        end
        return;
    else
        DAStudio.error('Shared:numericType:floatUnSupportedInputType',class(TotalBits));
    end
elseif (nargin == 2)
    if isnumeric(TotalBits) && isnumeric(ExpBits)
        if (TotalBits == 64) && (ExpBits == 11)
            DataType = struct('Class','DOUBLE');
        elseif (TotalBits == 32) && (ExpBits == 8)
            DataType = struct('Class','SINGLE');
        else
            if exist('custom_float_user_replacement','file')
                DataType = custom_float_user_replacement( TotalBits, ExpBits );
            else
                DAStudio.error('Shared:numericType:customFloatSupportRemove', TotalBits, ExpBits );
            end
        end
    else
        DAStudio.error('Shared:numericType:floatCustomNumerics');
    end  
elseif (nargin == 0)
    DAStudio.error('Shared:numericType:floatNoArg');
end

