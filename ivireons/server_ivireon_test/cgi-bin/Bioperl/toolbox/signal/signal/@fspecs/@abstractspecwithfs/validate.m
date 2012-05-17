function [isvalid,errmsg,msgid] = validate(h)
%VALIDATE   Validate specs.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/12/26 22:14:18 $

% Populate defaults
isvalid = true;
errmsg = '';
msgid = '';

if h.NormalizedFrequency,
    upperlimit = 1;
else
    % Fs is used 
    upperlimit = h.Fs/2;
end

% Get all frequency specs
fspecs = get(h,props2normalize(h));

% Make it a vector
fspecs = [fspecs{:}];

if any(fspecs > upperlimit),
    isvalid = false;
    errmsg = sprintf('Frequency specifications must be between 0 and %0.5g.',upperlimit);
    msgid = generatemsgid('invalidSpec');
    return
end

[isvalid, errmsg, msgid] = thisvalidate(h);

% [EOF]
