function Mask = refreshmask(this)
%REFRESHMASK  Builds visibility mask for REFRESH.
%
%  Same as WAVEPLOT/REFRESHMASK, but also takes RowIndex and 
%  ColumnIndex into account.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:04 $
Mask = refreshmask(this.Parent);
Mask = Mask(this.RowIndex,this.ColumnIndex,:,:);