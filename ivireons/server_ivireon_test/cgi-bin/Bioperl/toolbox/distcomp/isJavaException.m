function [OK, exceptionType, causes] = isJavaException(caughtException)
; %#ok Undocumented
%isJavaException private function to test if a caught exception is from java
%
% [OK, exceptionType] = isJavaException
%
% OK is true if the exception was from java, exceptionType holds the class
% name of the exception type.

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/06/24 17:00:26 $ 

nExpectArgs = 1;
assert(nargin == nExpectArgs, ...
       'function was given %d args instead of %d.', nargin, nExpectArgs);

msg = caughtException.message;
% Define the default output
OK = false;
exceptionType = '';
causes = {};

try
    % String to first colon
    initialString = regexp(msg, '^.+?:', 'match', 'once');
    % Is the text up to the first colon 'Java exception occurred:'?
    OK = strcmp(initialString, 'Java exception occurred:');
    % Have we been asked for the exceptionType output
    if OK && nargout > 1
        % Search for everything after the first ':<whitespace>' that starts with
        % [a-zA-Z] and then contains only valid characters for a fully
        % qualified java class name - i.e. "\w$\." - letters, digits,
        % underscores, "$" and ".". This handles the case where the exception stack
        % doesn't include a colon after the exception class name.
        exceptionType = regexp(msg, '(?<=:\s*)[a-zA-Z][\w$\.]*', 'once', 'match');
    end
    % Have we been asked for causes as well
    if OK && nargout > 2
        % Get everything up to the first 'Caused by:' string
        firstException = regexp(msg, '^.*?(?=Caused by:)', 'once', 'match');
        % Find all the nested exceptions - these are preceded by the string 'nested
        % exception is:<whitespace>' and then valid characters for a fully
        % qualified java class name as previously
        causes = regexp(firstException, '(?<=nested exception is:\s*)[a-zA-Z][\w$\.]*', 'match');
    end
catch unexpectedException %#ok<NASGU>
    % Do nothing because the default output values have been set up.
end
