function [obsIndices,numIndices,maxIndex,newNames] = getobsindices(a,obsIndices,allowNew)
%GETOBSINDICES Process string, logical, or numeric dataset array observation indices.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:07 $

if nargin < 3, allowNew = false; end
newNames = {};

% Translate observation (row) names into indices
if ischar(obsIndices)
    if strcmp(obsIndices, ':') % already checked ischar
        % leave them alone
        numIndices = a.nobs;
        maxIndex = a.nobs;
    elseif size(obsIndices,1) == 1
        obsName = obsIndices;
        obsIndices = find(strcmp(obsName,a.obsnames));
        if isempty(obsIndices)
            if allowNew
                obsIndices = a.nobs+1;
                newNames = {obsName};
            else
                error('stats:dataset:getobsindices:UnrecognizedObsName', ...
                      'Unrecognized observation name ''%s''.',obsName);
            end
        end
        numIndices = 1;
        maxIndex = obsIndices;
    else
        error('stats:dataset:getobsindices:InvalidObsName', ...
              'An observation name subscript must be a string or a cell array of strings.');
    end
elseif iscellstr(obsIndices)
    obsNames = obsIndices;
    obsIndices = zeros(1,numel(obsIndices));
    maxIndex = a.nobs;
    for i = 1:numel(obsIndices)
        obsIndex = find(strcmp(obsNames{i},a.obsnames));
        if isempty(obsIndex)
            if allowNew
                maxIndex = maxIndex+1;
                obsIndex = maxIndex;
                newNames{obsIndex-a.nobs,1} = obsNames{i};
            else
                error('stats:dataset:getobsindices:UnrecognizedObsName', ...
                      'Unrecognized observation name ''%s''.',obsNames{i});
            end
        end
        obsIndices(i) = obsIndex;
    end
    numIndices = numel(obsIndices);
    maxIndex = max(obsIndices);
elseif isnumeric(obsIndices) || islogical(obsIndices)
    % leave the indices themselves alone
    if isnumeric(obsIndices)
        numIndices = numel(obsIndices);
        maxIndex = max(obsIndices);
    else
        numIndices = sum(obsIndices);
        maxIndex = find(obsIndices,1,'last');
    end
    if maxIndex > a.nobs
        if allowNew
            if ~isempty(a.obsnames)
                % If the target dataset has obsnames, create default names for
                % the new observations, but make sure they don't conflict with
                % existing names.
                newNames = strcat({'Obs'},num2str(((a.nobs+1):maxIndex)','%d'));
                obsnames = genuniquenames([a.obsnames; newNames],a.nobs+1);
                newNames = obsnames(a.nobs+1:end);
            end
        else
            error('stats:dataset:getobsindices:ObsIndexOutOfRange', ...
                  'Observation index exceeds dataset dimensions.');
        end
    end
else
    error('stats:dataset:getobsindices:InvalidObsSubscript', ...
          'Dataset subscript indices must be real positive integers, logicals, strings, or cell arrays of strings.');
end
obsIndices = obsIndices(:);
