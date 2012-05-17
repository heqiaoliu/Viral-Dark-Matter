function [W, m, xunits] = normalize_w(hObj, W)
%NORMALIZE_W Normalize the frequency vector if it should be.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2006/06/27 23:40:59 $

mfs = getmaxfs(hObj);
if strcmpi(get(getparameter(hObj, 'freqmode'), 'Value'), 'on') || isempty(mfs),
    if isempty(mfs), mfs = 2*pi; end
    for indx = 1:length(W),
        W{indx} = W{indx}/(mfs/2);
    end
    m = 1;
    xunits = 'rad/sample';
else
    
    [W, m, xunits] = cellengunits(W);
end

% [EOF]
