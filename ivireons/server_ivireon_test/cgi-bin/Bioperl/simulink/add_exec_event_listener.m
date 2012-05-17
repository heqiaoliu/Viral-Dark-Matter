function varargout = add_exec_event_listener(varargin)
%ADD_EXEC_EVENT_LISTENER Adds execution event listener to block
%   listeners = ADD_EXEC_EVENT_LISTENER(block, eventType, listenerCB)
%   adds an execution listener of type 'eventType' to 'block'
%   which is specified either as a fullpath name or a block
%   handle. The callback that needs to run when the event fires is 
%   specified in 'listenerCB'. Note that the output must be assigned 
%   to a variable that persists for the duration that the listener 
%   is active.
%
%   listeners = ADD_EXEC_EVENT_LISTENER(rto, eventType, listenerCB)
%   adds an execution event listener to each Simulink.RunTimeBlock
%   object that is specified in the array 'rto'.
%
%   The supported event types and the trigger that causes them
%   to fire are as follows:
%   ----------------------------------------------------------
%   Event Type       Event trigger
%   ----------------------------------------------------------
%   PreOutputs        Before block's Outputs method executes
%   PostOutputs       After block's Outputs method executes
%   PreUpdate         Before block's Update method executes
%   PostUpdate        After block's Update method executes
%   PreDerivatives    Before block's Derivatives method executes
%   PostDerivatives   After block's Derivatives method executes
%   ----------------------------------------------------------
%
%   To remove listeners added using this function, simply clear
%   the return variable.
%
%   Examples:
%       
%    h = add_exec_event_listener('vdp/Mu', 'PostOutputs', 'disp(''Outputs''')')
%
%   adds a listener which displays 'Outputs' on the command line 
%   every time the Outputs method of block 'vdp/Mu' finishes executing. 
%
%    r = get_param('vdp/Mu', 'RuntimeObject');
%    h = add_exec_event_listener(r, 'PostOutputs', 'disp(''Outputs''')')
%  
%   has the same effect as the previous example.
%
%    h = add_exec_event_listener('vdp/Mu', 'PostOutputs', @eventCB)
%  
%   adds a listener which calls the function 'eventCB' every time 
%   the Outputs method of block 'vdp/Mu' finishes executing. The 
%   function is called with two arguments: the Simulink.RunTimeBlock
%   corresponding to 'vdp/Mu' and an EventData object which contains
%   the name of the event and a handle to the Simulink.RunTimeBlock.
%
%     function eventCB(r, eventData)
%       disp(eventData.Type);
%     %endfunction
%
%    clear h
%
%   removes listeners added as shown in the previous examples.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $

%
% Requisite nargin and nargout checking
%
listenerUseTid = false;
if nargin == 4
  listenerUseTid = true;
  listenerTids = varargin{4};
elseif nargin ~= 3
  DAStudio.error('Simulink:tools:AddExecEventListenerInvalidInputArgs');
end

block = varargin{1};
eventType = varargin{2};
listenerCallback = varargin{3};

if nargout == 0
    DAStudio.error('Simulink:tools:AddExecEventListenerRequireOneOutputArg');
end

if isa(block,'Simulink.RunTimeBlock')
  rtih = block;
else
  rtih = get_param(block, 'RuntimeObject');
end

if listenerUseTid
    for k=1:length(rtih)
        rtih(k).EventListenerTIDs = listenerTids;
    end
end

if isempty(rtih)
    DAStudio.error('Simulink:tools:AddExecEventListenerOnlyDuringExecuting');
end

rtih = handle(rtih);

ret_handle = [];

for k = 1:length(rtih)
  hl = handle.listener(rtih(k), eventType, listenerCallback);

  ret_handle = [ret_handle hl];
end

varargout{1} = ret_handle;

%% [EOF] add_execevent_listener.m
