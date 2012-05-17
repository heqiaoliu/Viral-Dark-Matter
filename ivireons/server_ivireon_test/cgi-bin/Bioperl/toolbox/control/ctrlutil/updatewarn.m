function updatewarn
%UPDATEWARN  output a warning when LOADOBJ routines are called

%   Author(s): G. Wolodkin 03/15/2000
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2007/12/14 14:29:28 $

persistent last_old_object;

if isempty(last_old_object) || (etime(clock, last_old_object) > 1)
   ctrlMsgUtils.warning('Control:ltiobject:UpdatePreviousVersion')
end
last_old_object = clock;
