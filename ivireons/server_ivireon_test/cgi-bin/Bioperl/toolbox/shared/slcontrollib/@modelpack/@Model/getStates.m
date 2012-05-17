function states = getStates(this, varargin)
% GETSTATES Returns all or specified state information.
%
% +getStates() : StateID[0..*]                     % All states
% +getStates(indices : int[1..n]) : StateID[1..n]  % Selected states

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2006/09/30 00:23:16 $

states = [];

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
