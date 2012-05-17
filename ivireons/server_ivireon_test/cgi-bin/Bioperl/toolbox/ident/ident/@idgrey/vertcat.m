function varargout = vertcat(varargin)
%VERTCAT  Vertical concatenation of IDMODEL models.
%
%   MOD = VERTCAT(MOD1,MOD2,...) performs the concatenation
%   operation
%         MOD = [MOD1 ; MOD2 , ...]
%
%   This operation amounts to appending  the outputs of the
%   IDMODEL objects MOD1, MOD2,... and feeding all these models
%   with the same input vector.
%
%   See also HORZCAT.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.4.2.4 $  $Date: 2008/10/02 18:47:49 $

ctrlMsgUtils.error('Ident:combination:idgreyConcat')

