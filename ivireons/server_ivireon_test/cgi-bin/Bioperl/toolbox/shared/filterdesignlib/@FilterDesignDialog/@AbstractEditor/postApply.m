function [b, str] = postApply(this)
%POSTAPPLY   Send the DialogApplied event.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:20:59 $

b = true;
str = '';

send(this, 'DialogApplied', handle.EventData(this, 'DialogApplied'));

% [EOF]
