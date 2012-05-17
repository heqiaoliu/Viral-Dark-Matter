function schema
% Defines properties for @mergedlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:56:56 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'datamergedlg',findclass(p,'mergedlg'));

