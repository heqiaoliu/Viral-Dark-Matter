function disp(hMessageLog)
%DISP Display message log.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:37 $

% Handle vector of logs
for i=1:numel(hMessageLog)
    localDisp(hMessageLog(i));
end

%%
function localDisp(hMessageLog)

% Display immediate children only
% Get count of immediate child messages (no linked-log messages)
anyLinked = ~isempty(hMessageLog.LinkedLogs);
if anyLinked
    ll=', not including linked logs';
else
    ll='';
end
c=countAll(hMessageLog,false); % this log only
if c==1
    msgCnt = sprintf('1 message%s',ll);
else
    msgCnt = sprintf('%d messages%s',c,ll);
end
fprintf('MessageLog object "%s" (%s)\n', hMessageLog.titleStr,msgCnt);
iterator.visitImmediateChildren(hMessageLog,@disp);
fprintf('\n');

% [EOF]
