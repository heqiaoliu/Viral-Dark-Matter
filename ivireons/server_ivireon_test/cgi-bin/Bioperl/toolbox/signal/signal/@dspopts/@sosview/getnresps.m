function n = getnresps(this, Hd)
%NRESPS   Return the number of responses for the given filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/02/23 02:48:46 $

switch lower(this.View)
    case 'complete'
        n = 1;
    case {'cumulative', 'individual'}
        n = nsections(Hd);
    case 'userdefined'
        % Call trim custom so we throw away any responses that have all of
        % their indexes greater than nsections of Hd.
        n = length(trimcustom(this, Hd));
end

% [EOF]
