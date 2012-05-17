function addSignal(this, varargin)
%ADDSIGNAL Add a signal to the database.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/03/31 18:43:23 $

[signal, okToOpenModel, blkname] = parseInputs(varargin{:});

this.Selectedblk = blkname;

for indx = 1:length(signal)
    
    % Check that each new signal is not already contained by the database.
    if ~isempty(signal{indx}) && isempty(findSignal(this, signal{indx}))
        
        % Convert each item to an slmgr.SignalSelect object.
        if ~isa(signal, 'slmgr.SignalSelect')
            signal{indx} = slmgr.SignalSelect(signal{indx}, okToOpenModel);
        end
        
        % Verify that the new signals are attached to the same BD Root.
        if isempty(this.Signals) || bdroot(signal{indx}) == bdroot(this.Signals(1))
            connect(signal{indx}, this, 'up');
        else
            warning('spcuilib:slmgr:SignalSelectMgr:rootMismatch', ...
                'Cannot add signals with heterogeneous roots.');
            signal{indx} = [];
        end
    elseif ~isempty(signal{indx})
        warning('spcuilib:slmgr:SignalSelectMgr:redundantSignal', ...
            'Signal already contained in database.');
        signal{indx} = [];
    end
end

% If we have successfully added signals, send an event.
signal = [signal{:}];
if ~isempty(signal)
    send(this, 'SignalAdded', spcuddutils.EventData(this, 'SignalAdded', signal));
end

% -------------------------------------------------------------------------
function [signal, okToOpenModel, blkname] = parseInputs(varargin)

okToOpenModel = true;
blkname = '';

% Get the signal from GSL if we have not been passed one.
signal = varargin;
if ~isempty(signal) && islogical(signal{end})
    okToOpenModel = signal{end};
    signal(end)   = [];
end

if isempty(signal)
    signal = gsl(slmgr.getCurrentSystem, 1);
    if isempty(signal)
        signal = gsb(slmgr.getCurrentSystem, 1);
    end
else
    if length(signal) == 1 && ~iscell(signal{1}) && length(signal{1}) > 1
        signal = signal{1};
    end
end

if ~iscell(signal)
    signal = {signal};
end

if ~isempty(signal) && ischar(signal{1})
    blkname = signal{1};
end

indx = 1;
while indx <= length(signal)
    signalI = signal{indx};
    
    if iscell(signalI) && numel(signalI) == 1
        signalI = signalI{1};
    end
    
    if isempty(signalI)
        signal(indx) = [];
    elseif ischar(signalI) && ...
            confirmIsBlock(signalI, okToOpenModel)
        
        % If we are passed a block name, create a signal for each of
        % its output ports. Convert each block passed to {block, port}
        block = signalI;
        
        nports = length(get_param(block, 'OutputSignalNames'));
        newSignal = cell(1, nports);
        for jndx = 1:nports
            newSignal{jndx} = {block, jndx};
        end
        signal = [signal(1:indx-1) newSignal signal(indx+1:end)];
        indx = indx+length(newSignal);
    elseif iscell(signalI)
        if isempty(signalI{1})
            
            % Sometimes this gets called with {{[]}} instead of {[]}.  We
            % need to simply remove these inputs.  They do not point to any
            % selected signal.
            signal(indx) = [];
        elseif numel(signalI) > 1 && ...
                numel(signalI{2}) > 1
            
            for jndx = 1:size(signalI, 1)
                % Support {'BlockName', [1 2 3]} format.
                nports = numel(signalI{jndx, 2});
                newSignal = cell(1, nports);
                for kndx = 1:nports
                    newSignal{kndx} = {signalI{jndx, 1}, signalI{jndx, 2}(kndx)};
                end
                signal = [signal(1:indx-1) newSignal signal(indx+1:end)];
                indx = indx+numel(newSignal);
            end
        else
            indx = indx+1;
        end
    elseif isnumeric(signalI) && length(signalI) > 1
        nports = numel(signalI);
        newSignal = cell(1, nports);
        for jndx = 1:nports
            newSignal{jndx} = signalI(jndx);
        end
        signal = [signal(1:indx-1) newSignal signal(indx+1:end)];
    else
        indx = indx+1;
    end
end

% -------------------------------------------------------------------------
function b = confirmIsBlock(fullblk,okToOpenModel)
% Confirm that the specified path string
% describes a valid Simulink block, not a
% block diagram, etc

openSimulinkModel(fullblk,okToOpenModel);
try
    sltype = get_param(fullblk,'type');
    b = strcmp(sltype,'block');
catch e %#ok
    % Might not have been a valid SL path at all
    b = false;
end

% -------------------------------------------------------------------------
function openSimulinkModel(slPath,okToOpenModel)
%OPENMODEL Open model if not currently open
%   OPENMODEL(SLPATH) checks to see if the Simulink model
%   specified as part of SLPATH is open.  If not, an attempt
%   to open the model is made.  ISOPEN is returned as false
%   if the model could not be opened.  MODELNAME is optionally
%   returned with the name of the Simulink model.
%
%   OPENMODEL(SLPATH,OPENMODEL) will not attempt to open a model that
%   is not loaded, if OPENMODEL=false.  By default, OPENMODEL=true;

% Does SLPATH contain a valid Simulink model name?
modelName = getModelName(slPath);
if isempty(modelName)
    error(generatemsgid('NoModelSpecified'), 'No Simulink model name specified.');
end
% See if the model is open
allOpenModelNames = find_system('searchdepth',0);
isOpen = any(strcmpi(allOpenModelNames,modelName));
if ~isOpen
    modelExists = exist(modelName, 'file') == 4;
    if ~modelExists
        error(generatemsgid('ModelNotFound'), 'Failed to find Simulink model "%s".', modelName);
    end
    
    if okToOpenModel
        open_system(modelName);
    else
        error(generatemsgid('ModelNotOpen'), 'Simulink model "%s" not open.',modelName);
    end
end

% -------------------------------------------------------------------------
function modelName = getModelName(slPath)
%GETMODELNAME Return Simulink model name from full Simulink path

modelName = '';
if ~ischar(slPath)
    return
end
idx = find(slPath=='/',1);  % Find first Simulink path separator
if isempty(idx)
    % assume just a model name was passed
    modelName = slPath;
else
    modelName = slPath(1:idx-1);
end

% [EOF]
