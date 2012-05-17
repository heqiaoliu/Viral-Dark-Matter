function [Value,Dim,Locations] = getParameterData(this,TunedBlock,ParamID) 
% GETPARAMETERDATA  private method to retrieve the parameter data from the SISOTOOL
% data object.
%
% Input
%   TunedBlock - the block with the parameter
%   ParamID    - index to the tuned parameter in this block

% Author(s): A. Stothert 02-Aug-2005
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/09/15 20:47:08 $

found = false;
Value = [];
Dim   = [];
Locations = {TunedBlock.Identifier};
%Check if parameter is part of PZGroup
ZPKSpecs = TunedBlock.getZPKParameterSpec;
if ~isempty(ZPKSpecs)
   if ZPKSpecs.GainSpec.getID.isSame(ParamID)
      %Gain parameter
      found = true;
      Value = TunedBlock.getFormattedGain;
   end
   if ~found && ~isempty(ZPKSpecs.PZGroupSpec)
      pID = ZPKSpecs.PZGroupSpec.getID;
      if iscell(pID), pID = [pID{:}]; end
      idx = 1;
      while ~found && idx <= numel(pID)
         found = ParamID.isSame(pID(idx));
         if ~found, idx = idx + 1; end
      end
      if found
         %PZGroup parameter
         Format = ZPKSpecs.PZGroupSpec(idx).Format;
         Value  = TunedBlock.PZGroup(idx).getValue(Format);
         found  = true;
      end
   end
end
%Check if parameter is part of tuned mask
if ~found && ~isempty(TunedBlock.MaskParamSpec)
   idx = strcmp({TunedBlock.Parameters.Name},ParamID.getName);
   if any(idx)
      Value = TunedBlock.Parameters(idx).Value;
      found = true;
   end
end

if found
   %Set dimension 
   Dim = size(Value);
   %Check for other locations of parameter
   Model = this.Model;
   for ct = 1:numel(Model.L)
      idx = Model.L(ct).TunedLFT.Blocks == TunedBlock;
      if any(idx)
         Locations{end+1} = sprintf('%s/%s',Model.L(ct).Identifier,TunedBlock.Identifier);
      end
      idx = Model.L(ct).TunedFactors == TunedBlock;
      if any(idx)
         Locations{end+1} = sprintf('%s/%s',Model.L(ct).Identifier,TunedBlock.Identifier);
      end
   end
else
   ctrlMsgUtils.error('SLControllib:modelpack:errParameterNotFound',ParamID.getFullName);
end

