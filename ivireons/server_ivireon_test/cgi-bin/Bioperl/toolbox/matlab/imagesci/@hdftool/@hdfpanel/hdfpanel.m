function this  = hdfpanel(hImportPanel)
%HDFPANEL Construct an hdfpanel.
%
%   Function arguments
%   ------------------
%   HIMPORTPANEL: the HG parent of this panel.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/15 20:14:38 $

    this = hdftool.hdfpanel;
    hdfPanelConstruct(this, hImportPanel);

end
