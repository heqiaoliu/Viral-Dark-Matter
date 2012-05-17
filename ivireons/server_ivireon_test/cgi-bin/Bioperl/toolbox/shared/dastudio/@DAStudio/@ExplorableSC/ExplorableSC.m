function this = ExplorableSC(target)
% Copyright 2004-2008 The MathWorks, Inc.

%% error checking

% supply default argument if necessary.
% MATLAB catches case of too many arguments.

if nargin == 0
    target = DAStudio.Object;
end

if ~isa(target, 'DAStudio.Object')
    error('DAStudio:ExplorableSC:DAStudioObjectRequired', 'Input argument must be a subclass of DAStudio.Object');
end

%% creation
this = DAStudio.ExplorableSC(target);
