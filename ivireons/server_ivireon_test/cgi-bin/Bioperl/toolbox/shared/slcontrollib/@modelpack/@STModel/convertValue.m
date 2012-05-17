function convertValue(this,Var,newFormat) 
% CONVERTVALUE  STModel object method to convert a parameter value from one
% format to another
%
% Var = this.convertValue(Var,newFormat)
%
% Inputs:
%   Var       - a modelpack.STParameterSpec or modelpack.ParameterValue
%               object to convert
%   newFormat - a numerical index or string giving the new parameter format,
%               valid formats can be found from the 'FormatOptions' property, i.e.,
%               this.FormatOptions
%
 
% Author(s): A. Stothert 29-Aug-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/09/18 02:28:09 $

TunedBlocks = this.Model.C;
varID       = Var.getID;
Path        = varID.getPath;
idx         = strcmp(get(TunedBlocks,'Identifier'),Path);
if ischar(newFormat) && isa(Var,'modelpack.STParameterSpec')
   newFormat = find(strcmp(newFormat,Var.FormatOptions));
   if isempty(newFormat), newFormat = inf; end
end
if ~isnumeric(newFormat) && isa(Var,'modelpack.ParameterSpec')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','newFormat','numeric index')
end
if any(idx) 
   %Found tuned block with this parameter, now find correct parameter and
   %Update min, max, etc. to match new format
   TB       = TunedBlocks(idx);
   ZPKSpecs = TB.getZPKParameterSpec;
   allPSpec = [ZPKSpecs.GainSpec; ZPKSpecs.PZGroupSpec];
   pID      = allPSpec.getID;
   if iscell(pID), pID = [pID{:}]; end
   found = false; idx = 1;
   while ~found && idx <= numel(pID)
      found = varID.isSame(pID(idx));
      if ~found, idx = idx + 1; end
   end
   if found && isa(Var,'modelpack.STParameterSpec')
      if idx==1
         %Gain parameter
         Var.setFormat(TB,newFormat);
      else
         Var.setFormat(TB.PZGroup(idx-1),newFormat)
      end
   end
   if found && isa(Var,'modelpack.ParameterValue')
      if idx==1
         %Gain parameter
         Var.Value = TB.getGainValue(newFormat);
      else
         Var.Value = TB.PZGroup(idx).getValue(newFormat);
      end
   end
   if ~found
      %Did not find matching parameter value
      ctrlMsgUtils.error('SLControllib:modelpack:stErrorParameterNotFoundConvert',varID.getFullName)
   end
else
   %Found no compensator with matching name that contains requested parameter
   ctrlMsgUtils.error('SLControllib:modelpack:stErrorParameterNotFoundConvert',varID.getFullName)
end