function setposition(this,varargin)
%SETPOSITION   Sets axes group position.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:43 $
set(this.Axes2d,'Position',this.Position)
messagepanepos(this)
