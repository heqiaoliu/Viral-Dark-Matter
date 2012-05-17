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
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:59:40 $

ReqDB = {...
      'PhaseMargin', sprintf('Phase margin'), 'editconstr.GainPhaseMargin', 'srorequirement.gainphasemargin';...
      'GainMargin',  sprintf('Gain margin'),  'editconstr.GainPhaseMargin', 'srorequirement.gainphasemargin'};

ni = nargin;
if ni==1
    % Return list of constraints that can be added. Check don't already have 
    % @gainphasemargin constraint
    hReqTool = this.Application.getExtInst('Tools:Requirement viewer');
    if isempty(hReqTool.hReq)
       %Can only add GPM if none is defined
       idx = [1 2];
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
   switch keyword
      case 'PhaseMargin'
         Type  = 'phase';
      case 'GainMargin'
         Type  = 'gain';
   end
   
   % Create instance
   if nargin > 2 && isa(CurrentConstr, Class)
      % Recycle existing instance
      Constr = CurrentConstr; 
      Constr.Requirement.setData('type',Type);
   else
      % Create new instance
      reqObj = feval(dClass);
      reqObj.setData('type',Type);
      Constr = feval(Class,reqObj);
      Constr.setDisplayUnits('XUnits',this.hPlot.Axes.XUnits);
      Constr.setDisplayUnits('YUnits','dB');
   end
   out = Constr;
end