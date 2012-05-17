function [varargout] = subsasgn(varargin)
%SUBSASGN Subscripted reference for a NaiveBayes object.
%   Subscript assignment is not allowed for a NaiveBayes object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:18:54 $

error('stats:NaiveBayes:subsasgn:NotAllowed',...
      'The NaiveBayes class does not support subscripted assignments.')