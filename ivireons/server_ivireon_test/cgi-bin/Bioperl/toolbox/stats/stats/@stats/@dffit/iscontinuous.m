function result = iscontinuous(hFit)
%ISCONTINUOUS Is this distribution continuous?

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:22:01 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Smooth fits are always continuous
if isequal(hFit.fittype, 'smooth')
   result = true;
else
   result = hFit.distspec.iscontinuous;
end
