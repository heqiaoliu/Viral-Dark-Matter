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
% $Revision: 1.1.8.3 $ $Date: 2010/04/11 20:41:49 $

ReqDB = {...
   'StepResponse', sprintf('Step response bounds'),  'editconstr.StepResponse', 'srorequirement.stepresponse'};

if nargin == 1
   % Return list of constraints that can be added. Check don't already have
   % @stepresponse constraint
   hReqTool = this.Application.getExtInst('Tools:Requirement viewer');
   if isempty(hReqTool.hReq)
      %Can only add step response if none is defined
      idx = 1;
   else
      idx = [];
   end
   out = ReqDB(idx,[1 2]);
   if nargout == 2
      constrClassTypes = unique(ReqDB(idx,3));
   end
else
   idx     = strcmp(keyword,ReqDB(:,1));
   Class   = ReqDB{idx,3};
   dClass  = ReqDB{idx,4};
   Type  = 'step';
   
   % Create instance
   if nargin > 2 && isa(CurrentConstr, Class)
      % Recycle existing instance
      Constr = CurrentConstr;
      Constr.Requirement.setData('type',Type)
   else
      % Create new instance
      reqObj = feval(dClass);
      reqObj.setData('type',Type);
      Constr = feval(Class,reqObj);
      Constr.setDisplayUnits('xunits',this.hPlot.Axes.XUnits);
      Constr.setDisplayUnits('yunits','abs');
   end
   out = Constr;
end