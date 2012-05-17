function dctStoreFunctionArray(action, postFcns)
; %#ok Undocumented

% Copyright 2006-2010 The MathWorks, Inc.

% This function should be called to finish any interactive session
% that has been started by a parallel job that has pIsInteractiveJob
% true. 

% Lock this file as it holds information about wrapping up a parallel
% interactive job that needs to persist across a call to clear functions.
mlock;
persistent thePostFcns;
% Ensure that we initialize the post functions correctly
if isempty(thePostFcns)
    thePostFcns = {};
end


switch lower(action)
    case 'set'
        thePostFcns = postFcns;
    case 'run'
        dctEvaluateFunctionArray(thePostFcns);
        % Clear out the functions correctly
        thePostFcns = {};
    otherwise
        error('distcomp:paralleljob:InvalidArgument', 'Action arguments to dctFinishInteractiveJob are set or finish');
end
