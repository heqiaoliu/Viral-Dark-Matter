function captureState(this)
%CAPTURESTATE   Capture the current state.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:20:09 $

% Get the values of all of the public properties and save them in the
% "LastAppliedState" property (which is private).  This 
laState = getState(this);

set(this, 'LastAppliedState', laState);

if ~isempty(this.FixedPoint)
    captureState(this.FixedPoint);
end

% [EOF]
