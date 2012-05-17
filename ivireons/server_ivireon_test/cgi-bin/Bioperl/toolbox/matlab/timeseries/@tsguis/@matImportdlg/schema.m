function schema
% SCHEMA Defines properties for @matImportdlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:39:27 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'matImportdlg',findclass(p,'abstractTSIOdlg'));

%% Public properties

%% Parameters for determine the positions of all the GUI components 
p = schema.prop(c,'IOData','MATLAB array');
