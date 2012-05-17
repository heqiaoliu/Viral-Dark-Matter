function [varargout] = subsasgn(varargin)
%SUBSASGN Subscripted reference for a CLASSREGTREE object.
%   Subscript assignment is not allowed for a CLASSREGTREE object.

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:20:06 $

error('stats:classregtree:subsasgn:NotAllowed',...
      'Subscripted assignments are not allowed.')