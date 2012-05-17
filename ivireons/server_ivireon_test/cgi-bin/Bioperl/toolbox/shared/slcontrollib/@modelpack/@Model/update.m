function this = update(this, varargin)
% UPDATE Synchronizes THIS when the underlying model changes.  Updates all
% model properties when requested by a client.
%
% this = update(this, ...)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2005/12/22 18:53:41 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
