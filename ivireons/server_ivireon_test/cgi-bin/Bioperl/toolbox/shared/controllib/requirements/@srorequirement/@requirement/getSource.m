function Source = getSource(this,CellFlag)
% GETSOURCE  Return requirement source. Returns cell array of individual
%            requirement sources if passed a vector. If optional CellFlag 
%            argument is 'c' always returns a cell array, default is no 
%            cell array.
%
 
% Author(s): A. Stothert 18-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:17 $

if nargin < 2,
   CellFlag = false;
end

nReq = numel(this);
if nReq == 1 && ~strncmpi(CellFlag,'c',1)
   Source = this.Source;
else
   Source = cell(nReq,1);
   for ct = 1:nReq
      Source{ct} = this(ct).Source;
   end
end
