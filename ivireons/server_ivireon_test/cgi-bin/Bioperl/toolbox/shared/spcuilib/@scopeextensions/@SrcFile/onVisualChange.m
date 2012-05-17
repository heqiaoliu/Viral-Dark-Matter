function onVisualChange(this)
%ONVISUALCHANGE React to Visual changes.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 16:08:38 $

% Capture the old command line args before we do anything else.
cmdLineArgs = commandLineArgs(this);

% Close any file handles that might be open.
disconnectData(this.DataHandler);

this.installDataHandler;

openFile(this.DataHandler, this, cmdLineArgs{:});

this.getFrameData;

if strcmp(this.ErrorStatus, 'failure')
    enable(this.Controls, 'off');
    screenMsg(this.Application, this.ErrorMsg);
else
    enable(this.Controls, 'on');
end

% [EOF]
