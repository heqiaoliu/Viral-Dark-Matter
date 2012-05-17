function display(this)
% DISPLAY Formatted display of object properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:28 $

str = sprintf('\nState Specification Objects: \n----------------------------');

for ct = 1:numel(this)
  h = this(ct);

  name  = modelpack.strdisp( h.Name );
  value = h.InitialValue;

  str = sprintf( '%s\n(%d) State ''%s'' has the following properties:', ...
                 str, ct, name );
  str = sprintf( '%s\n       Dimensions: %s', str, mat2str(size(value)) );
  str = sprintf( '%s\n    Initial Value: %s', str, LocalMat2Str(value, 4) );

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
