function [OK, out] = dctSystem( command )
; %#ok Undocumented
% Wrapper around system to ensure that we are not in a UNC path on windows
%
%  [OK, out] = dctSystem( command )

%  Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2010/01/25 21:30:54 $ 

cdir = pwd;
% Is the current directory a UNC path?
CWD_IS_UNC = ispc && ~isempty(regexp(cdir, '^\\\\', 'once'));

% Try the following in order - matlab tempdir, %TEMP%, %WINDIR%, C:\
if CWD_IS_UNC
    try
        if exist(tempdir, 'dir')
            cd(tempdir);
        else
            temp = getenv('TEMP');
            windir  = getenv('WINDIR');
            if exist(temp, 'dir')
                cd(temp);
            elseif exist(windir, 'dir')
                cd(windir)
            else
                cd('C:\');
            end
        end
    catch %#ok<CTCH>
    end
end

if ispc
    % Remove anything starting with matlabroot from the windows
    % path as this might cause dll issues (particularly seen in our
    % integration with LSF 7.0). The actual search is to look-before
    % for Beginning Of Line or ; followed by MATLABROOT followed by
    % anything except ; followed by ; or EOL. Then replace '\' with
    % '\\' in the pattern
    path = regexprep(getenv('PATH'), strrep(['(?<=(^|;))' matlabroot '[^;]*(;|$)'], '\', '\\'), '');
    command = sprintf('set PATH=%s&&%s', path, command);
end

[OK, out] = system(command);

% Now change back to the starting directory
if CWD_IS_UNC
    try
        cd(cdir);
    catch %#ok<CTCH>
    end
end