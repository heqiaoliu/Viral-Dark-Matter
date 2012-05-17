function SumBlock = createsum(Identifier, Position, AxisHandle)
% ------------------------------------------------------------------------%
% Function: CreateSum
% Purpose: Creats Sum Structure
% Arguments:     
%     Identifier: Identifier of block (Identifier used in sisotool)
%       Position: Position of center of block
%     AxisHandle: Parent Axis
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.10.2 $ $Date: 2006/01/26 01:48:13 $

% Sum width = height = diameter

AxPos = get(AxisHandle, 'Position');
ar = AxPos(3)/AxPos(4); % Aspect Ratio

origunits = get(AxisHandle,'units');
set(AxisHandle,'Units','pixels');
AxPos = get(AxisHandle,'Position');
set(AxisHandle,'Units',origunits);

%AxPos = get(AxisHandle, 'Position');
% ar = AxPos(3)/AxPos(4);  % Aspect Ratio

Xlims = get(AxisHandle, 'Xlim');
Ylims = get(AxisHandle, 'Ylim');
ar = (Xlims(2)-Xlims(1))/(Ylims(2)-Ylims(1))/AxPos(4)*AxPos(3);  % Aspect Ratio

swidth = 0.05/ar; 
sheight = 0.05;
PatchColor = 'k';

x = Position(1);
y = Position(2);

a = swidth/2;
b = sheight/2;
xcoord = x + a*sin([0:2*pi/36:2*pi]);
ycoord = y + b*cos([0:2*pi/36:2*pi]);

PHandle = patch(xcoord,ycoord,PatchColor,'Parent', AxisHandle);

SumBlock = struct( ...
    'Identifier', Identifier, ...
    'Position', Position, ...
    'Width', swidth, ...
    'Height', sheight, ...
    'PatchColor',PatchColor, ...
    'PHandle', PHandle, ...  
    'THandle', [],...
    'Label', []); 



