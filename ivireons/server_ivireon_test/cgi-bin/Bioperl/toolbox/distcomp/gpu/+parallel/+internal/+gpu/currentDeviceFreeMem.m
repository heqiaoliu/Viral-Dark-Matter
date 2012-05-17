function idx = currentDeviceFreeMem()
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:46 $

idx = feval( '_gpu_selectedDeviceFreeMem' );
end
