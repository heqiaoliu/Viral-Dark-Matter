function minorder = getminorder(this, varargin)
%GETMINORDER   Get the minorder.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/10/31 07:04:24 $

n = firpmord(varargin{:});

if n < 3,
    n = 3;
end

% Force the min flag to even for MinPhase filters.
if this.MinPhase || this.MaxPhase || isminordereven(this)
    minorder = 'mineven';
    
    % Make sure that we have an even order as the first guess.
    if rem(n, 2)
        n = n+1;
    end
elseif isminorderodd(this)
    minorder = 'minodd';
    
    % Make sure that we have an odd order as the first guess.
    if ~rem(n, 2)
        n = n + 1;
    end
else
    minorder = 'minorder';
end

minorder = {minorder, n};

% [EOF]
