function h = simdblBall(ZcAlgorithm)

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/02/25 08:31:07 $

sllasterror('');
sllastwarning('');

h=[];

handles = get_param([bdroot,'/Animation'],'UserData');

% Turn off warning to keep it from command window.
warning off Simulink:Engine:SolverIgnoredZCBracketing

% Set zero-crossing algorithm for model
set_param(handles.model, 'ZeroCrossAlgorithm', ZcAlgorithm)

try
    % Display the currently running algorithm
    set(handles.status,'String',['Running ',ZcAlgorithm,' Algorithm...']);

    % Simulate the model
    sim(handles.model);

    % If simulation has run to completion (i.e. the Stop button has not
    % been pushed, display Simulation Complete.
    if ~strcmpi(get(handles.status,'String'),'Simulation Stopped.')
        set(handles.status,'String',sprintf(['Simulation Complete.\n(Default algorithm is ' get_param(handles.model, 'ZeroCrossAlgorithm') '.)']));
    end

    % If warning is related to the zero-crossing display it.
    warnmsg = sllastwarning;
    if ~isempty(warnmsg) && strcmpi(warnmsg.MessageID,'Simulink:Engine:SolverIgnoredZCBracketing')
        h = warndlg(warnmsg.Message,warnmsg.MessageID);
    end

    % Turn zero-crossing warning back on
    warning on Simulink:Engine:SolverIgnoredZCBracketing

catch errorMsg
    % Turn on 'Simulation Error' message in animation window
    set(handles.error,'Visible','on');
    h = errordlg(errorMsg.message, errorMsg.identifier);
    % Turn zero-crossing warning back on
    warning on Simulink:Engine:SolverIgnoredZCBracketing
end
