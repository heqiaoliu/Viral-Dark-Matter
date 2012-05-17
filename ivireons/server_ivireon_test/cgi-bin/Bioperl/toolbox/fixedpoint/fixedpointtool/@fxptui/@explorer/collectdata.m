function signals = collectdata(h)
%COLLECTDATA

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/01/29 17:11:08 $

bd = h.getRoot.daobject;
ModelDataLogName = bd.SignalLoggingName;
[ds, run] = h.getdataset;
%ModelDataLogs
try
  ModelDataLog = evalin('base', ModelDataLogName);
  jModelDataLog = java(ModelDataLog);
  ModelDataLogHashCode = jModelDataLog.hashCode;
  if(ModelDataLogHashCode ~= h.getRoot.ModelDataLogHashCode && ...
      isa(ModelDataLog, 'Simulink.ModelDataLogs') && ...
      isequal(bd.Name, ModelDataLog.BlockPath))
    ds.adddata(run, fxptds.tsdata(ModelDataLog));
    h.getRoot.ModelDataLogHashCode = ModelDataLogHashCode;
  end
catch fpt_exception %#ok<NASGU>
  %we expect errors when variables don't exist, so consume them.
  h.getRoot.ModelDataLogHashCode = 0;
end
%Outports
try
  signals = h.getRoot.gettowsoutputs;
  if(~isempty(signals))
    ds.adddata(run, fxptds.tsdata(signals));
  end
catch fpt_exception %#ok<NASGU>
  %we expect errors when variables don't exist, so consume them
end
%Scopes
try
  signals = h.getRoot.gettowsscopes;
  if(~isempty(signals))
    ds.adddata(run, fxptds.tsdata(signals));
  end
catch fpt_exception %#ok<NASGU>
  %we expect errors when variables don't exist, so consume them
end
%ToWSBlocks
try
  signals = h.getRoot.gettowsblocks;
  if(~isempty(signals))
    ds.adddata(run, fxptds.tsdata(signals));
  end
catch fpt_exception %#ok<NASGU>
end
try
    SimulinkFixedPoint.Autoscaler.collectPostSimData(bd.getFullName);
catch fpt_exception%#ok<NASGU>
end
ds.cleanuprun(run);
% Update the list view based on the filter selection.
send(h,'UpdateFilterListEvent',handle.EventData(h,'UpdateFilterListEvent'));
h.wake;
bd = h.getRoot;
if(isa(bd, 'fxptui.blkdgmnode'))
  bd.firehierarchychanged;
end

% [EOF]
