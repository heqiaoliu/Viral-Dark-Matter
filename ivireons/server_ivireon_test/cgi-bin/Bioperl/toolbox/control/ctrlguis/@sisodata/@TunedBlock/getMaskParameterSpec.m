function MaskParamSpec = getMaskParameterSpec(this) 
% GETMASKPARAMETERSPECS  method to return any mask parameter specs for the
% tuned block
%
 
% Author(s): A. Stothert 22-Nov-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 14:28:58 $

if numel(this.Parameters) == 0
   %Quick exit as no parameters
   MaskParamSpec = [];
   return
end

%Find tunable mask parameters
InPars     = this.Parameters;
idxTunable = strcmp({InPars.Tunable},'on');
InPars     = InPars(idxTunable);

%Check for known parameters
MaskParamSpec = this.MaskParamSpec;
if ~isempty(MaskParamSpec)
   KnowID       = MaskParamSpec.getID;
   KnownNames   = KnowID.getFullName;
else
   KnownNames   = cell(0,1);
end

for ct_P = 1:numel(InPars)
   %Check if already have a Spec for the parameter 
   FullName = sprintf('%s:%s',this.Identifier,InPars(ct_P).Name);
   if ~isempty(KnownNames)
      idxMask = strcmp(KnownNames,FullName);
   else
      idxMask = false;
   end
   NewDim = size(InPars(ct_P).Value);
   if ~any(idxMask)
      %Need to create a new parameter spec
      PID = modelpack.STParameterID(...
         sprintf('%s (mask)',InPars(ct_P).Name), ...
         NewDim, ...
         this.Identifier, ...
         'double', ...
         {''}, ...
         InPars(ct_P).Name);
      idxMask = numel(MaskParamSpec)+1;
      if isempty(MaskParamSpec)
         %First Spec
         MaskParamSpec = modelpack.STParameterSpec(PID);
      else
         MaskParamSpec(idxMask,1) = modelpack.STParameterSpec(PID);
      end
   else
      %Check that dimensions are up to date
      pID = MaskParamSpec(idxMask,1).getID;
      OldDim = pID.getDimensions;
      if ~isequal(OldDim,NewDim)
         pID.update([],'Dimension',NewDim)
         MaskParamSpec(idxMask,1).setDimensions(NewDim);
      end
   end
   % Update initial, typical, max and min  values
   MaskParamSpec(idxMask,1).InitialValue = InPars(ct_P).Value;
   MaskParamSpec(idxMask,1).Known        = true(NewDim);
   MaskParamSpec(idxMask,1).Minimum      = -inf(NewDim);
   MaskParamSpec(idxMask,1).Maximum      = inf(NewDim);
   MaskParamSpec(idxMask,1).TypicalValue = ones(NewDim);
end

%Store mask parameters
this.MaskParamSpec = MaskParamSpec(1:numel(InPars));

