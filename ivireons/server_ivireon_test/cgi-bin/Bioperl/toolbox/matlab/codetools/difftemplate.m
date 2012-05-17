function str = difftemplate
%DIFFTEMPLATE Returns an HTML template for displaying reports
% 
% str = difftemplate
%
% The template should be used with the Java MessageFormat class,
% and takes two format arguments: the contents of the <title>
% and <body> tags.

% Copyright 2007 The MathWorks, Inc.

str = makeheadhtml;
str = [ str '<title>{0}</title></head><body>{1}</body></html>' ];


