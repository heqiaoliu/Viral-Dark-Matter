function varargout = singleton(varargin)
%SINGLETON Singleton filter virtual class.
%   SINGLETON is a virtual class---it is never intended to be instantiated.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2007/12/14 15:09:47 $

msg = sprintf('SINGLETON is not a filter structure.');
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end
