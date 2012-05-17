function idx = currentDeviceIndex()
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:47 $

idx = feval( '_gpu_selectedDeviceIdx' );
end
