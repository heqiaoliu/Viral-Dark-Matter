function [T,F,ERR,val,isautoscaled] = eml_sfiufi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,issigned,varargin)
% SFI(VAL,WL,FL) will return a signed FI object with value VAL, 
% word-length WL, fraction-length Fl and an empty fimath

%   Copyright 2008-2010 The MathWorks, Inc.

T = []; F = []; val = []; isautoscaled = false;
ERR = ''; %#ok

lvar = length(varargin);
if lvar < 1 || lvar > 5
    ERR = 'Too many input arguments.';
    return;
end

% Check to make sure that varargin is numeric and let embedded.fi do the error checking
for idx = 1:lvar
    if ~isnumeric(varargin{idx})
        ERR = 'Input must be numeric.';
        return;
    end
end
varargin = [varargin(1),issigned,varargin(2:end)];
% Pass in a dummySize input to eml_fi_constructor helper. In this context this input is un-necessary (since it is used to check for data specified by PV pairs, but that cannto happen with sfi or ufi) 
dummySize = [1 1];
[T,F,ERR,val,isautoscaled] = eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,dummySize,varargin{:});

%--------------------------------------------------------------------------
