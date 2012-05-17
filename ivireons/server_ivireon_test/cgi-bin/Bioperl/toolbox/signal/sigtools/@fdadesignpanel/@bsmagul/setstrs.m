function [upper, lower, lbls] = setstrs(this) %#ok
%SETSTRS Returns the strings to use to setup the contained object/

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:39:51 $

upper = {'Dpass1Upper', 'DstopUpper', 'Dpass2Upper'};
lower = {'Dpass1Lower', 'DstopLower', 'Dpass2Lower'};
lbls  = {'Dpass1', 'Dstop', 'Dpass2'};

% [EOF]
