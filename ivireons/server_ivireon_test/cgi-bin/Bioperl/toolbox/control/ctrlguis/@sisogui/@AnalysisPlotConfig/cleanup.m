function cleanup(this) 
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 19:50:23 $

delete(this.Handles.Listeners)
delete(this.Handles.TableListener);
delete(this);