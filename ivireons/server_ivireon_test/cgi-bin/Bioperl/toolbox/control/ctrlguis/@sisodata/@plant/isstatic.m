function boo = isstatic(this)
% Returns TRUE if model array is a pure gain.

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/03/26 17:22:25 $

boo = true;
P = this.P;
for ct = 1:numel(P)
    if ~isstatic(P(ct));
        boo = false;
        break;
    end
end
