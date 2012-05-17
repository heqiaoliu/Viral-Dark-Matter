function this = Database(varargin)
%DATABASE Construct a DATABASE object

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:43 $

% Database is NOT an abstract class.
this = extmgr.Database;

this.add(varargin{:});

% [EOF]
