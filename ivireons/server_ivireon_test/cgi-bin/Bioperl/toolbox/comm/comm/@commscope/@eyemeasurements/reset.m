function reset(this)
%RESET    Reset the eye measurements object
%   RESET(THIS) resets the eye measurement values of the eye measurement object
%   THIS to zero.
%
%   See also COMMSCOPE, COMMSCOPE.EYEMEASUREMENTS,
%   COMMSCOPE.EYEMEASUREMENTS/ANALYZE, COMMSCOPE.EYEMEASUREMENTS/DISP.

%   @commscope/@eyemeasurementsetup
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:19:55 $

% Get field names except Type
s = get(this);
s = rmfield(s, 'Type');
s = rmfield(s, 'DisplayMode');
fNames = fieldnames(s);

% The rest of the fields are measurement values.  Set them to zero.
for p=1:length(fNames)
    set(this, fNames{p}, 0);
end

% Enable eye level search
this.PrivEyeLevelStable = 0;

%-------------------------------------------------------------------------------
% [EOF]
