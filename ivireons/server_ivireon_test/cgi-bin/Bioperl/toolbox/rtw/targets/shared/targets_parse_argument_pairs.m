function args = targets_parse_argument_pairs(allowedArgNames, argCell)
% TARGETS_PARSE_ARGUMENT_PAIRS - Parse argument pairs from a cell array
%                                and check for valid argument names.
%
% args = targets_parse_argument_pairs(allowedArgNames, argCell)
%
% allowedArgNames: Cell array of allowed argument names (must be non-empty)
% argCell: Cell array of argument pairs (can be empty)
%
% args: Struct with a field for each argument name and field value with
% corresponding argument value.
% 

% Copyright 2005-2009 The MathWorks, Inc.

error(nargchk(1, 2, nargin, 'struct'))

% check arguments
if isempty(allowedArgNames)
  rtw.pil.ProductInfo.error('pil', 'InvalidArgumentNames');
end

if ~iscell(argCell)
  rtw.pil.ProductInfo.error('pil', 'InvalidArgumentPairs');
end

% create a display version of the allowed argument names
allowedArgNamesStr = ['"' allowedArgNames{1} '"'];
for i=2:length(allowedArgNames)
    allowedArgNamesStr = [allowedArgNamesStr ', "' allowedArgNames{i} '"'];  %#ok
end
       
% check for pairs
if mod(length(argCell),2)
  rtw.pil.ProductInfo.error('pil', 'ArgumentsInNameValuePairs', allowedArgNamesStr);
end

% create struct
args = [];
for i=1:2:length(argCell)
     args.(argCell{i}) = argCell{i+1};
end

% check that parsed arguments are allowed
if ~isempty(args)
    actualArgNames = fieldnames(args);
    unknownArgNames = setdiff(actualArgNames, allowedArgNames);
    if ~isempty(unknownArgNames)
        unknownArgNamesStr = ['"' unknownArgNames{1} '"'];
        for i=2:length(unknownArgNames)
            unknownArgNamesStr = [unknownArgNamesStr ', "' unknownArgNames{i} '"']; %#ok
        end
        %
        rtw.pil.ProductInfo.error('pil', 'InvalidArgument', ['Unknown argument name(s): ' unknownArgNamesStr sprintf('\n') 'Allowed argument name(s): ' allowedArgNamesStr]);
    end
end
