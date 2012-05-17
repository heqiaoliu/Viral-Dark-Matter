function [varargout] = subsasgn(varargin)
%SUBSASGN Subscripted reference for a gmdistribution object.
%   Subscript assignment is not allowed for a gmdistribution object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:20:33 $

error('stats:gmdistribution:subsasgn:NotAllowed',...
      'Subscripted assignments are not allowed.')