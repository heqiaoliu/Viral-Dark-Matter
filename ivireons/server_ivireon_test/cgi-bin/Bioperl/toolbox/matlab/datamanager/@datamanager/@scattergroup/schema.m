function schema
% Defines properties for @scattergroup


% Register class 
p = findpackage('datamanager');
c = schema.class(p,'scattergroup',findclass(p,'series'));

