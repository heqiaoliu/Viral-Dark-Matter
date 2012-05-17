function hresp = responseobj(this)
%RESPONSEOBJ   Magresp response object.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:35:20 $

% Create the response object. 
hresp = sigresp.freqz(this);

% [EOF]
