function sig = sigresponse(sigvalues, domain)
%SIGRESPONSE  Construct a signal response.
%
%   Inputs:
%     sigvalues  - vector of signal values.
%     domain     - domain of signal.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $Date: 2007/09/14 15:58:18 $

error(nargchk(0, 2, nargin,'struct'));
        
sig = channel.sigresponse;

switch nargin
    case 0
        sig.Values = 0;
        sig.Domain = 0;
    case 1
        sig.Values = sigvalues;
        sig.Domain = 0:length(sigvalues)-1;
    case 2
        sig.Values = sigvalues;
        sig.Domain = domain;
end
