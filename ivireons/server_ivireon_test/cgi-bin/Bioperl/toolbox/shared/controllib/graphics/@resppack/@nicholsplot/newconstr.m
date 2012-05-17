function [out,constrClassTypes] = newconstr(this, keyword, CurrentConstr) 
%Interface with dialog for creating new constraints.
%
%   [LIST,CLASSTYPES] = NEWCONSTR(View) returns the list of all available
%   constraint types for this view.
%
%   CONSTR = NEWCONSTR(View,TYPE) creates a constraint of the 
%   specified type.
 
% Author(s): A. Stothert 23-Sep-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:00 $

ReqDB = {...
      'PhaseMargin',   sprintf('Phase margin'),           'editconstr.GainPhaseMargin', 'srorequirement.gainphasemargin';...
      'GainMargin',    sprintf('Gain margin'),            'editconstr.GainPhaseMargin', 'srorequirement.gainphasemargin';...
      'CLPeakGain',    sprintf('Closed-Loop peak gain'),  'editconstr.NicholsPeak',     'srorequirement.nicholspeak'; ...
      'GPRequirement', sprintf('Gain-Phase requirement'), 'editconstr.NicholsLocation', 'srorequirement.nicholslocation'};

if nargin == 1
   % Return list of valid constraints
   out = ReqDB(:,[1 2]);
   if nargout == 2
      constrClassTypes = ReqDB(:,3);
   end
else
   keyword = localCheckKeyword(keyword,ReqDB);
   idx     = strcmp(keyword,ReqDB(:,1));
   Class   = ReqDB{idx,3};
   dClass  = ReqDB{idx,4};
   switch keyword
      case 'PhaseMargin'
         Type  = 'phase';
      case 'GainMargin'
         Type  = 'gain';
      case 'CLPeakGain'
         Type  = 'upper';
      case 'GPRequirement'
         Type  = 'lower';
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
      Constr.setDisplayUnits('XUnits',this.Axes.XUnits);
      Constr.setDisplayUnits('YUnits','dB');
   end
   out = Constr;
end

%--------------------------------------------------------------------------
function kOut = localCheckKeyword(kIn,ReqDB)
%Helper function to check keyword is correct, mainly needed for backwards
%compatibility with old saved constraints

if any(strcmp(kIn,ReqDB(:,1)))
   %Quick return is already an identifier
   kOut = kIn;
   return
end

%Handle case where gainphasemargin requirement is one object
if strcmp(kIn,'GainPhaseMargin')
   kOut = 'PhaseMargin';
   return
end

%Now check display strings for matching keyword
idx = strcmp(kIn,ReqDB(:,2));
if ~isempty(idx)
   kOut = ReqDB{idx,1};
else
   kOut = [];
end

