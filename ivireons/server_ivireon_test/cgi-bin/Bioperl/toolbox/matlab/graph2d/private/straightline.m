function h = straightline(fun, varargin)
% STRAIGHTLINE  Creates a line from a function evaluated at just 2 points.

% fun must return a vector y = f(x) for vector valued x

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.3.4.3 $  $Date: 2010/03/31 18:23:56 $

if nargin < 1
    error('MATLAB:straightline:NeedsMoreArgs','STRAIGHTLINE requires at least one argument.');
end

if feature('HGUsingMATLABClasses')
    h = specgraphhelper('createFunctionLineUsingMATLABClasses',...
        'Function',fun, varargin{:});
else
    h = graph2d.functionline(fun, varargin{:});
end
h.Granularity = 2;