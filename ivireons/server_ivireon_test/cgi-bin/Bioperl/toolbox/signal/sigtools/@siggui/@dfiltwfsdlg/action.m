function aClose = action(hObj)
%ACTION Action for the dfiltwfsdlg

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:22:34 $

aClose = true;

names = get(hObj, 'BackupNames');
bfs   = get(hObj, 'BackupFs');

filtobjs = get(hObj, 'Filters');

hfs = getcomponent(hObj, '-class', 'siggui.fsspecifier');
if get(hObj, 'Index')
    
    for indx = 1:length(bfs)
        if strncmpi(bfs(indx).Units, 'normalized', 10),
            v = [];
        else
            v = evaluatevars(bfs(indx).Value);
        end
        bfs(indx).Value = v;
    end
    
    % Do this in two separate loops incase evaluatevars errors out.  If
    % evaluatevars errors out then we do not want to set any of the filts.
    for indx = 1:length(filtobjs)
        fs{indx} = getfsvalue(hfs, bfs(indx));
        set(filtobjs(indx), 'Name', names{indx});
    end
    setfs(filtobjs, fs);
else
    fs = getfsvalue(hfs);
    
    for indx = 1:length(filtobjs),
        set(filtobjs(indx), 'Name', names{indx});
    end
    setfs(filtobjs, fs);
    
    % Update all the backup Fs's to match their new sampling frequency
    % (since they were applied to all).
    fs_listener(hObj);
    set(hObj, 'isApplied', 1);
    
end

% [EOF]
