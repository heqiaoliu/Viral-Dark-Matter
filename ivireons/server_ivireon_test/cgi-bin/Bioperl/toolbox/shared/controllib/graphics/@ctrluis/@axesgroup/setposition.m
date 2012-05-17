function setposition(this,varargin)
%SETPOSITION   Sets axes group position.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:39 $

% Default implementation: delegate to @plotarray object
this.Axes.setposition(this.Position);
messagepanepos(this)