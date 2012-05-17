function [fcn, nOut, args] = pGetEvaluationData(task)
; %#ok Undocumented
%pGetEvaluationData
%
%  [FUN, NOUT, ARGS] = pGetEvaluationData(TASK)

%  Copyright 2006-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.5 $    $Date: 2008/09/13 06:51:38 $

% Reset the last warning before getting the data below because we are
% going to test the warning state afterwards. If it is TooMuchData we
% know we failed to get the required data from the jobmanager
lastwarn('');

try
    proxyTask = task.ProxyObject;
    info = proxyTask.getWorkUnitInfo(task.UUID);

    fcnData = info(1).getMLFunction.getData;
    if ~isempty(fcnData) && fcnData.limit > 0
        fcn = distcompdeserialize(fcnData);
    else
        fcn = [];
    end
    info(1).getMLFunction.delete();

    nOut = info(1).getNumOutArgs;
    
    inputData = info(1).getInputData.getData;
    if ~isempty(inputData) && inputData.limit > 0
        args = distcompdeserialize(inputData);
    else
        args = cell(1, 0);
    end
    info(1).getInputData.delete();
catch err
    distcomp.handleGetLargeDataError(task, err);
end
