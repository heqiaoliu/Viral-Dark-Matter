function idx = targets_find_signature(sigs, args)
%TARGETS_FIND_SIGNATURE returns the index of a matching signature based on args
%   TARGETS_FIND_SIGNATURE returns the index of the matching signature in the cell array
%   based on the parameters supplied in the args structure

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:58 $

if isempty(args)
  % Trying to call the empty constructor
  params = {};
else
  % Trying to call a specific constructor with prototype == params
  params = fieldnames(args);
end

% Search the constructors comparing each constructor prototype in sigs with the 
% prototype in params
foundConstructor = false;
for idx=1:length(sigs)
  % Did we find a matching constructor - all elements in params prototype are 
  % in the sigs prototype
  if isempty(setxor(params, sigs{idx}))
    foundConstructor = true;
    break;
  end
end

if ~foundConstructor
  if isempty(params)
    % Trying to call the empty constructor
    error('Targets:ExecuteConstructor', 'No matching constructor');
  else
    % Trying to call some other parameterised constructor
    paramsString = '';
    % Build up a string of the parameters given in args
    for i=1:length(params)
      paramsString = [paramsString params{i} ' ']; %#ok
    end
    error('Targets:ExecuteConstructor', ['No matching constructor for parameters: ' paramsString]);
  end
end
