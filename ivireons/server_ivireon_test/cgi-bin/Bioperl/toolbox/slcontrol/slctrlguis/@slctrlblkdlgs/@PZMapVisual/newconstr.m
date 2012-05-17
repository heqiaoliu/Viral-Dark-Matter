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
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:59:42 $

ReqDB = {...
   'SettlingTime',     sprintf('Settling time'),     'editconstr.SettlingTime',     'srorequirement.settlingtime';...
   'PercentOvershoot', sprintf('Percent overshoot'), 'editconstr.DampingRatio',     'srorequirement.dampingratio';...
   'DampingRatio',     sprintf('Damping ratio'),     'editconstr.DampingRatio',     'srorequirement.dampingratio';...
   'NaturalFrequency', sprintf('Natural frequency'), 'editconstr.NaturalFrequency', 'srorequirement.naturalfrequency'};

ni = nargin;
if ni==1
   % All options
   out = ReqDB(:,[1 2]);
   if nargout == 2
      constrClassTypes = unique(ReqDB(:,3));
   end
else
   idx     = strcmp(keyword,ReqDB(:,1));
   Class   = ReqDB{idx,3};
   dClass  = ReqDB{idx,4};
   
   % Create instance
   reuseInstance = ni>2 && isa(CurrentConstr,Class);
   if reuseInstance && (strcmpi(keyword,'PercentOvershoot') || strcmpi(keyword,'DampingRatio'))
      if strcmp(keyword,'PercentOvershoot') && strcmp(CurrentConstr.Type,'damping') || ...
            strcmp(keyword,'DampingRatio') && strcmp(CurrentConstr.Type,'overshoot')
         reuseInstance = false;
      end
   end
   if reuseInstance
      % Recycle existing instance if of same class
      Constr = CurrentConstr;
   else
      %Create new requirement instance
      reqObj = feval(dClass);
      %Ensure feedback sign for requirement is zero (i.e., open loop)
      reqObj.FeedbackSign = 0;
      %Create corresponding requirement editor class
      Constr = feval(Class,reqObj);
      %Determine sampling time for the constraint
      if isempty(this.hPlot.Response)
         %Assume continuous for now
         Constr.Ts = 0;
      else
         Constr.Ts = this.hPlot.Response(1).DataSrc.Model.Ts;
      end
      
      if strcmp(keyword,'PercentOvershoot')
         Constr.Type = 'overshoot';
         Constr.Requirement.Name = Constr.Type;
      elseif strcmp(keyword,'DampingRatio')
         Constr.Type = 'damping';
         Constr.Requirement.Name = Constr.Type;
      elseif strcmp(keyword,'NaturalFrequency')
         if Constr.Ts, Constr.Frequency = 1/Constr.Ts; end
         Constr.setDisplayUnits('xunits','rad/s');
      elseif strcmp(keyword,'SettlingTime') && Constr.Ts
         Constr.SettlingTime = 10*Constr.Ts;
      end
   end
   
   out = Constr;
end