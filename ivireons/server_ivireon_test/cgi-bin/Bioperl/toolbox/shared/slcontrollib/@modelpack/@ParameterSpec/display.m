function display(this)
% DISPLAY Formatted display of object properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/12/14 15:01:26 $

str = sprintf('\nParameter Specification Objects:\n--------------------------------');

for ct = 1:numel(this)
  h = this(ct);

  name = modelpack.strdisp( h.Name );
  id   = h.getID;
  if ~isempty(id) && ~isempty(id.getPath)
    str = sprintf( '%s\n(%d) Parameter ''%s'' in ''%s'':', ...
                   str, ct, name, id.getPath );
  else
    str = sprintf( '%s\n(%d) Parameter ''%s'':', str, ct, name );
  end

  str = sprintf( '%s\n    Initial Value: %s', str, LocalMat2Str(h.InitialValue, 4) );
  
  str = sprintf( '%s\n    Minimum Value: %s', str, LocalMat2Str(h.Minimum, 4) );
  str = sprintf( '%s\n    Maximum Value: %s', str, LocalMat2Str(h.Maximum, 4) );

  if length(h.Known) > 1
    str = sprintf( '%s\n   Known elements: %s', str, LocalMat2Str(h.Known, 4) );
  else
    str = sprintf( '%s\n            Known: %s', str, LocalMat2Str(h.Known, 4) );
  end

  str = sprintf('%s\n', str);
end

disp(str)

% --------------------------------------------------------------------------
function str = LocalMat2Str(value, N)
try
  str = mat2str(value, N);
catch
  s1  = regexprep( num2str(size(value)), ' *', 'x' );
  str = sprintf('[%s %s]', s1, class(value));
end
