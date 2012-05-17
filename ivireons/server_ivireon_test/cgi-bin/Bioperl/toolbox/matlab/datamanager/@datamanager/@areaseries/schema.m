function schema
% Defines properties for @lineseries

% Register class 
p = findpackage('datamanager');
c = schema.class(p,'areaseries',findclass(p,'lineseries'));

