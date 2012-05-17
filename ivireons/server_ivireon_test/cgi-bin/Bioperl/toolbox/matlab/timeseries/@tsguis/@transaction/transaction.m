function h = transaction(varargin)
% Returns instance of @transaction class

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2006/06/27 23:11:34 $


%% Create transaction and set its tsTransaction property to capture
%% operations on the time series object. 

h = tsguis.transaction;

%% Make this transaction current
r = tsguis.recorder;
r.CurrentTransaction = h;

%% If this is a data logger transaction, do not create udd transaction
%% objects
if nargin==1 && ischar(varargin{1}) && strcmp(varargin{1},'notrans')
    return
end

% Add the handle to the affected object
if nargin==2 && iscell(varargin{2})
    h.ObjectsCell =  varargin{2};
end


