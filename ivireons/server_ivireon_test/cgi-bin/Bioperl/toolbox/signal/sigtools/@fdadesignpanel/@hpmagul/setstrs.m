function [upper, lower, lbls] = setstrs(this) %#ok
%SETSTRS Returns the strings to use to setup the contained object/

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:40:46 $

upper = {'DstopUpper', 'DpassUpper'};
lower = {'DstopLower', 'DpassLower'};
lbls  = {'Dstop', 'Dpass'};

% [EOF]
