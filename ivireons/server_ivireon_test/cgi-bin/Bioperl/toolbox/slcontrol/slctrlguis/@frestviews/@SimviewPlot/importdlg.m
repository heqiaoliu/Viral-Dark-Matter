function h = importdlg(this)
%IMPORTDLG  Builds the import dialog for simview plot.

%   Author(s): Erman Korkut 01-Jul-2009
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:19:25 $


% Build import dialog
h = frestviews.ImportDialog(this);

% Center dialog
centerfig(h.Handles.Figure,this.Figure);
