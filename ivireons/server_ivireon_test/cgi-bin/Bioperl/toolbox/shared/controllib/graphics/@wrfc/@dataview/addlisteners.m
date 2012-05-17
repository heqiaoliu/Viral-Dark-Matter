function addlisteners(this, L)
%ADDLISTENERS  Adds new listeners to listener set.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:28:55 $
this.Listeners = [this.Listeners; L];
