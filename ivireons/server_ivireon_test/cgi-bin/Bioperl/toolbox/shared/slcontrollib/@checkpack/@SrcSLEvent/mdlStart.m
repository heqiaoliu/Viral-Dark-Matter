function mdlStart(this, block)
%MDLSTART Called at model start time.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:08 $

setSnapShotMode(this, 'off');

if nargin > 1
    this.RunTimeBlock = block;
else
    block = this.RunTimeBlock;
end

mdlStart(this.DataHandler, block);

% If we are already installed, make sure we update here.
if isequal(this.Application.DataSource, this)
    installDataSource(this.Application);
end

% [EOF]
