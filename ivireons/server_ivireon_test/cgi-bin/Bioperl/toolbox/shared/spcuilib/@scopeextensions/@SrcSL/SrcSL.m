function this = SrcSL(varargin)
% Constructor for SrcSL Simulink-based data sources
%
%  SrcSL(slPath) specifies a Simulink path, either
%  'path' or {'path'} or {'path',portIdx} or [line_handles].
%  It may also be omitted, in which case gsb/gsl is ultimately used.
%
%  Port can describe a single matrix signal, or a virtual bus of 3
%  matrices representing an RGB signal.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/11/16 22:33:58 $

% Initialize the getCurrentSystem mechanism so that from now on we record
% model selection changes.
slmgr.getCurrentSystem;

this = scopeextensions.SrcSL;
this.initSource(varargin{:});

% [EOF]
