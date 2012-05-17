function save(this, fName)
%SAVE     Save the current instrumentation set.
%   SAVE(H) save the current instrumentation set.  Launches a UIPUTFILE to
%   specify the file name.
%
%   SAVE(H, FNAME) save the current instrumentation set to the file
%   specified by the string FNAME.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/14 04:06:37 $

if nargin < 2

    inst = uiscopes.iget;
    if isempty(inst)
        DAStudio.warning('Spcuilib:scopes:NoSerializableScopes');
        return;
    end
    
    % use GUI chooser/browser
    saveFile(this.RecentFilesUI.RecentFiles);
else

    uiscopes.isave(fName);
end

% [EOF]
