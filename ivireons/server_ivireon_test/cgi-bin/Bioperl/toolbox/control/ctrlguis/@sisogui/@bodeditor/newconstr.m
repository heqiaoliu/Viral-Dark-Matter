function [out,constrClassTypes] = newconstr(Editor,keyword,CurrentConstr)
%NEWCONSTR  Interface with dialog for creating new constraints.
%
%   [LIST,CLASSTYPES] = NEWCONSTR(Editor) returns the list of all available
%   constraint types for this editor.
%
%   CONSTR = NEWCONSTR(Editor,TYPE) creates a constraint of the 
%   specified type.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.8.4.9 $  $Date: 2010/03/31 18:13:13 $

ReqDB = {...
       'UpperGainLimit', sprintf('Upper gain limit'),     'editconstr.BodeGain', 'srorequirement.bodegain'; ...
       'LowerGainLimit', sprintf('Lower gain limit'),     'editconstr.BodeGain', 'srorequirement.bodegain'; ...
       'GPMargins',      sprintf('Gain & Phase margins'), 'editconstr.GainPhaseMargin', 'srorequirement.gainphasemargin'};

ni = nargin;
if ni==1
    % Return list of constraints that can be added. Check don't already have 
    % @bodegpm constraint
    currConstr = Editor.findconstr;
    noGPM = true;
    ct = 1;
    while ct <= numel(currConstr) && noGPM
       noGPM = noGPM && ~isa(currConstr(ct),'plotconstr.bodegpm');
       ct = ct + 1;
    end
    if noGPM
       idx = 1:size(ReqDB,1);
    else
       idx = [1 2];
    end
    out = ReqDB(idx,[1 2]);
    if nargout == 2
       constrClassTypes = unique(ReqDB(idx,3));
    end  
else
   keyword = localCheckKeyword(keyword,ReqDB);
   idx     = strcmp(keyword,ReqDB(:,1));
   Class   = ReqDB{idx,3};
   dClass  = ReqDB{idx,4};
   switch keyword
      case 'UpperGainLimit'
         Type   = 'upper';
         xUnits = Editor.Axes.XUnits;
         yUnits = Editor.Axes.YUnits{1};

      case 'LowerGainLimit'
         Type   = 'lower';
         xUnits = Editor.Axes.XUnits;
         yUnits = Editor.Axes.YUnits{1};

      case 'GPMargins'
         Type   = 'both';
         yUnits = Editor.Axes.YUnits{1};  %Magnitude
         xUnits = Editor.Axes.YUnits{2};  %Phase
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
      Constr.Ts = Editor.LoopData.Ts;
      % Make sure constraint is below Nyquist freq.
      if Constr.Ts
         Constr.Requirement.setData('xData',(pi/Constr.Ts) * [0.01 0.1]);
      end
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

%Now check display strings for matching keyword, may need to translate kIn
%from an earlier saved version
idx = strcmp(sprintf(kIn),ReqDB(:,2));
if any(idx)
   kOut = ReqDB{idx,1};
else
   kOut = [];
end

