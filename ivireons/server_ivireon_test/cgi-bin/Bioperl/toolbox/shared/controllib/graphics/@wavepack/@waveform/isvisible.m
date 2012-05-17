function boo = isvisible(this)
%ISVISIBLE  Determines effective visibility of @waveform object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:58 $
boo = strcmp(this.Visible,'on') && isvisible(this.Parent);