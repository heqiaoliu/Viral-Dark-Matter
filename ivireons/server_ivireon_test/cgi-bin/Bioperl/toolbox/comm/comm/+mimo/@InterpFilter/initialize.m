function initialize(h)
%INITIALIZE  Initialize interpolating filter object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:06 $

R = h.PolyphaseInterpFactor;

% Design polyphase filter bank.
if R==1
    % Trivial case if no polyphase interpolation.
    
    % Set subfilter length to 1.
    h.SubfilterLength = 1;
        
    h.FilterBank = 1; % Filter is simply a pass-through.

else
    % Otherwise, use interpolating filter from signal.
    
    % Set subfilter length to maximum length.
    h.SubfilterLength = h.MaxSubfilterLength;
   
    L = h.SubfilterLength;
    freqMult = 0.5;
    b = intfilt(R, L/2, freqMult);

    h.FilterBank = reshape([b 0], R, L);

end

% Reset filter.
h.reset;
