function s = savepublicinterface(this)
%SAVEPUBLICINTERFACE   Save the public interface.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:35:44 $

s = abstract_savepublicinterface(this);
s.OptimizeScaleValues = get(this, 'OptimizeScaleValues');

% [EOF]
