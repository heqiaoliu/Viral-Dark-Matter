function clg(arg1)
%CLG    Clear Figure (graph window).
%   CLG is a pseudonym for CLF, provided for upward compatibility
%   from MATLAB 3.5.
%
%   See also CLF.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2005/10/28 15:53:34 $

warning('MATLAB:clg:ObsoleteFunction', 'This function is obsolete and may be removed in future versions. Use Clf instead')
if(nargin == 0)
    clf;
else
    clf(arg1);
end

