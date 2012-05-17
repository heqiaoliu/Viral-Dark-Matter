function solvers = getSolversByParameter(varargin)
% Get the list of solvers by parameter-value pairs from sl('getSolverInfo')
%
% Usage:
%   solvers = getSolversByParameter('States', 'Continuous', 'SolverType',
%   'Variable Step')
%   solvers = 
% 
%         'ode113'
%         'ode15s'
%         'ode23'
%         'ode23s'
%         'ode23t'
%         'ode23tb'
%         'ode45'
%
%   solvers = getSolversByParameter('States', 'Discrete')
%   solvers = 
% 
%           'FixedStepDiscrete'
%           'VariableStepDiscrete'
%
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

if mod(nargin,2)
    error('Please use pairs of param_name, param_value as input')
end

solvers = sl('getSolverInfo');

for i=1:2:length(varargin)
    solvers = process(solvers, varargin{i}, varargin{i+1});
end

% Get from the solvers list the ones which have the value for the given
% parameter name
function solvers = process(solvers, param_name, param_value)
if strcmp(param_name, 'States')    
    if strcmp(param_value, 'Discrete') || strcmp(param_value, 'Continuous')
        arr = 1:length(solvers);
        idx = strfindidx(solvers,'Discrete');
        if strcmp(param_value, 'Discrete')
            solvers = solvers(idx);
            return;
        else
            arrxor = setxor(idx, arr);
            solvers = solvers(arrxor);
            return;
        end
    else
        solvers = {};
    end
else
    idx = [];
    j = 1;
    for i=1:length(solvers)
        slvrs_struct = sl('getSolverInfo', solvers{i});
        if ~isempty(strmatch(param_name, fieldnames(slvrs_struct)))
            if strfind(slvrs_struct.(param_name).Value, param_value)
                idx(j) = i;
                j = j+1;
            end            
        end
    end
    solvers = solvers(idx);
end


% Get the row indices from a cell array of strings
% which rows contain value
function idx = strfindidx(cell, value)
ret = strfind(cell,'Discrete');
idx = [];
j = 1;
for i=1:length(ret)
    if ~isempty(ret{i})
        idx(j) = i;
        j = j+1;
    end
end