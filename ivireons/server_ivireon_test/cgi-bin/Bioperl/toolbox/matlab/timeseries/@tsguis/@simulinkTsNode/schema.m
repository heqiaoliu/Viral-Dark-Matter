function schema
% Defines properties for @simulinkTsNode class. This node is a subclass of
% @tsnode. It represents the Simulink.timeseries objects in the tree panel.
%

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:16:37 $


%% Register class (subclass)
p = findpackage('tsguis');
c = schema.class(p, 'simulinkTsNode', findclass(p,'tsnode'));

