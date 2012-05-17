function this = setName(this, name)
% SETNAME Sets the name of the parameter.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 15:01:37 $

% Type checking
if ~ischar(name)
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidStringArgument', ...
                      'NAME', 'setName' );
end

% Check name matches parameterID name
var = modelpack.varnames(name);
if ~strcmp(this.getID.getName,var)
   ctrlMsgUtils.error('SLControllib:modelpack:IncompatibleSpecName',this.getID.getName);
end

this.Name  = modelpack.utCheckVariableSubsref(this.getID, name);
if strcmp(this.Name,this.getID.getName)
   %Value for a Parameter ID object, dimension must match parameter ID and 
   %is not editable
   this.isDimensionEditable = true;
   this.setDimensions(this.getID.getDimensions) %Also initializes property sizes
   this.isDimensionEditable = false;
else
   %Clear dimensions
   this.isDimensionEditable = true;
   this.setDimensions([0 0]);
end