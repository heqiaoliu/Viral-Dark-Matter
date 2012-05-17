function this = SrcFile(varargin)
% Constructor for MPlay.SrcFile file-based data sources

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:33:09 $

this = scopeextensions.SrcFile;
this.initSource(varargin{:});

% [EOF]
