function this = idminimizer(aModel, aData, varargin)
%UDMINIMIZER  Constructor.

% Author(s): Bora Eryilmaz
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2007/12/14 14:47:02 $

% Create object.
this = idestimatorpack.idminimizer;

if nargin>0
    % Initialize object.
    this.initialize(aModel, aData, varargin{:});
end