function removeglobalfimathpref
% REMOVEGLOBALFIMATHPREF Remove global fimath MATLAB preference 
%    
%    REMOVEGLOBALFIMATHPREF removes the user configured global fimath that was saved as a MATLAB preference.
%
%
%    Example:
%      resetglobalfimath; 
%      removeglobalfimathpref;
%    
%    See also SAVEGLOBALFIMATHPREF, GLOBALFIMATH, RESETGLOBALFIMATH
    
%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 18:51:27 $

% If the 'embedded'/'defaultfimath' preference exists delete it from the MATLAB preferences.    
if ispref('embedded','defaultfimath')
    rmpref('embedded','defaultfimath');
end
