function input = findInput(this, varargin)
% FINDINPUT Returns the input port identifier objects specified by
% their (partial) full name.
%
% +findInput(fullname : string) : PortID[0..*]  % All matching inputs
%
% FULLNAME is the (partial) full name of the input port.
%
% INPUT is an array of matching PORTID objects or EMPTY if an input port
% cannot be found.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/09/30 00:23:05 $

input = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
