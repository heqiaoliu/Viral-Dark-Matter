function schema
% Defines properties for @stateflowDataLogsNode class.
%
%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:00:46 $


%% Register class (subclass)
p = findpackage('tsguis');
c = schema.class(p, 'stateflowDataLogsNode', findclass(p,'modelDataLogsNode'));

