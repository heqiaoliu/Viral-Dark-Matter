function dctProfStripAnchors
% DCTPROFSTRIPANCHORS Removes anchors that evaluate MATLAB code from 
% Parallel Profiler HTML.
% It displays stripped-down HTML from the Profiler in a new
% HTML window, thereby allowing users to compare two profiling runs
% without causing problems with stale file information. No temporary images
% are currently copied.
%   See also STRIPANCHORS, MPIPROFILE, MPIPROFVIEW.

%   Copyright 2007 The MathWorks, Inc.

%   $Revision: 1.1.6.1 $  $Date: 2007/10/10 20:43:47 $
%   2007 smarvasti based on stripanchors.m

if ~iIsOnClient()
    if labindex==1
        iRunCmdOnClient('dctProfStripAnchors');
        return;
    else % dont do anything on other labs
        return;
    end
end
str = char(com.mathworks.mde.profiler.Profiler.getHtmlTextParallel);

% The question mark makes the .* wildcard non-greedy
str = regexprep(str,'<a.*?>','');
str = regexprep(str,'</a>','');
str = regexprep(str,'<form.*?</form>','');
str = regexprep(str,'<form.*?</form>','');
str = regexprep(str,'<table name="topMenuTable".*?</table>','');

str = strrep(str,'<body>','<body bgcolor="#F8F8F8"><strong>Links are disabled because this is a static copy of a profile report</strong><p>');

web('-new', '-noaddressbox', ['text://' str]);


%--------------------------------------------------------------------------
% IRunCmdOnClient allows the dctstripanchors command to be called in pmode
%--------------------------------------------------------------------------
function iRunCmdOnClient(cmd)
%iRunCmdOnClient Send a command back to the client for asynchronous evaluation.
session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
if isempty(session)
    error('distcomp:mpiprofile:pmodeNotRunning', ...
        'Cannot execute %s from pmode as the session isempty!', cmd);
end
% Error messages will only be displayed in the main MATLAB command window, and
% the command will only be executed in the MATLAB client when it is idle.
c = session.getClient;
c.evalConsoleOutput(cmd);


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function onclient = iIsOnClient()
onclient = ~system_dependent('isdmlworker');

