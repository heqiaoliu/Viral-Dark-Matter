function initialize(h);
%INITIALIZE  Initialize interpolating filter object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/10 19:19:45 $

R = h.PolyphaseInterpFactor;

% Design polyphase filter bank.
if R==1

    % Trivial case if no polyphase interpolation.
    
    % Set subfilter length to 1.
    h.SubfilterLength = 1;
        
    h.FilterBank = [1]; % Filter is simply a pass-through.

else

    % Otherwise, use interpolating filter from Signal Processing Toolbox.
    
    % Set subfilter length to maximum length.
    h.SubfilterLength = h.MaxSubfilterLength;
   
    M = h.SubfilterLength;
    freqMult = 0.5;
    b = intfilt(R, M/2, freqMult);

    h.FilterBank = reshape([b 0], R, M);

end

% Reset filter.
h.reset;

