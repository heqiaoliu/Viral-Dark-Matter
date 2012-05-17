function setValue(this,Variable,Value) 
% SETVALUE  method to set the value of a SISOTOOL model variable object. 
%
% this.setValue(Variable,Value)
%  
% Input:
%   Variable - a vector or single VariableID object (valid ID objects are
%              parameterID's, stateID's, ParameterSpec's and StateSpec's), 
%              or a string with the variable name
%   Value    - a double value with the new value for the variable object,
%              or a cell array of values when the Variable argument is a vector. 
%              If the Variable argument is a Spec object the value can be omitted
%
 
% Author(s): A. Stothert 01-Aug-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/12/05 02:22:38 $

if nargin < 3, Value = {}; end

%Parse input types to check which local set methods to call
processed = false;
if ischar(Variable)
   %Want to set a parameter using the fullname
   localSetStringValue(this,Variable,Value)
   processed = true;
end
if isa(Variable,'modelpack.STStateID') || ...
      isa(Variable,'modelpack.StateValue')
   %Want to set a state value
   localSetStateValue(this,Variable,Value)
   processed = true;
end
if isa(Variable,'modelpack.STParameterID') || ...
      isa(Variable,'modelpack.ParameterValue') || ...
      isa(Variable,'modelpack.ParameterSpec')
   %Want to set a parameter value
   localSetParameterValue(this,Variable,Value)
   processed = true;
end

if ~processed
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Variable', ...
      'modelpack.STParameterID, modelpack.STStateID, ParameterSpec, StateSpec, or a string');
end

%--------------------------------------------------------------------------
function localSetStateValue(this,VarID,Val) %#ok<INUSD>
%Local function to set state value. As SISOTOOL states cannot be set this
%function is a no-op.

ctrlMsgUtils.warning('SLControllib:modelpack:stWarnSetStates')

%--------------------------------------------------------------------------
function localSetParameterValue(this,VarID,Val)
%Local function to set parameter value

%Make sure new values are in a cell array
if ~iscell(Val), Val = {Val}; end

%Check input arguments
nVarID  = numel(VarID);
nVal    = numel(Val);
pvVarID = isa(VarID,'modelpack.ParameterValue');
if ~pvVarID && (pvVarID || ~(nVal==1 || nVal==nVarID)) 
   ctrlMsgUtils.error('SLControllib:modelpack:stErrorSetDimensions')
end

TunedBlocks = this.Model.C;
for ct = 1:nVarID
   if pvVarID
      %Convert value object to ID and value
      if isempty(Val), ValIn = VarID(ct).Value; end
      ID = VarID(ct).getID;
      if isa(VarID(ct),'modelpack.STParameterValue')
         Format = VarID(ct).Format;
      else
         Format = [];
      end
   else
      if nVal > 1
         ValIn = Val{ct};
      else
         ValIn = Val{1};
      end
      if isa(VarID(ct),'modelpack.ParameterSpec')
         %Passed a spec object
         ID = VarID(ct).getID;
         if isa(VarID(ct),'modelpack.STParameterSpec')
            Format = VarID(ct).Format;
         else
            Format = [];
         end
      else
         ID = VarID(ct);
         Format = [];
      end
      %Check dimensions and type of new value
      if ~isnumeric(ValIn) || ~all(isfinite(ValIn))
         ctrlMsgUtils.error('SLControllib:modelpack:stErrorNewValueType',ID.getFullName)
      end
      if prod(ID.getDimensions)~=numel(ValIn)
         ctrlMsgUtils.error('SLControllib:modelpack:stErrorNewValueDimension',ID.getFullName)
      end
   end
   
   %Now ready to set the value
   Path = ID.getPath;
   idx = strcmp(get(TunedBlocks,'Identifier'),Path);
   if any(idx)
      %Found tunedblock with this parameter, now find correct parameter and 
      %set value
      found = false;
      TB = TunedBlocks(idx);
      if ~isempty(TB.getMaskParameterSpec)
         %Mask parameter
         allPSpec = TB.getMaskParameterSpec.getID;  
         if iscell(allPSpec), allPSpec = [allPSpec{:}]; end
         idx = 1;
         while ~found && idx <= numel(allPSpec)
            found = ID.isSame(allPSpec(idx));
            if ~found, idx = idx + 1; end;
         end
         if found
            %Match spec index to tunable parameter index
            idxTunable = cumsum(strcmp({TB.Parameters.Tunable},'on'));
            idxTBParam = find(idxTunable >= idx,1,'first');
            %Have index into parameters, set value
            TB.setParameterValue(idxTBParam,ValIn)
            %Clear all compensator dependencies
            this.Model.reset('all',TB)
         end
      end
      if ~found && TB.isTunable
         ZPKSpecs = TB.getZPKParameterSpec;
         if ZPKSpecs.GainSpec.getID.isSame(ID)
            %PZgroup gain parameter
            found = true;
            if isempty(Format), Format = 1; end
            TB.setGainValue(ValIn,Format);
            %Clear all compensator dependencies
            this.Model.reset('all',TB)
         end
         if ~found && ~isempty(ZPKSpecs.PZGroupSpec)
            %Check PZgroups for parameter
            allPSpec = ZPKSpecs.PZGroupSpec;
            pID = allPSpec.getID;
            if iscell(pID), pID = [pID{:}]; end
            idx = 1;
            while ~found && idx <= numel(pID)
               found = ID.isSame(pID(idx));
               if ~found, idx = idx + 1; end
            end
            if found
               if isempty(Format)
                  Format = allPSpec(idx).Format;
               end
               TB.PZGroup(idx).setValue(ValIn,Format);
               %Clear all compensator dependencies
               this.Model.reset('all',TB)
            end
         end
      end
   end
end

%--------------------------------------------------------------------------
function localSetStringValue(this,VarName,Val)
%Local function to set a variable value based on the variable name

idx = strcmp(this.Parameters.getFullName,VarName);
if any(idx)
   %Looking for a parameter value
   localSetParameterValue(this,this.Parameters(idx),Val);
else
   idx = strcmp(this.States.getFullName,VarName);
   if any(idx)
      %Looking for a state value
      localSetStateValue(this,this.States(idx),Val);
   end
end




