function instrcb(val,obj,event)
%INSTRCB Wrapper for serial object M-file callback.
%
%  INSTRCB(FCN,OBJ,EVENT) calls the function FCN with parameters
%  OBJ and EVENT.
%

%   MP 7-13-99
%   Copyright 1999-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 05:02:01 $

% Store the warning state. Note, reset warning to address 
% G309961 which was causing the same last warn to be rethrown.
lastwarn('');
s = warning('backtrace', 'off');

switch (nargin)
case 1
    try
        evalin('base', val);
    catch aException
        warning(s);
        rethrow(aException);
    end
case 3    
    % Construct the event structure.
    eventStruct = struct(event);
    eventStruct.Data = struct(eventStruct.Data);
 
    if isa(val, 'function_handle')
        val = {val};
    end
    
    % Execute callback function.
    try
        feval(val{1}, obj, eventStruct, val{2:end});
    catch aException
        warning(s);
        rethrow(aException);
    end
end

% Restore the warning state.
warning(s)
  
% Report the last warning if it occurred.
if ~isempty(lastwarn)
   warning('MATLAB:instrcb:invalidcallback', lastwarn);
end

