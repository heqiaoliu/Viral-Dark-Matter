function varargout = multistage(varargin)
%MULTISTAGE   Multistage filter virtual class.
%   MULTISTAGE is a virtual class---it is never intended to be instantiated.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:09:26 $

error(generatemsgid('DFILTErr'),'MULTISTAGE is not a filter structure.');
