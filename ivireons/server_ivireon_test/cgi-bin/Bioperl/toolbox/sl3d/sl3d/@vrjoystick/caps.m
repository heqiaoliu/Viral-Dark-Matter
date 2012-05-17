function c = caps(joy)
%CAPS Return joystick capabilities.
%   C = CAPS(JOY) returns joystick capabilities, such as number of axes,
%   number of buttons, number of POVs, and number of force-feedback axes.
%   The return value is a structure with fields named Axes, Buttons, POVs,
%   and Forces.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:26 $ $Author: batserve $

% convert internal representation to joystick capabilities structure
cp = [ {'Axes', 'Buttons', 'POVs', 'Forces'}; num2cell(double(joy.PrivateIWork(1:4))) ];
c = struct(cp{:});
