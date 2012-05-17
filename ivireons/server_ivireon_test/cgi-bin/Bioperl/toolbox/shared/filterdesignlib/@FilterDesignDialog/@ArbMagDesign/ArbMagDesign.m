function this = ArbMagDesign(varargin)
%ARBMAGDESIGN   Construct an ARBMAGDESIGN object.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:24 $

this = FilterDesignDialog.ArbMagDesign;

% Setup the defaults
f = 'linspace(0, 1, 30)';
a = '[ones(1, 7) zeros(1,8) ones(1,8) zeros(1,7)]';
m = 'ones(1, 30)';
p = 'angle(exp(-12*j*pi*linspace(0, 1, 30)))';
h = 'exp(-12*j*pi*linspace(0, 1, 30))';

set(this, ...
    'OrderMode', 'specify', ...
    'VariableName', uiservices.getVariableName('Ham'), ...
    'Band1', FilterDesignDialog.ArbMagBand(f, a, m, p, h), ...
    varargin{:});

% Prepare dialog depending on license config and operating mode
setupDisabledOrEnabled(this);

set(this, 'FDesign', fdesign.arbmag(20,eval(f),eval(a)));
set(this, 'DesignMethod', 'Frequency sampling');

set(this, ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedDesignOpts', {'Window', ''});

% [EOF]
