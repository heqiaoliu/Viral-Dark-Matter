function this = setName(this, name)
% SETNAME Sets the name of the parameter.

% Author(s): Alec Stothert
% Revised:
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:01:50 $

% Type checking
if ~ischar(name)
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidStringArgument', ...
                      'NAME', 'setName' );
end

if strcmp(this.getID.getName,name)
   this.Name = name;
else
   ctrlMsgUtils.error('SLControllib:modelpack:stErrorParameterSubsref')
end

this.setDimensions(this.getID.getDimensions) %Also initializes property sizes
