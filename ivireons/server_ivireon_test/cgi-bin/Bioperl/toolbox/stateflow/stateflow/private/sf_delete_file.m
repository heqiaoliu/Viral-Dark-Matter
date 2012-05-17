function sf_delete_file(fileName, force)

% Copyright 2003-2009 The MathWorks, Inc.

% G569013: We need to call dos() and unix() with output arguments to
% suppress the ugly output from the OS.
if nargin >= 2
    if force
        if ispc
            [~,~] = dos(['attrib -r "', fileName,'"']);
        else
            [~,~] = unix(['chmod +w ', fileName]);
        end
    end
end
if ispc
    [~,~] = dos(['del /f /q "',fileName,'"']);
else
    [~,~] = dos(['\rm -f ',fileName]);
end

