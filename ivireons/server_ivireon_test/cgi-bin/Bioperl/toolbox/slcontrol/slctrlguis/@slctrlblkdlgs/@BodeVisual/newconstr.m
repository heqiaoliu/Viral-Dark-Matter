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
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:29 $

ReqDB = {...
       'UpperGainLimit', sprintf('Upper gain limit'),     'editconstr.BodeGain', 'srorequirement.bodegain' ;...
       'LowerGainLimit', sprintf('Lower gain limit'),     'editconstr.BodeGain', 'srorequirement.bodegain'};

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
   switch keyword
      case 'UpperGainLimit'
         Type   = 'upper';
         xUnits = this.hPlot.Axes.XUnits;
         yUnits = this.hPlot.Axes.YUnits{1};

      case 'LowerGainLimit'
         Type   = 'lower';
         xUnits = this.hPlot.Axes.XUnits;
         yUnits = this.hPlot.Axes.YUnits{1};
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
      Constr.setDisplayUnits('xunits',xUnits);
      Constr.setDisplayUnits('yunits',yUnits);
   end

   %Special initialization for bode gain constr
   if strcmp(Class,'editconstr.BodeGain')
      % Set sample time and units
      if isempty(this.hPlot.Response)
         %Assume continuous for now
         Constr.Ts = 0;
      else
         Constr.Ts = this.hPlot.Response(1).DataSrc.Model.Ts;
      end
      % Make sure constraint is below Nyquist freq.
      if Constr.Ts
         Constr.Requirement.setData('xData',(pi/Constr.Ts) * [0.01 0.1]);
      end
   end
   out = Constr;
end