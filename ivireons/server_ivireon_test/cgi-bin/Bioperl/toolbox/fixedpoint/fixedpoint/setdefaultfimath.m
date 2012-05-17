function setdefaultfimath(varargin)
% SETDEFAULTFIMATH Configure global fimath
%
%   SETDEFAULTFIMATH is obsolete. SETDEFAULTFIMATH still works but may be removed in a future release.
%   Use <a href="matlab:help globalfimath">globalfimath</a> instead.   
%
%   See also RESETGLOBALFIMATH, SAVEGLOBALFIMATHPREF, REMOVEGLOBALFIMATHPREF
    
%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/23 18:51:32 $
    
error(nargoutchk(0,0,nargout,'struct'));
error(nargchk(1,inf,nargin,'struct'));
globalfimath(varargin{:});


