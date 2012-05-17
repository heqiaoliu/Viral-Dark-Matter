function [isvalid, errmsg, errid] = checkincfreqs(h,fprops)
%CHECKINCFREQS   Check for increasing frequencies.
%
%   Inputs:
%       fprops - cell array of frequency properties expected in increasing
%       order.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:14:14 $

% Get all frequency specs
fspecs = get(h,fprops);

% Make it a vector
fspecs = [fspecs{:}];

isvalid = true;
errmsg  = '';
errid   = '';

% Check for increasing values
if any(diff(fspecs) <= 0),
    % Form string for error message
    specstr = '';
    for n = 1:length(fprops)-1,
        specstr = [specstr,fprops{n},', '];
    end
    % Add last one
    specstr = [specstr,fprops{end},'}'];
    
    isvalid = false;
    errmsg  = sprintf('The frequency specifications {%s must have increasing values.', specstr);
    errid   = generatemsgid('invalidSpec');
end

if nargout == 0
    error(errid, errmsg);
end

% [EOF]
