function dialogClosecallback(this)
%DIALOGCLOSECALLBACK Called when dialog closes.

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/27 23:40:40 $

send(this,'DialogClose', handle.EventData(this, 'DialogClose'));

% [EOF]
