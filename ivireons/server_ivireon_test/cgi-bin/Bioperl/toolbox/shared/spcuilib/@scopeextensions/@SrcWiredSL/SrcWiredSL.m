function this = SrcWiredSL(varargin)
%WIREDSRCSL Construct a WIREDSRCSL object for Simulink Sources.


%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/11/16 22:34:10 $

this = scopeextensions.SrcWiredSL;
this.initSource(varargin{:});

% Overwrite the SourceType set in initSource.  We want it to say 'Simulink'
% instead of 'Wired Simulink'.
this.Type = 'Simulink';

% [EOF]
