function tsDispatchTableCallback(varargin)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

%% Parse the function args
col = varargin{nargin};
row = varargin{nargin-1};
thisModel = varargin{nargin-2};
fcnH = varargin{1};
numargs = varargin{2};

%% Assemble the array of objects to be passed to the specified function
inargs = cell(1,numargs);
if size(varargin,1)>1 % Force a row
    varargin = varargin';
end
allargs = [varargin(3:nargin-3),{row,col,thisModel}];
for k=1:numargs
   inargs{k} = allargs{k};
end
feval(fcnH,inargs{:});



