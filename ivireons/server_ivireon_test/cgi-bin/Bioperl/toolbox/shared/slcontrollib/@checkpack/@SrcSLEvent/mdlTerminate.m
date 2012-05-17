function mdlTerminate(this, block) %#ok<INUSD>
%MDLTERMINATE Called at model termination (stop).

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:09 $

this.stepFwd  = false;
this.setSnapShotMode('off');

update(this.Controls);

send(this.Application, 'SourceStopped');
end