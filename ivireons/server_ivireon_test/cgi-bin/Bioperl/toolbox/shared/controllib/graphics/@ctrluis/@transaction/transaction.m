function h = transaction(RootObj,varargin)
% Returns instance of @transaction class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:16 $

h = ctrluis.transaction;
h.RootObjects = RootObj;

% Create transaction and set its  properties
T = handle.transaction(RootObj(1));
T.set(varargin{:});
h.Transaction = T;

% Set name
h.Name = T.Name;