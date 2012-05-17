function setSchedulerMessageHandler(handlerFcn)
; %#ok Undocumented
%SETSCHEDULERMESSAGEHANDLER set the default message handler on an engine
%
%  SETSCHEDULERMESSAGEHANDLER(HANDLER_FCN)
%
% Where HANDLER_FCN is a function handle to a function which takes a string
% input and logs the message for the particular scheduler. To deliver a
% message to the scheduler you should call dctSchedulerMessage

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:33:29 $ 



if nargin == 1 && (isa(handlerFcn, 'function_handle') || isempty(handlerFcn))
    % Set the actual message handler in the private function
    dctSchedulerMessageHandler(handlerFcn);
else
    error('distcomp:abstractscheduler:InvalidArgument', ...
        'The input to setSchedulerMessageHandler must be a function handle'); 
end

