function warnfiguredialog(functionName)

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

% Shows the warning in -nodisplay and -noFigureWindows mode

% (usejava('jvm') will return true in -nodisplay and -noFigureWindows mode,
% but false in -nojvm mode)

% @HACK HACK alert: if you are modifying the warning message, 
% please also modify the same message in the following files:
%  * matlab/toolbox/matlab/uitools/private/warnfiguredialog.m
%  * matlab/src/hg/gs_obj/figure.cpp

if usejava('jvm') && ~feature('ShowFigureWindows')
    warningId = strcat('MATLAB:', functionName, ':DeprecatedBehavior');
    warning(warningId, ['This functionality is no longer supported under the -nodisplay and -noFigureWindows startup options. '...
                        'For more information, see \"Changes to -nodisplay and -noFigureWindows Startup Options\" in the MATLAB Release Notes. '...
                        'To view the release note in your system browser, '...
                        'run  web(''http://www.mathworks.com/access/helpdesk/help/techdoc/rn/br5ktrh-1.html#br5ktrh-3'', ''-browser'')']);
end
