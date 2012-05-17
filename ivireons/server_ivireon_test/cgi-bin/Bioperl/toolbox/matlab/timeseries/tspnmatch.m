function [Property,imatch] = tspnmatch(Name,PropList,nchars)
%
% timeseries utility function

%   Copyright 2005-2007 The MathWorks, Inc.

if ~ischar(Name) || size(Name,1)>1,
   error('tspnmatch:invPropStr','Property names must be single-line strings.')
end

% Set number of characters used for name comparison
if nargin==2,
   nchars = length(Name);
else
   nchars = min(nchars,length(Name));
end

% Find all matches
imatch = find(strncmpi(Name,PropList,nchars));

% Get matching property name
switch length(imatch)
case 1
   % Single hit
   Property = PropList{imatch};
   
case 0
   % No hit
   error('tspnmatch:invPropName','Invalid property name ''%s''',Name)
   
otherwise
   % Multiple hits. Take shortest match provided it is contained
   % in all other matches (Xlim and XlimMode as matches is OK, but 
   % InputName and InputGroup is ambiguous)
   [minlength,imin] = min(cellfun('length',PropList(imatch)));
   Property = PropList{imatch(imin)};
   if ~all(strncmpi(Property,PropList(imatch),minlength)),
      error('tspnmatch:ambPropName',...
          'Ambiguous property name ''%s''. Supply more characters.',Name)
   end
   imatch = imatch(imin);
end
