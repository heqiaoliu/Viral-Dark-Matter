%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = clean_error_msg(M)
%
% this function strips extraneous call stack info from error message
% Used by sfblk() function in fsm.c.

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.11.2.5 $  $Date: 2008/12/01 08:05:17 $
%

if isa(M,'char')
    M = clean_it_up(M);
elseif isa(M,'struct')
    % Assume this one came from lasterror.
    M.message = clean_it_up(M.message);
else
    % Do nothing.  Better to report original message than to error.
end

function newStr = clean_it_up(oldStr)
try
    
    n = regexp(oldStr, '(^|\n)(?!Error using ==>)(?<newMsg>.*)?', 'names', 'once');
    if isempty(n)
        newStr = '';
    else
        newStr = n.newMsg;
    end
catch
    newStr = oldStr;
end
