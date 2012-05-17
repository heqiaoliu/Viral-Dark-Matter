function cleanup(this)
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 19:50:26 $

for ct = 1:numel(this.MethodManagers)
    delete(this.MethodManagers(ct));
end
delete(this)