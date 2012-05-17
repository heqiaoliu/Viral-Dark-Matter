function ports = getLinearizationIOs(this, varargin)
% GETLINEARIZATIONIOS Returns the selected linearization port identifier
% objects.
%
% ports = this.getLinearizationIOs
% ports = this.getLinearizationIO(indices)
%
% PORTS is an array of LINEARIZATIONIO objects or EMPTY if there are no
% linearization ports.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:38:06 $

ports = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
