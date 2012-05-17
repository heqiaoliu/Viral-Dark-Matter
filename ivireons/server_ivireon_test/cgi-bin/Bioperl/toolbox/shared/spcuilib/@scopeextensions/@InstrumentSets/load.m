function load(this, fName)
%LOAD   Load an instrument set.
%   LOAD(H) load an instrumentation set.  Launches a UIGETFILE to specify
%   the file name.
%
%   LOAD(H, FNAME) load an instrumentation set from the file specified by
%   the string FNAME.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/14 04:06:36 $

if nargin < 2
    
    % use GUI chooser/browser
    chooseFile(this.RecentFilesUI.RecentFiles);
else
    
    uiscopes.iload(fName);
end

% [EOF]
