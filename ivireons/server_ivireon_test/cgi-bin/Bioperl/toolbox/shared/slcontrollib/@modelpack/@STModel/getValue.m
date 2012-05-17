function Value = getValue(this,Variable) 
% GETVALUE  method to return the value of a SISOTOOL model object. 
%
% Value = this.getValue(Variable)
%
% Input:
%   Variable - a vector or single VariableID object, valid objects are
%              parameterID's, parameterSpecs, stateID's, stateSpecs or 
%              a string with the variable name
%
% Output:
%   Value - a vector of VariableValue objects corresponding to the requested varaibales
%           with the current value set to the model variable value
%
 
% Author(s): A. Stothert 01-Aug-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2007/12/14 15:01:44 $

%Parse input types to check which local set methods to call
processed = false;
if ischar(Variable)
   %Want to set a parameter using the fullname
   Value = localGetStringValue(this,Variable);
   processed = true;
end
if isa(Variable,'modelpack.STStateID') || ...
      isa(Variable,'modelpack.StateValue')
   %Want to get a state value
   Value = localGetStateValue(Variable);
   processed = true;
end
if isa(Variable,'modelpack.STParameterID') || ...
      isa(Variable,'modelpack.ParameterValue') || ...
      isa(Variable,'modelpack.ParameterSpec')
   %Want to get a parameter value
   Value = localGetParameterValue(this,Variable);
   processed = true;
end

if ~processed
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Variable', ...
      'string, modelpack.STParameterID, or modelpack.STStateID');
end

%--------------------------------------------------------------------------
function Val = localGetParameterValue(this,VarID)
%Local sub-function to return a parameter value

TunedBlocks = this.Model.C;
Val = [];
for ct = 1:numel(VarID)
   %Check whether we have a Spec object, if so extract ID object
   Format = [];  %Some parameters have a format option
   if isa(VarID(ct),'modelpack.ParameterSpec')
      if isa(VarID(ct).getID,'modelpack.STParameterID')
         if isa(VarID(ct),'modelpack.STParameterSpec')
            %Want parameter value in specific format
            Format = VarID(ct).Format;
         end
         VarID(ct) = VarID(ct).getID;
      else
         ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Variable',...
            'modelpack.STParameterID or modelpack.STParameterSpec');
      end
   end
   %Find TunedBlock that uses this parameter
   Path = VarID(ct).getPath;
   idx = strcmp(get(TunedBlocks,'Identifier'),Path);
   if any(idx)
      %Found tuned block with this parameter, now find correct parameter and 
      %get value
      found = false;
      TB = TunedBlocks(idx);
      if ~isempty(TB.getMaskParameterSpec)
         allPSpec = TB.getMaskParameterSpec.getID;  
         if iscell(allPSpec), allPSpec = [allPSpec{:}]; end
         idx = 1;
         while ~found && idx <= numel(allPSpec)
            found = VarID(ct).isSame(allPSpec(idx));
            if ~found, idx = idx + 1; end
         end
         if found
            %Match spec index to tunable parameter index
            idxTunable = cumsum(strcmp({TB.Parameters.Tunable},'on'));
            idxTBParam = find(idxTunable >= idx,1,'first');
            %Have index into parameters, get value
            Value = TB.Parameters(idxTBParam).Value;
         end
      end
      if ~found
         ZPKSpecs = TB.getZPKParameterSpec;
         if ZPKSpecs.GainSpec.getID.isSame(VarID(ct))
            %PZgroup gain parameter
            found = true;
            if isempty(Format), Format = 1; end
            Value = TB.getGainValue(Format);
         end
         if ~found && ~isempty(ZPKSpecs.PZGroupSpec)
            %Check PZgroups for parameter
            allPSpec = ZPKSpecs.PZGroupSpec;
            pID = allPSpec.getID;
            if iscell(pID), pID = [pID{:}]; end
            idx = 1;
            while ~found && idx <= numel(pID)
               found = VarID(ct).isSame(pID(idx));
               if ~found, idx = idx + 1; end
            end
            if found
               if isempty(Format);
                  Format = allPSpec(idx).Format;
               end
               Value = TB.PZGroup(idx).getValue(Format);
            end
         end
      end
      %Now find correct index into model API parameter list, set value
      %object and return
      if found
         if isempty(Format), Format = 1; end
         %Need to create a parameter value object
         ParaValue = modelpack.STParameterValue(VarID(ct));
         ParaValue.Value  = Value;
         ParaValue.Format = Format;
         Val = [Val; ParaValue]; %#ok<AGROW>
      end
   end
end

%--------------------------------------------------------------------------
function Val = localGetStateValue(VarID)
%Local sub-function to return a state value, note that for SISOTOOL all
%state values are column zeros

Val = [];
for ct = 1:numel(VarID)
   if isa(VarID(ct),'modelpack.StateSpec') 
      if isa(VarID(ct).getID,'modelpack.STStateID')
         VarID(ct) = VarID(ct).getID;
      else
         ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Variable', ...
            'modelpack.STStateID or StateSpec')
      end
   end
   Val = [Val; modelpack.StateValue(VarID(ct),[])]; %#ok<AGROW>
end

%--------------------------------------------------------------------------
function Val = localGetStringValue(this,VarName)
%Local sub-function to return a variable value based on a variable
%fullname. An exact match is used when looking for the variable name

Val = [];
idx = strcmp(this.Parameters.getFullName,VarName);
if any(idx)
   %Looking for a parameter value
   Val = localGetParameterValue(this,this.Parameters(idx));
else
   idx = strcmp(this.States.getFullName,VarName);
   if any(idx)
      %Looking for a state value
      Val = localGetStateValue(this.States(idx));
   end
end

if isempty(Val)
   ctrlMsgUtils.error('SLControllib:modelpack:errParameterNotFound',VarName);
end