function schema
% Defines properties for @mergedlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2005/11/27 22:42:56 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'preprocdlg',findclass(p,'viewdlg'));

%% Enumerations
if isempty(findtype('detrend'))
    schema.EnumType('detrend', {'constant','linear'});
end
if isempty(findtype('filtertype'))
    schema.EnumType('filtertype', {'ideal','transfer','firstord'});
end
if isempty(findtype('filterband'))
    schema.EnumType('filterband', {'pass','stop'});
end

%% Public properties

%% Removal attributes
p = schema.prop(c, 'Rowor', 'on/off');
p.FactoryValue = 'off';

%% Interpolation attributes
schema.prop(c, 'InterptsPath', 'string');

%% Filter attributes
p = schema.prop(c, 'Detrendtype', 'detrend');
p.FactoryValue = 'constant';
p = schema.prop(c, 'Filter', 'filtertype');
p.FactoryValue = 'firstord';
p = schema.prop(c, 'Band', 'filterband');
p.FactoryValue = 'pass';
p = schema.prop(c, 'Range', 'MATLAB array');
p.Description = 'frequency range';
p.FactoryValue = [0 0.1];
p = schema.prop(c, 'Acoeffs', 'MATLAB array');
p.FactoryValue = [1 -0.5];
p.Description = 'numerator coefficients';
p = schema.prop(c, 'Bcoeffs', 'MATLAB array');
p.FactoryValue = 1;
p.Description = 'denominator coefficients';
p = schema.prop(c, 'Timeconst', 'double');
p.Description = 'time constant';
p.FactoryValue = 10;
schema.prop(c, 'UndoButtons', 'MATLAB array');

