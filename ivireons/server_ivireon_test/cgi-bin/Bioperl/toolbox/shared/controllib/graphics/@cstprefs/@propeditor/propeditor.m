function h = propeditor(TabLabels)
%EDITDLG  Constructor for the Response Plot Property Editor.

%   Author(s): A. DiVergilio
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/12/22 18:57:41 $

%---Create class instance
h = cstprefs.propeditor;

% Build dialog
build(h,TabLabels)

