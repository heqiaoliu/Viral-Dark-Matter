classdef CheckBlockScopeVisData < handle
%

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:36 $

% CHECKBLOCKSCOPEVISDATA data container to link check block with
% visualization. The visualization data source (checkpack.SrcSlEvent) has a 
% listener for events fired by this object.
%

properties
   NewData
   NewTime
end
events
   DataChanged
end
end
