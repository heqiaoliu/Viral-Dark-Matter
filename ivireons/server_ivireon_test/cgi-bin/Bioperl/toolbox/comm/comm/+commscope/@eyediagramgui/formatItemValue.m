function [formattedValue units] = formatItemValue(this, value, fracDigits, itemUnit)
%FORMATITEMVALUE Format the value using engineering units
%   Formats the value using engineering units and FRACDIGITS fractional digits.
%   Returns FORMATTEDVALUE and UNITS, which is the engineering unit prefix.

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:14:52 $

if ischar(value)
    % If char then do not format
    formattedValue = {value};
    units = '';
elseif isnan(value)
    % NaN
    formattedValue = {'-'};
    units = '';
else
    if isempty(itemUnit) || strncmp(itemUnit, '%', 1)
        y = value;
        units = '';
    else
        [y e units] = engunits(value);
        % Make sure the significant digits are used properly.  enguints returns
        % 999.9999999 and m for input 0.99999999999.  SInce fracDigit controls
        % significant digits, we should round this, e.g. if fracDigit is 3, then
        % this should be 1 and no engineeing units.
        if round(abs(y)+10^(-fracDigits)) == 1000
            olde = e;
            [y e units] = engunits(value*olde);
            y = y / olde;
        end
    end

    basicFormat = ['%1.' num2str(fracDigits) 'g'];
    
    [M N] = size(value);
    if N >1
        % If more than one value, then use [val1 val2 ...] format
        formatStr = ['[' repmat([basicFormat ' '], 1, N)];
        formatStr(end) = ']';
    else
        formatStr = basicFormat;
    end
        
    formattedValue = cell(M,1);
    for p=1:M
        itemValue = sprintf(formatStr, y(p, :));
        itemValue = regexprep(itemValue, 'e-0*', 'e-');
        itemValue = regexprep(itemValue, 'e\+0*', 'e');
        formattedValue{p} = itemValue;
    end
end

%-------------------------------------------------------------------------------
% [EOF]
