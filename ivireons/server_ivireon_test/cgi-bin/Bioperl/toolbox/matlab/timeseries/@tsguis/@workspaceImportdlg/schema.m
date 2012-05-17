function schema
% SCHEMA Defines properties for @workspaceImportdlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:45:20 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'workspaceImportdlg',findclass(p,'abstractTSIOdlg'));

%% Public properties

%% Parameters for determine the positions of all the GUI components 
p = schema.prop(c,'IOData','MATLAB array');
