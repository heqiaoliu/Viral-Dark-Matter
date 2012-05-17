function varargout = loadSource(this, hScopeCLI, newSourceFcn)
%LOADSOURCE Load source from command-line serialization data.
%   sourceArgs comes from a call to source() method, or from
%   the actual command-line args, in a cell-vector.
%
%   errStatus is a struct returned by NewSourceEvent.
%
%   We offer a convenient BLOCKING call here, despite having
%   to synchronize with "stop".

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/11/18 02:14:50 $

% Return early if the parser did not recognize the inputs.
parseCmdLineArgs(this, hScopeCLI);

if nargin > 2
    this.Listeners.NewSource.Callback = @(h, ev) onNewSource(this, ev, newSourceFcn);
    this.Listeners.NewSource.Enabled  = 'on';
end

if isempty(hScopeCLI.Name)
    if isempty(hScopeCLI.Args) || isempty(hScopeCLI.Args{1})
        errMsg = '';
    else
        errMsg = 'Source could not be identified.';
    end
    send(this, 'NewSourceEvent', uiservices.EventData(this, 'NewSource', ...
            struct('ErrorStatus', 'failure', 'ErrorMsg', errMsg)));
    if nargout
        varargout = {false, errMsg};
    end
    return;
end

% Return early if the source extension is enabled.
hNewSource = this.getExtInst('Sources', hScopeCLI.Name);
if isempty(hNewSource)
    errMsg = sprintf('The %s source is not enabled.', hScopeCLI.Name);
    send(this, 'NewSourceEvent', uiservices.EventData(this, 'NewSource', ...
            struct('ErrorStatus', 'failure', 'ErrorMsg', errMsg)));
    if nargout
        varargout = {false, errMsg};
    end
    return;
end

hNewSource.ScopeCLI = hScopeCLI;
if nargin > 2
    
    newSource(this, hNewSource, true);
    
else
    % Execute the NewSource function
    % NOTE: 1st arg (doStop=false) indicates no need to stop timer
    %       it also implies we can get LHS return arg for error status
    [varargout{1:nargout}] = newSource(this, hNewSource, false);
end

% -------------------------------------------------------------------------
function onNewSource(this, ev, newSourceFcn)

this.Listeners.NewSource.Enabled = 'off';

newSourceFcn(this, ev);

% [EOF]
