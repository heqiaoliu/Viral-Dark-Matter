function singledataHandler(this, adaptorFcn, rto, rtoIdx)
%SINGLEDATAHANDLER <short description>
%   OUT = SINGLEDATAHANDLER(ARGS) <long description>

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/16 22:34:33 $

newData = (nargin==4);  % otherwise, it's a "refresh" call

if newData
    % Get frame data using adaptor-specific callback
    % UserData is used to accumulate components, no op here for single
    % component
    this.UserData = feval(adaptorFcn, rto, rtoIdx);
    this.time = rto.CurrentTime;
end

this.TargetObject.runtimeData(this);
this.UserData = [];

% [EOF]
