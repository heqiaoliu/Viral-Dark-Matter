function err = callhelp(file, method, addition)
%CALLHELP Calls a specified section of a help file to display.
%       CALLHELP(FILE) displays an entire FILE contents in the MATLAB
%       Command Window.
%
%       CALLHELP(FILE, STR) searches [STR '_help_begin'] and [STR '_help_end']
%       in FILE and displays the section in the MATLAB Command Window.
%
%       CALLHELP(FILE, STR, ADDITION) displays additional information with a
%       line break.
%
%       ERR = CALLHELP(...) output error message.
%       ERR = 0, command is successfully executed.
%       ERR = -2, file has not been  found.
%
%       See also ENCODE, DECODE.

%       Copyright 1996-2007 The MathWorks, Inc.
%       $Revision: 1.13.4.2 $  $Date: 2007/09/14 15:57:11 $

% help lines for individual modulation method.
hand = fopen(file);
if hand<=0
    error('comm:callhelp:IncompleteCommToolbox','The Communications Toolbox on your machine is not a completed one.')
else
    x = fscanf(hand, '%c', Inf);
    index_begin = findstr(x, [method,'_help_begin']);
    index_end = findstr(x, [method,'_help_end']);
    if index_end > index_begin
         x = x(index_begin+12+length(method):index_end-1);
        fprintf('%s', x);
        if nargin > 2
            disp(' ')
            disp(['    ', addition])
        end
        if nargout > 0
            err = 0;
        end
    else
        if nargout > 0
            err = -2;
        else
            disp(['No help for ', method]);
        end
    end
end
fclose(hand);
% end of callhelp.m

