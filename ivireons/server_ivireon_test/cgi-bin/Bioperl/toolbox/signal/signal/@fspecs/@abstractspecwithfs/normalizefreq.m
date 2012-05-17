function normalizefreq(h,boolflag,Fs)
%NORMALIZEFREQ   Normalize frequency specifications.

%   Author(s): R. Losada
%   Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2005/12/22 19:02:33 $

% Check for error condition first
if (nargin > 2) && boolflag,
       error(generatemsgid('FsnotAllowed'),'Specifying Fs is not allowed while requesting to normalize the frequency specifications.');
end

% Check for early return condition next
if nargin < 2,
    boolflag = true;
end
if boolflag && h.NormalizedFrequency,
    return;
end

oldFs = h.privFs;
% Assign Fs if specified
if (nargin > 2) && ~boolflag,
    h.privFs = Fs;
end

oldnormfreq = h.NormalizedFrequency;
h.privNormalizedFreq = boolflag;

if (~h.privFs == 0),
    p = props2normalize(h);
    if boolflag,
        for n = 1:length(p),
            set(h,p{n},2*get(h,p{n})/h.privFs);
        end
    else
        if ~oldnormfreq
           % If normalized frequency was already false set Fs so that specs
           % are recomputed correctly
           cf = h.privFs/oldFs; % Correction factor
        else
            cf = h.privFs*0.5;
        end
        for n = 1:length(p),
            set(h,p{n},cf*get(h,p{n}));
        end
    end
end




% [EOF]
