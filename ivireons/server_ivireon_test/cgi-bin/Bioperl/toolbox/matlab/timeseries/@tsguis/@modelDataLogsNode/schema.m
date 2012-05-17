function schema
% Defines properties for @tsnode class.
%
%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:15:43 $


%% Register class (subclass)
p = findpackage('tsguis');
c = schema.class(p, 'modelDataLogsNode', findclass(p,'simulinkTsParentNode'));

schema.prop(c,'SimModelhandle','handle');

