function cleanup(this)
% CLEANUP 
%
 
% Author(s): John W. Glass 19-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/03/13 17:39:35 $

if ~isempty(this.Dialog)
    javaMethodEDT('clearPanel',this.Handles.SummaryArea);
end