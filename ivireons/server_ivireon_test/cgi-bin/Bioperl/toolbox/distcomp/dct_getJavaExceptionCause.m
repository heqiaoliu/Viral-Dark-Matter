function [hasCause, causeExceptionType, causeMessage] = dct_getJavaExceptionCause(message)
; %#ok Undocumented
%dct_getJavaExceptionCause function to get java exception cause
%
% [hasCause, exceptionType, message] = dct_getJavaExceptionCause
%
% OK is true if the exception has a cause , exceptionType holds the class
% name of the exception type. message returns the remaining error message

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2008/06/24 17:00:20 $

causeExceptionType = '';
causeMessage = '';


% Match to start of line, non greedy 1 or more chars followed by Caused By:
causeSearchString = '^.+?(Caused by:)';
nestedSearchString = '^.+?(nested exception is:)';
% Find 'Caused by:' in the exception string - but only if it isn;t the
% first element of the string
causeExtent = regexp(message, causeSearchString, 'tokenExtents', 'once');
hasCause = ~isempty(causeExtent);
% We have to treat cause statements and nested exceptions
% differently - use the cause statement first as it contains all
% the relevant information. However, if there is no cause statement
% then we can try checking for a nested exception because we are
% likely to get at least the exception type if not the actual stack
% trace
if hasCause
    % Remove upto the causeString from the message
    causeMessage = message(causeExtent(1):end);
    % Try and find the class of the cause clause
    msg = message(causeExtent(2)+1:end);
    % Find the first alphabetic chars that end in a ':'
    match = regexp(msg, '[a-zA-Z].+?(:|\n)', 'once', 'match');
    if ~isempty(match) 
        % Remove the colon
        causeExceptionType = match(1:end-1);
    end
end
% Did we find a causeExceptionType?
if isempty(causeExceptionType)
    % See if we have a nested exception
    nestedExtent = regexp(message, nestedSearchString, 'tokenExtents', 'once');
    hasNested = ~isempty(nestedExtent);
    if hasNested
        % Best guess at a stack trace is to return the message after the
        % nesting string
        causeMessage = message(nestedExtent(2)+1:end);
        % Try and find the class of the nested clause
        msg = causeMessage;
        % Find the first alphabetic chars that end in a ':'
        match = regexp(msg, '[a-zA-Z].+?(:|\n)', 'once', 'match');
        if ~isempty(match)
            % Remove the colon
            causeExceptionType = match(1:end-1);
        end
    end
    hasCause = hasNested;
end
% Finally - deblank the causeExceptionType as windows seems to sometimes
% include CR at the end of the string
causeExceptionType = deblank(causeExceptionType);
