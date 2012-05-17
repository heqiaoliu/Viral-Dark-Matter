function aHandler = lsfMessageHandler(jobID, taskID, initialMessageNumber)
%lsfMessageHandler 
%
%  lsfMessageHandler(jobID, taskID, initialMessageNumber)
%

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:44:57 $ 

if nargin < 3
    initialMessageNumber = 0;
end

if isempty( taskID )
    % Parallel execution
    initialMessageNumber = labindex-1;
    messageIncrement = numlabs;
    jobString = jobID;
else
    messageIncrement = 1;
    jobString = sprintf('%s[%s]', jobID, taskID);
end
messageNumber = initialMessageNumber;
aHandler = @nMessageHandler;
if ispc
    quote = '"';
else
    quote = '''';
end

    function nMessageHandler(stringToPost)
        % Display the message so that it ends up in the debug log
        disp( stringToPost );
        % Strip characters that would cause problems with the command line - 
        % any quotes or newlines
        stringToPost = regexprep( stringToPost, '[''"\n\r]', '' );
        dctSystem(sprintf('bpost -i %d -d %s%s%s "%s"', messageNumber, quote, stringToPost, quote, jobString));
        messageNumber = messageNumber + messageIncrement;
    end
end