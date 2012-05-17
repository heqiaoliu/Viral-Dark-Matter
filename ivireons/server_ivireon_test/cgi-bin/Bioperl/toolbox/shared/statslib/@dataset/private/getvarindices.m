function [varIndices,newNames] = getvarindices(a,varIndices,allowNew)
%GETVARINDICES Process string, logical, or numeric dataset array variable indices.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/07/06 20:47:36 $

if nargin < 3, allowNew = false; end
newNames = {};

% Translate variable (column) names into indices
if ischar(varIndices)
    if strcmp(varIndices, ':') % already checked ischar
        % have to translate these, since dataset column indexing is not done
        % by the built-in indexing code
        varIndices = 1:a.nvars;
    elseif size(varIndices,1) == 1
        varName = varIndices;
        varIndices = find(strcmp(varName,a.varnames));
        if isempty(varIndices)
            if allowNew
                checkreservednames(varName);
                varIndices = a.nvars+1;
                newNames = {varName};
            else
                error('stats:dataset:getvarindices:UnrecognizedVarName', ...
                      'Unrecognized variable name ''%s''.',varName);
            end
        end
    else
        error('stats:dataset:getvarindices:InvalidVarName', ...
              'A variable name subscript must be a string or a cell array of strings.');
    end
elseif iscellstr(varIndices)
    varNames = varIndices;
    varIndices = zeros(1,numel(varIndices));
    maxIndex = a.nvars;
    for j = 1:numel(varIndices)
        varIndex = find(strcmp(varNames{j},a.varnames));
        if isempty(varIndex)
            if allowNew
                checkreservednames(varNames{j});
                maxIndex = maxIndex+1;
                varIndex = maxIndex;
                newNames{1,varIndex-a.nvars} = varNames{j};
            else
                error('stats:dataset:getvarindices:UnrecognizedVarName', ...
                      'Unrecognized variable name ''%s''.',varNames{j});
            end
        end
        varIndices(j) = varIndex;
    end
elseif isnumeric(varIndices) || islogical(varIndices)
    if islogical(varIndices)
        % have to translate these, since dataset column indexing is not done by
        % the built-in indexing code
        varIndices = find(varIndices);
        if isempty(varIndices)
            maxIndex = [];
        else
            maxIndex = varIndices(end);
        end
    else
        maxIndex = max(varIndices);
    end
    if maxIndex > a.nvars
        if allowNew
            if any(diff(unique([1:a.nvars varIndices(:)'])) > 1)
                error('stats:dataset:getvarindices:DiscontiguousVars', ...
                      'Cannot create dataset variable with discontiguous index.');
            end
            % create default names for the new vars, but make sure they don't
            % conflict with existing names.
            newNames = strcat({'Var'},num2str(((a.nvars+1):maxIndex)','%d'))';
            varnames = genuniquenames([a.varnames newNames],a.nvars+1);
            newNames = varnames(a.nvars+1:end);
        else
            error('stats:dataset:getvarindices:VarIndexOutOfRange', ...
                  'Variable index exceeds dataset dimensions.');
        end
    end
    % already have col numbers, leave them alone
else
    error('stats:dataset:getvarindices:InvalidVarSubscript', ...
          'Dataset subscript indices must be real positive integers, logicals, strings, or cell arrays of strings.');
end
varIndices = varIndices(:)';
