function b = isDataEmpty(this)
% ISDATAEMPTY return true if no data available
%
 
% Author(s): A. Stothert 26-Apr-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/05/10 17:38:10 $

%Return true if data source has no data
b = isempty(this.Data.Data);
end