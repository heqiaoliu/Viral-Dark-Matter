function m = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDGREY models.
%
% Horizontal concatenation is not supported for IDGREY models. Calling this
% function would result in an error.
%
%   See also IDGREY/VERTCAT, IDGREY.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.5.2.4 $ $Date: 2008/10/02 18:47:39 $

ctrlMsgUtils.error('Ident:combination:idgreyConcat')


