function EnableRTO(this, val)
% Enable RTO (turn on/turn off data valve)

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:48 $

if nargin<2, val=true; end
if val, s='on'; else s='off'; end
h = this.rtoListeners;
for i=1:numel(h)
    h(i).Enabled = s;
end

% [EOF]
