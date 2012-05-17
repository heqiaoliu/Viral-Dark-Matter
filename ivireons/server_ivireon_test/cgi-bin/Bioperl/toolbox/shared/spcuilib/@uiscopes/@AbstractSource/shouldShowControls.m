function out = shouldShowControls(this,controlType)
%SHOULDSHOWCONTROLS For source specific control visibility
% Returns true if the controls should be visible on the scope.  

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:44:12 $

% show all controls unless the derived class forbids it
% the baseclass only knows of the control type 'Base'
out = true;

% [EOF]
