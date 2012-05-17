function result = usejavadialog(functionName)

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
result = usejava('awt');
% For -nojvm/-nodisplay modes the dialogs follow a deprecated code path
% that already throws a warning


% Show the warning for -nodisplay/-noFigureWindows mode
% warnfiguredialog method only shows a warning if java is present
warnfiguredialog(functionName);


% if JVM is not there, the -nojvm warning is generated
if (~usejava('jvm'))
    warning('MATLAB:HandleGraphics:noJVM', ['This functionality is no longer supported under the -nojvm startup option. ' ...
                                           'For more information, see "Changes to -nojvm Startup Option" in the MATLAB Release Notes. ' ...
                                           'To view the release note in your system browser, ' ...
                                           'run  web(''http://www.mathworks.com/access/helpdesk/help/techdoc/rn/bropbi9-1.html#brubkzc-1'', ''-browser'')']);
end


if (feature('UseOldFileDialogs') == 1)
    result = false;
end