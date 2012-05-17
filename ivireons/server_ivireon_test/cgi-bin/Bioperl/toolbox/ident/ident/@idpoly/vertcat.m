function sys = vertcat(varargin)
%VERTCAT  Vertical concatenation of IDPOLY models.
%
% Vertical concatenation is not supported for IDPOLY models. This is
% because the IDPOLY object cannot represent a model with more than one
% outputs. To achieve this concatenation, convert the input models to IDSS
% (state-space) format first. That is, in place of:
% MODEL = [MODEL1; MODEL2],
% do:
% MODEL = [IDSS(MODEL1); IDSS(MODEL2)].
%
% See also HORZCAT.

%   MOD = VERTCAT(MOD1,MOD2,...) performs the concatenation
%   operation
%         MOD = [MOD1 ; MOD2 , ...]
%
%   This operation amounts to appending  the outputs of the
%   IDMODEL objects MOD1, MOD2,... and feeding all these models
%   with the same input vector.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2008/10/02 18:49:06 $

if length(varargin)>1
    ctrlMsgUtils.error('Ident:combination:vertcatIdpoly')
else
    sys = varargin{1};
end
