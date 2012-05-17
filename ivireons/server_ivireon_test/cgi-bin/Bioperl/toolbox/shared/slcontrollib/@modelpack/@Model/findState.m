function state = findState(this, varargin)
% FINDSTATE Returns the state identifier objects specified by
% their (partial) full name.
%
% +findState(fullname : string) : StateID[0..*]  % All matching states
%
% STATENAME is the (partial) full name of the state.
%
% STATE is an array of matching STATEID objects or EMPTY if a state
% cannot be found.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/09/30 00:23:09 $

state = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
