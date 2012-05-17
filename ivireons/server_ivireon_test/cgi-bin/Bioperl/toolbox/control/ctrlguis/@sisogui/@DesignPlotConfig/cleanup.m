function cleanup(this)
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 19:50:30 $

delete(this.Listeners.TableChanged)
delete(this.Listeners.ConfigChange)
delete(this);