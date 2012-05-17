function closereq
%CLOSEREQ  Figure close request function.
%   CLOSEREQ deletes the current figure window.  By default, CLOSEREQ is
%   the CloseRequestFcn for new figures.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2009/10/24 19:18:02 $

%   Note that closereq now honors the user's ShowHiddenHandles setting
%   during figure deletion.  This means that deletion listeners and
%   DeleteFcns will now operate in an environment which is not guaranteed
%   to show hidden handles.
if isempty(gcbf)
    if length(dbstack) == 1
        warning('MATLAB:closereq', ...
                'Calling closereq from the command line is now obsolete, use close instead');
    end
    close force
else
    if (isa(gcbf,'ui.figure'))
        % Convert GBT1.5 figure to a double.
        delete(double(gcbf));
    else
        delete(gcbf);
    end
end
