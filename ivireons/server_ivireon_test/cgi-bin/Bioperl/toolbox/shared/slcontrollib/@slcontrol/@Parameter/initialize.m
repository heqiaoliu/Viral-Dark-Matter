function initialize(this, name, varargin)
% INITIALIZE Initialize object properties
%
% NAME is a Simulink block name or handle.
% VARARGIN Parameter value if supplied.

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/09 21:02:14 $

% Check parameter name
if ~ischar(name)
  ctrlMsgUtils.error( 'SLControllib:general:InvalidArgument', ...
                      'NAME', 'initialize', 'slcontrol.Parameter.initialize' );
end

% Try to get value from the workspace.
if ~isempty(varargin) && isnumeric( varargin{1} )
   value = varargin{1};
else
   try
      value = evalin('base', name);
   catch
     ctrlMsgUtils.error( 'SLControllib:slcontrol:VariableNotInWorkspace', name );
   end
end

% Value from workspace might not be numeric
if ~isnumeric(value)
  ctrlMsgUtils.error( 'SLControllib:slcontrol:VariableNotNumeric', name );
end

% Set properties
this.Name       = name;
this.Dimensions = size(value);

% Set dependent properties
this.Value        = value;
this.InitialGuess = value;
this.Minimum      = -Inf * ones( this.Dimensions );
this.Maximum      = +Inf * ones( this.Dimensions );
this.TypicalValue = value;
