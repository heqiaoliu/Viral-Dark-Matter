function dctSchedulerMessageHandler(input, levelNum)
%DCTSCHEDULERMESSAGEHANDLER 
%
%  DCTSCHEDULERMESSAGE(MESSAGE_STRING)
%

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:37:16 $ 

mlock;
persistent theHandler;
persistent handlerNargIn;

if isempty(input)
    theHandler = [];
elseif ischar(input)
    % Do nothing if no handler has been registered
    if isempty(theHandler)
        return
    end
    % This function should NEVER error
    try
        if handlerNargIn == 1
            theHandler(input);
        elseif handlerNargIn > 1
            theHandler(input, levelNum);
        end
    catch err
        warning(err.identifier, err.message);
    end
elseif isa(input, 'function_handle')
    theHandler = input;
    handlerNargIn = nargin(theHandler);
end
