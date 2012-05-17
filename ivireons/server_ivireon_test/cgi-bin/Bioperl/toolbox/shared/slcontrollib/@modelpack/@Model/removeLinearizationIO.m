function removeLinearizationIO(this, varargin)
% REMOVELINEARIZATIONIO Removes the specified linearization I/Os from the model.
%
% this.removeLinearizationIO           (removes all linearization I/Os.)
% this.removeLinearizationIO(hLin)
% this.removeLinearizationIO(indices)
% this.removeLinearizationIO(name)
%
% HLIN is an array of LINEARIZATIONIO objects to be removed from the model.
% NAME is the relative or absolute full name of the lin. I/O to be removed.
%
% A warning is thrown if the specified port(s) do not exist.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:38:15 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
