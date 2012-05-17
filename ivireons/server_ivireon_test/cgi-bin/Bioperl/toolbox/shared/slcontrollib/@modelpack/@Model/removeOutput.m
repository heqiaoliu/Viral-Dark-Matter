function removeOutput(this, varargin)
% REMOVEOUTPUT Removes the specified output ports from the model.
%
% this.removeOutput                    (removes all output ports.)
% this.removeOutput(hOut)
% this.removeOutput(indices)
% this.removeOutput(name)
%
% HOUT is an array of PORTID objects to be removed from the model.
% NAME is the relative or absolute full name of the output to be removed.
%
% A warning is thrown if the specified port(s) do not exist.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:38:16 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
