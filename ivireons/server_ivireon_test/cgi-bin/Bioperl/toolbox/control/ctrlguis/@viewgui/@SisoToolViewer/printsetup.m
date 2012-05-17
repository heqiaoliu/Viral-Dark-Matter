function printsetup(this,prop,value)
% PRINTSETUP sets the visibility specified in 'value' to the HG objects in
% the Object 'this'
%   Author: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2005/12/22 17:44:28 $

hg = this.HG;
set([hg.StatusSeparator;hg.StatusText;hg.StatusCheckBox],prop,value);
this.HG = hg;
