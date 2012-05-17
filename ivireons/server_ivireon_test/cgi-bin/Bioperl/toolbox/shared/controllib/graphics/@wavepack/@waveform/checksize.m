function boo = checksize(this,dataobj)
%CHECKSIZE  Checks data size against waveform size.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:51 $
rcsize = getsize(dataobj);
boo = all(isnan(rcsize) | rcsize==[length(this.RowIndex),length(this.ColumnIndex)]);
