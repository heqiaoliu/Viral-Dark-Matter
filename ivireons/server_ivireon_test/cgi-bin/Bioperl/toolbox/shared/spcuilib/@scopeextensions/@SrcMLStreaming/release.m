function release(this)
%RELEASE  

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:02 $

disconnectData(this);
this.DataSpecsLocked = false;
update(this.Controls);

send(this.Application, 'sourceStop');

% [EOF]
