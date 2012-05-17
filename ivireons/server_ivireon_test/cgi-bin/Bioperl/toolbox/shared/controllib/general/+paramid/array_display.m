function array_display(objs, name)
%

% ARRAY_DISPLAY display properties of an array of objects with given NAME.
%
% paramid.array_display(objs, [name])
%
% h = param.Continuous('a', 5);
% paramid.array_display( [h h], 'P' )
%
% P(1,1) =
%
%   Name: 'a'
%  Value: 5
%
%
% P(1,2) =
%
%   Name: 'a'
%  Value: 5
%
%
% 1x2 param.Continuous
%

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:01 $

% Default name argument.
if (nargin < 2), name = ''; end

n = numel(objs);
if n > 0
   indices = paramid.array_indices( size(objs) );
end

if isequal(get(0, 'FormatSpacing'), 'compact')
   spc = '';
else
   spc = ' ';
end
disp(spc)

%Display property values. Three cases to handle, objs is empty, objs is
%scalar, objs is array (possibly multi-dimensional)
if n == 1
   % Display variable name
   if ~isempty(name)
      fprintf('%s =\n',name)
      disp(spc)
   end
   %Avoid invoking subsref on scalar objects
   localDisplayPropValues(objs,spc);
elseif n > 1
   for j = 1:n
      % Display array name and current index.
      coord = sprintf('%d,', indices(j,:));
      fprintf('%s(%s) =\n', name, coord(1:end-1))
      disp(spc)
      % Display property values.
      localDisplayPropValues(objs(j),spc)
   end
end

% Display class name and array size.
str = sprintf( '<a href="matlab:doc %s">%s</a>', class(objs), class(objs) );
% Prepend array size string
str = sprintf('%s %s', regexprep(num2str(size(objs)),' *','x'), str);
disp(str)
disp(spc)

% Display class information
cls = class(objs);
str = '';
k = 0;
% Methods
if ~isempty( methods(cls) )
   str = sprintf( '<a href="matlab:methods(''%s'')">methods</a>', cls );
   k = k + 1;
end
% Superclasses
if ~isempty( superclasses(cls) )
   if ~isempty(str)
      str = [str ','];
   end
   str = sprintf( '%s <a href="matlab:superclasses(''%s'')">superclasses</a>', str, cls );
   k = k + 1;
end
% Events
if ~isempty( events(cls) )
   if ~isempty(str)
      str = [str ','];
   end
   str = sprintf( '%s <a href="matlab:events(''%s'')">events</a>', str, cls );
   k = k + 1;
end
% Single or multiple lists.
if k == 1
   fprintf('list of %s\n', str);
   disp(spc)
elseif k > 1
   fprintf('lists of %s\n', str);
   disp(spc)
end
end

function localDisplayPropValues(h,spc)
% Helper function to display property values of a single object
%

allProps = properties(h);
numProps = length(allProps);
s = cell2struct(cell(numProps,1), allProps, 1);
for ct = 1:numProps
   s.(allProps{ct}) = h.(allProps{ct});
end
disp(s)
disp(spc)
end