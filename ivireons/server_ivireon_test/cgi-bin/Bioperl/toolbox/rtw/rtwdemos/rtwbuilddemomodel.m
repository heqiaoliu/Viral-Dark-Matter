function rtwbuilddemomodel(model)
%RTWBUILDDEMOMODEL  Call Real-Time Workshop to build code for demo models.
% 

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2004/10/06 14:00:56 $

try
  feature('RTWBuild',get_param(model,'Handle'));
catch
  error(lasterr);
end

set_param(model,'dirty','off');
