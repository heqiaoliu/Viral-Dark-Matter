function initialize(this,Axes)
%INITIALIZE  Initializes @rlview objects.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:56 $

% Pole ands zeros
this.SystemZero = handle(line('XData', NaN, 'YData', NaN, ...
   'Parent',  Axes, 'Visible', 'off',...
   'LineStyle','none','Marker','o'));
this.SystemPole = handle(line('XData', NaN, 'YData', NaN, ...
   'Parent',  Axes, 'Visible', 'off',...
   'LineStyle','none','Marker','x'));

% Create locus curves
% RE: Create only one upfront (number will vary with data)
this.Locus = handle(line('XData', NaN, 'YData', NaN, ...
   'Parent',  Axes, 'Visible', 'off'));
