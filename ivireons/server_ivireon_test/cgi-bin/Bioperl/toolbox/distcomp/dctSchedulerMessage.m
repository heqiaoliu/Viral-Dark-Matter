function dctSchedulerMessage(levelNum, messageString, varargin)
; %#ok Undocumented
%DCTSCHEDULERMESSAGE sends a message to the scheduler
%
%  DCTSCHEDULERMESSAGE(MESSAGE_STRING)
%

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.7 $    $Date: 2008/06/24 17:00:19 $ 

if nargin < 1
    levelNum = 0;
end

if nargin < 2 || ~iIsValidLogLevel(levelNum) || ~ischar(messageString)
    warning('distcomp:abstractscheduler:InvalidArgument', ...
        'The inputs to dctSchedulerMessage must be an integer value and a string'); 
    messageString = 'WARNING - The inputs to dctSchedulerMessage must be an integer value and a string.';
elseif nargin > 2
    try
        messageString = sprintf(messageString, varargin{:});
    catch err
        % Use unformatted messageString if sprintf fails
        warning('distcomp:abstractscheduler:InvalidArgument', 'Unable to format a scheduler message. Error returned :\n%s', err.message);
    end
end

try 
    dctSchedulerMessageHandler(messageString, levelNum);
catch err %#ok<NASGU>
    % Do Nothing - It's OK
end

end



function valid = iIsValidLogLevel(value)
    % Check that the log level is a 1x1 integer.
    valid = (isnumeric(value) &&  (numel(value) == 1) ...
        && (uint16(value) == value));
end
