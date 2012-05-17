function varargout = bodeplot(varargin)
%BODEPLOT Plots the Bode diagram of a transfer function or spectrum.
%   OBSOLETE function. Use BODE instead. See help on IDMODEL/BODE.
 
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $ $Date: 2009/10/16 04:56:26 $

if nargout == 0
   bodeaux(1,varargin{:});
else
   [varargout{1:nargout}] = bodeaux(1,varargin{:});
end 