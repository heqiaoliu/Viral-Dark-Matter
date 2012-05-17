function schema
% Defines properties for @stemseries

% Register class 
p = findpackage('datamanager');
c = schema.class(p,'stairseries',findclass(p,'series'));

