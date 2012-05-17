function hout = IODispatch()
% IODispatch
%
 
% Author(s): John W. Glass 22-Sep-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/05/18 05:59:58 $

mlock
persistent this
    
if isempty(this)
    this = LinAnalysisTask.IODispatch;
end

hout = this;