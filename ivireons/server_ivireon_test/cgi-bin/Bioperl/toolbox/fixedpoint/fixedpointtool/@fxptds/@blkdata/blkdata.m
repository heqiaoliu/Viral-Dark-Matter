function this = blkdata(blk, varargin)
%QRDATA   constructor

%   Author(s): G. Taillefer
%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:48:47 $

pathitem = '';
if(nargin > 1)
  pathitem = varargin{1};
end
this = fxptds.blkdata;
this.daobject = blk;
this.pathitem = pathitem;

% [EOF]