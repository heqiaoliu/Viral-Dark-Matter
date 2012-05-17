function [props,E] = deviceProperties( opt_idx )
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:49 $

if nargin == 0
    idx = parallel.internal.gpu.currentDeviceIndex;
else
    idx = opt_idx;
end

try
    props = feval( '_gpu_getProperties', idx );
    E = [];
catch E
end

end
