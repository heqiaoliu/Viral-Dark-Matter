function show(this)
%SHOW Show the import dialog

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:27 $

%this.Frame.pack;
%this.Frame.setVisible(true);
awtinvoke(this.Frame,'pack');
awtinvoke(this.Frame,'setVisible(Z)',true);