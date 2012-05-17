function loadpublicinterface(this, s)
%LOADPUBLICINTERFACE   Load the public interface.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:35:42 $

abstract_loadpublicinterface(this, s);

if s.version.number > 3
   set(this, 'OptimizeScaleValues', s.OptimizeScaleValues); 
end

% [EOF]
