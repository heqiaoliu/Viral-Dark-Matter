function c = deviceCount()
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:48 $

c = feval( '_gpu_deviceCount' );

end
