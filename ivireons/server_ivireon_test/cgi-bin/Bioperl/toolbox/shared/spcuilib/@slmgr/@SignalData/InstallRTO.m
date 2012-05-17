function InstallRTO(this, hDataSink)
%INSTALLRTO Install RTO by setting up and caching listeners.
% Note: it is required to call CacheAttribsAndRTO before this.
%       Use AttachToModel method.
%
% Considers both single- and multi-signal (-component)
% signals access.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/20 03:08:15 $

% Note:
%   - RTO's work by defining a listener callback; timing of call
%     is from Simulink engine
%   - RTO listeners stop working when a model is stopped; that's done
%     automatically by Simulink.  The RTO "goes away."  Any listeners
%     still connected go "dead."  The listeners is removed upon
%     model stop, since they're useless.
%   - to regain the connection, use model start event to reconstruct
%     new RTO's and new listeners (each time at model start)

% Choose data-access callback function
% depending on source Simulink data type
%
% If data matches a predefined type, we can access
% the data in "raw" form, and don't need to impose
% a conversion to doubles.
%
% Otherwise, a conversion to double must be done
% and that costs memory and performance:

% Certain "native" data types can be accessed in their raw format
% Others, particularly general fixed-point, are accessed as doubles
if any(strcmpi(this.dtype, slmgr.getNativeTypes))
    dataFcn = @get_simulink_data_cb;
else
    dataFcn = @get_simulink_dataasdouble_cb;
end

% What we need from this:
%    numComponents (scalar #)
%    dtype (string)
%    dims (vector dims)
%    period (scalar real)
%    (rto,portIdx) for each component
%

% Create and retain RTO listener handles
if this.numComponents > 1
    this.rtoListeners = setupMultiComponentCallback(this, dataFcn);
else
    this.rtoListeners = setupSingleComponentCallback(this, dataFcn);
end

this.TargetObject = hDataSink;

% -------------------------------------------------------------------------
function hListen = setupMultiComponentCallback(this, dataFcn)
% Create run-time object callback

% Setup DCS:DemandUpdate* callback arguments,
% and copy into RTO listener callbacks
%
for i = 1:length(this.portIdx)    
    % Set callback parameters
    callback_fcn = makeMultidataHandler(this, i, dataFcn);
    
    % Install listener on run-time object
    %
    hRTO = handle(this.rto(i));
    
    % Handles the possible multi-rate block. Get the correct sampling time for
    % selected port.
    stIdx = hRTO.OutputPort(this.portIdx(i)).SampleTimeIndex;
    hRTO.EventListenerTIDs = double(stIdx);

    hListen(i) = handle.listener(hRTO,'PostOutputs',callback_fcn); %#ok
    hListen(i).Enabled='off'; %#ok
end

% -------------------------------------------------------------------------
function hListen = setupSingleComponentCallback(this, dataFcn)
% Create callback
%
% 4 entries to fill in

% Define on-demand/single-shot display update function
callback_fcn = makeSingledataHandler(this, dataFcn);

% Certain "native" data types can be accessed in their raw format
% Others, particularly general fixed-point, are access as doubles

% Install listener on run-time object
% Don't enable it until callback target is installed
% xxx bug: cannot turn off Enabled during construction
hRTO = handle(this.rto);

% Handles the possible multi-rate block. Get the correct sampling time for
% selected port.
stIdx = hRTO.OutputPort(this.portIdx).SampleTimeIndex;
hRTO.EventListenerTIDs = double(stIdx);

hListen = handle.listener(hRTO,'PostOutputs',callback_fcn);
hListen.Enabled='off';

% -------------------------------------------------------------------------
function y = get_simulink_data_cb(rto,portIdx)
% Calling sequence
%     block execution callback fires in Simulink
%     which calls MPlay:demand_callback
%         - automatic callback, supplies (hco,eventStruct,hfig)
%     which calls DataConnectSimulink:get_simulink_data_cb
%         - manual callback, supplies (rto,portIdx)

hPort = rto.OutputPort(portIdx);
y = hPort.Data;  % frame of raw data

% -------------------------------------------------------------------------
function y = get_simulink_dataasdouble_cb(rto,portIdx)
% Calling sequence
%     block execution callback fires in Simulink
%     which calls MPlay:demand_callback
%         - automatic callback, supplies (hco,eventStruct,hfig)
%     which calls DataConnectSimulink:get_simulink_data_cb
%         - manual callback, supplies (rto,portIdx)

hPort = rto.OutputPort(portIdx);
y = hPort.DataAsDouble;  % frame of data converted to doubles

% -------------------------------------------------------------------------
function cb = makeSingledataHandler(this, dataFcn)

cb = @(h, ev) singledataHandler(this, dataFcn, this.rto, this.portIdx);

% -------------------------------------------------------------------------
function cb = makeMultidataHandler(this, i, dataFcn)

cb = @(h, ev) multidataHandler(this, this.numComponent, ...
        i, dataFcn, this.rto(i), this.portIdx(i));

% [EOF]
