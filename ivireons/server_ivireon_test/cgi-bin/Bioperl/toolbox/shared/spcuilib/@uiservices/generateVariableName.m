function variableName = generateVariableName(variableName)
%GENERATEVARIABLENAME Generate a valid variable name given a string.
%   uiservices.generateVariableName(VarName) Returns a string which is a
%   modified version of VarName, such that it can be used as the name of a
%   variable or structure field.

%   Unlike the generic GENVARNAME, this function replaces invalid
%   characters with '_' instead of a unique numeric identifier.  This
%   results in the output being a more readable string, but can result in
%   non-unique outputs for unique inputs.  For instance 'var%1' and 'var#1'
%   both return 'var_1'.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 19:35:05 $

if ~isvarname(variableName)
    %check length
    if length(variableName) > namelengthmax
        variableName = variableName(1:namelengthmax);
    end
    
    % check first char
    if ~isvarname(variableName(1))
        variableName(1) = 'A';
    end
    
    % check remaining and replace invalid characters with '_'
    for indx=2:length(variableName)
        if isvarname(variableName(1:indx))
            continue;
        else
            variableName(indx) = '_';
        end
    end
end

% [EOF]
