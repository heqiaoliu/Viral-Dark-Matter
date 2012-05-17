function schema
%  SCHEMA  Defines properties for @bodeview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:31 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'bodeview', superclass);

% Class attributes
schema.prop(c, 'MagCurves', 'MATLAB array');          % Handles of HG lines for mag axes
schema.prop(c, 'MagNyquistLines', 'MATLAB array');    % Handles of Nyquist lines for mag axes
schema.prop(c, 'PhaseCurves', 'MATLAB array');        % Handles of HG lines for phase axes
schema.prop(c, 'PhaseNyquistLines', 'MATLAB array');  % Handles of Nyquist lines for phase axes
schema.prop(c, 'UnwrapPhase', 'on/off');              % Phase wrapping
p = schema.prop(c, 'ComparePhase', 'MATLAB array');   % Phase matching
p.FactoryValue = struct(...
   'Enable', 'off',...
   'Freq', 0, ...
   'Phase', 0);    


 