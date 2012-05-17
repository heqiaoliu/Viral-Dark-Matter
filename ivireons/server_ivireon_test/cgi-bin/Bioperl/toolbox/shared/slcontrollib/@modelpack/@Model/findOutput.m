function output = findOutput(this, varargin)
% FINDOUTPUT Returns the output port identifier objects specified by
% their (partial) full name.
%
% +findOutput(fullname : string) : PortID[0..*]  % All matching outputs
%
% FULLNAME is the (partial) full name of the output port.
%
% OUTPUT is an array of matching PORTID objects or EMPTY if an output port
% cannot be found.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/09/30 00:23:06 $

output = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
