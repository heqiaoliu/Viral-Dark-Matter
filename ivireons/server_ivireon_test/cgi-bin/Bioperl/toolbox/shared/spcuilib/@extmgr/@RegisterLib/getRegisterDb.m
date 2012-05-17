function hRegisterDb = getRegisterDb(this,extFileName,varargin)
%GETEXTREGDB Return or create RegisterDb object from library.
%  GETEXTREGDB returns the RegisterDb object corresponding to the specified
%  extension file name.  If the extension file name is not found,
%  a corresponding registration database is created and cached.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/08/03 21:37:42 $

hRegisterDb = findChild(this, 'FileName', extFileName);

if isempty(hRegisterDb)
    % Create new registration database for this extension file name,
    % and pass a reference to RegisterLib's message log for reporting
    hRegisterDb = extmgr.RegisterDb(extFileName, this.MessageLog, varargin{:});

    % Add named database to RegisterLib library
    this.add(hRegisterDb);
end

% [EOF]
