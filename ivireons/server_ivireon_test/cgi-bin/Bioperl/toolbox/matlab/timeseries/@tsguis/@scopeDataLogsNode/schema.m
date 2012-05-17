function schema
% Defines properties for @scopeDataLogsNode class.
%
%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:59:16 $


%% Register class (subclass)
p = findpackage('tsguis');
c = schema.class(p, 'scopeDataLogsNode', findclass(p,'modelDataLogsNode'));

