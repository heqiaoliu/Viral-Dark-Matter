function this = SrcWksp(varargin)
% Constructor for MPlay.SrcWksp MATLAB workspace-based data sources

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:33:21 $

this = scopeextensions.SrcWksp;
this.initSource(varargin{:});

this.LoadExpr = scopeextensions.WorkspaceExpression(this.Application);

% [EOF]
