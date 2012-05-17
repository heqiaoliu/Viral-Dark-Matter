function show(arg, varargin)
%SHOW     Bring all open specified scope instances to the foreground.
%   SHOW(name) brings the specified scope instance to the foreground,
%   moving it in front of other MATLAB windows as appropriate.
%
%   SHOW(name, 'all') moves all specified scope instances forward.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/14 04:06:32 $

if nargin<1
    m = uiscopes.find(0);  % current/most recent instance only
else
   if ~strcmpi(arg,'all')
       error(generatemsgid('InvalidArgs'),...
           'Argument must be ''all''.');
   end
   m = uiscopes.find(varargin{:});  % all instances
end

% Bring each instance forward
for i=numel(m):-1:1
    m(i).show;
end

% [EOF]
