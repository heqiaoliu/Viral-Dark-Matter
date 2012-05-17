function rtwtrace(block,varargin)
% RTWTRACE Trace generated code for block in model

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.9 $

if ~ischar(block)
    block = getfullname(block);
end
model = strtok(block,':/');
if nargin > 1
    target = varargin{1};
else
    target = 'rtw';
end
switch target
  case 'rtw'
    traceInfo = RTW.TraceInfo.instance(model);
    if ~isa(traceInfo,'RTW.TraceInfo')
        traceInfo = RTW.TraceInfo(model);
    end
    if isempty(traceInfo.BuildDir)
        traceInfo.setBuildDir('');
    end
  case 'hdl'
    traceInfo = hdlshared.TraceInfo.instance(model);
    if ~isa(traceInfo,'hdlshared.TraceInfo')
        traceInfo = hdlshared.TraceInfo(model);
    end

    if isempty(traceInfo.BuildDir)
        traceInfo.setBuildDir('');
    end

    if isempty(traceInfo.getRegistry)
        traceInfo.loadTraceInfo;
    end
end
traceInfo.highlight(block);
