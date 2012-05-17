function port = findLinearizationIO(this, varargin)
% FINDLINEARIZATIONIO Finds the specified linearization port identifier
% object(s).
%
% port = this.findLinearizationIO('portname')
%
% PORTNAME is the relative or absolute full name of the linearization port.
% Partial name matching is also supported.
%
% PORT is an array of matching LINEARIZATIONIO objects or EMPTY if
% linearization port cannot be found.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:58 $

port = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
