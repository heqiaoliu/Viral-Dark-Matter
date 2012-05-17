function strs = relpath(modelname, strs)
% RELPATH Removes the model name, if necessary, from the beginning of a
% string or a cell array of strings representing the absolute path names for
% various model components.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:59:33 $

flag = false;

% Convert from char array to cell array.
if ischar(strs)
  strs = {strs};
  flag = true;
end

if iscellstr(strs)
  % Make relative paths empty if strings are the same as the model name.
  cmp = strcmp(modelname, strs);
  strs(cmp) = {''};

  % Create relative paths if strings contain the model name.
  idxs = strmatch(modelname, strs);
  strs(idxs) = regexprep(strs(idxs), [modelname, '[/:]'], '', 'once');
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

% Convert back to char array.
if flag
  strs = strs{1};
end
