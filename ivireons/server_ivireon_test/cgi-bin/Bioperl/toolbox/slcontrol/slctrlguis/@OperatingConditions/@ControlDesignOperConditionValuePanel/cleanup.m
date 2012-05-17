function cleanup(this) 
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/03/13 17:40:09 $

if ~isempty(this.Dialog)
    javaMethodEDT('cleanup',this.Dialog);
end