function hresp = responseobj(this)
%RESPONSEOBJ   Pseudopowerresp response object.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:35:27 $

% Create the response obj. 
hresp = sigresp.pseudopowerresp(this);

% [EOF]
