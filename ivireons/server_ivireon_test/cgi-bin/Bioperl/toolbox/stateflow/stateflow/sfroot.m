function [sfRoot] = sfroot
%SFROOT Returns the Stateflow Root object.
%   [SFROOT] = SFROOT 
%   Returns the one-and-only Stateflow Root object.
%
%   See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFCLIPBOARD, SFHELP.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.4 $

% Simulink Root object behaves just like Stateflow Root.  Use that instead
sfRoot = slroot;
