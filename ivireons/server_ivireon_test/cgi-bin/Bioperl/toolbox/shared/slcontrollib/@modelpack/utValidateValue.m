function value = utValidateValue(variable, value, delimiters)
% UTVALIDATEVALUE Checks whether the VALUE can be assigned to the VARIABLE.
%
% modelpack.utvalidatevalue(variable, value, delimiters)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/09 20:59:40 $

% Default arguments
if (nargin < 3 || isempty(delimiters)), delimiters = '.({'; end

ID = variable.getID;

if ~isempty(ID)
  % Adjust size if value is a numeric or logical array.
  if isnumeric(value) || islogical(value)
    [var, subs] = modelpack.varnames(variable.Name, delimiters);
    if isempty(subs)
      % Full variable name is used: assign value after adjusting size.
      value = modelpack.utFormatValueToSize(value, ID.getDimensions);
    else
      % An expression is used: assign value directly if assignment is valid.
      try
        eval(['tmp' subs '= value;']);
        value = eval(['tmp' subs]);
      catch
        ctrlMsgUtils.error( 'SLControllib:modelpack:CannotAssignVariable', ...
                            variable.Name );
      end
    end
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:NumericArrayArgument', ...
                        'VALUE' );
  end
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:EmptyIdentifier' );
end
