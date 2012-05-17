function varargout = thispsd(this,x,varargin)
%THISPSD   Power Spectral Density (PSD) estimate.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $Date: 2007/12/14 15:14:23 $

error(generatemsgid('InternalError'),'PSD method needs to be overloaded.');

% [EOF]
