function [out,constrClassTypes] = newconstr(this, keyword, CurrentConstr)
% NEWCONSTR interface method to support graphically adding bounds to the
% visualization
%
% Used by the requirement viewer tool
%
%   [LIST,CLASSTYPES] = NEWCONSTR(View) returns the list of all available
%   constraint types for this view.
%
%   CONSTR = NEWCONSTR(View,TYPE) creates a constraint of the 
%   specified type.
%
 
% Author(s): A. Stothert 10-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:34 $

error('SLControllib:checkpack:errAbstractMethod', ...
   DAStudio.message('SLControllib:checkpack:errAbstractMethod'))
end
