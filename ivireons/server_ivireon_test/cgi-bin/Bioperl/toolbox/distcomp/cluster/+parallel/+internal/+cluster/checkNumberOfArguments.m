function checkNumberOfArguments(inOrOutMode, minArgs, maxArgs, actualNumArgs, functionName, giveDetailedInputMessage)

% Function to check if the number of input/output arguments.  Use
% this over the standard nargchk and nargoutchk for distcomp functions that
% take input arguments of the form (@fcn, numArgsOut, argsIn) in order
% to minimise user's confusion about which input/output arguments we are 
% referring to.
%
% If giveDetailedInputMessage is true, the generated error has a nice
% message along the lines of "<functionName> requires between 3 and 5 input arguments, 
% but 2 were supplied".  Use this only for functions and NOT for class methods (since
% the number of input arguments can be confusing for methods depending on whether 
% dot notation was used.
% If giveDetailedInputMessage is false, the more generic mesage of "Not enough
% input arguments for <functionName> were supplied".
% 

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:03:54 $

% Default to giving the less detailed message.
if nargin < 6
    giveDetailedInputMessage = false;
end

%inOrOutMode must be either 'input' or 'output'
allowedStrings = {'input'; 'output'};
assert(any(strcmpi(inOrOutMode, allowedStrings)), ...
    'distcomp:checkNumberOfArguments:InvalidMode', ...
        'inOrOutMode must be one of the following: %s.', ...
        sprintf('%s ', allowedStrings{:}));

if (actualNumArgs >= minArgs) && (actualNumArgs <= maxArgs)
    return;
end
    
if giveDetailedInputMessage
    % Give a nice error message like "...requires 3 arguments, but
    % only 2 were supplied".  Use this only for functions that cannot
    % be called using functional form and dot notation

    % Build up the correct error string based on minArgs, maxArgs and
    % actualNumArgs
    argumentsString = 'arguments';
    if minArgs == maxArgs
        requiredArgMessage = sprintf('exactly %d', minArgs);
        if minArgs == 1
            argumentsString = 'argument';
        end
    else
        requiredArgMessage = sprintf('between %d and %d', minArgs, maxArgs);
    end

    if actualNumArgs == 1
        verb = 'was';
    else
        verb = 'were';
    end

    ex = MException(sprintf('distcomp:%s:IncorrectNumberOfArguments', functionName), ...
        '%s requires %s %s %s, but %d %s supplied.', ...
        functionName, requiredArgMessage, inOrOutMode, argumentsString, actualNumArgs, verb);
else
    if actualNumArgs < minArgs 
        argMessage = 'Not enough';
    else
        argMessage = 'Too many';
    end
    
    ex = MException(sprintf('distcomp:%s:IncorrectNumberOfArguments', functionName), ...
        '%s %s arguments for %s', argMessage, inOrOutMode, functionName);
end

throwAsCaller(ex);

