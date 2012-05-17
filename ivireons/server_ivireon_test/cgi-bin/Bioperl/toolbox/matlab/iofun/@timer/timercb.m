function timercb(obj,type,val,event)
%TIMERCB Wrapper for timer object M-file callback.
%
%   TIMERCB(OBJ,TYPE,VAL,EVENT) calls the function VAL with parameters
%   OBJ and EVENT.  This function is not intended to be called by the 
%   user.
%
%   See also TIMER
%

%    Copyright 2001-2008 The MathWorks, Inc.
%    $Revision: 1.2.4.7 $  $Date: 2008/10/02 19:01:57 $

if ~isvalid(obj)
    return;
end
try  
    if isa(val,'char') % strings are evaled in base workspace.
        evalin('base',val);
    else % non-strings are fevaled with calling object and event struct as parameters
    % Construct the event structure.  The callback is expected to be of cb(obj,event,...) format
        eventStruct = struct(event);
        eventStruct.Data = struct(eventStruct.Data);
    
	% make sure val is a cell / only not a cell if user specified a function handle as callback.
        if isa(val, 'function_handle')
            val = {val};
        end	
     % Execute callback function.
        if iscell(val)
    		feval(val{1}, obj, eventStruct, val{2:end});
        else
            error('MATLAB:timer:IncorrectCallbackInput', ...
                'The third argument to the timer callback must be a character array, a function handle, or a cell array.'); 
        end
    end        
catch exception
    if ~ strcmp(type,'ErrorFcn') && isJavaTimer(obj.jobject)
        try %#ok<TRYNC>
           obj.jobject.callErrorFcn(exception.message,exception.identifier);
        end
    end
    %Error message is coming from Callback specified by the user.  We
    %will provide the stack information in this case. 
    lerrInfo.message = sprintf('??? Error while evaluating %s for timer ''%s'' \n\n%s\n',...
            type,get(obj,'Name'),exception.message);
    lerrInfo.identifier = 'MATLAB:timer:badcallback';
    nStack = length(exception.stack)-length(dbstack);
    lerrInfo.stack = exception.stack(1:nStack);
    lasterror(lerrInfo); %#ok<LERR>
    disp(lasterr); %#ok<LERR>
end
