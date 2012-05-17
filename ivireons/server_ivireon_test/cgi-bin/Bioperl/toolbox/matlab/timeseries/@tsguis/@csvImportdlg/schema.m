function schema
% SCHEMA Defines properties for @excelImportdlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/15 20:55:57 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'csvImportdlg',findclass(p,'excelImportdlg'));


