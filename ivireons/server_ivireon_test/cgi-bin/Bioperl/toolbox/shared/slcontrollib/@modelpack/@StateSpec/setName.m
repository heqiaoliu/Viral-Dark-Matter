function this = setName(this, name)
% SETNAME Sets the name of the state.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2006-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/11/09 21:01:30 $

% Type checking
if ~ischar(name)
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidStringArgument', ...
                      'NAME', 'setName' );
end

this.Name         = modelpack.utCheckVariableSubsref(this.getID, name);
this.InitialValue = 0;
this.Known        = true;
this.SteadyState  = true;
this.Minimum      = -Inf;
this.Maximum      = +Inf;
this.TypicalValue = 0;
