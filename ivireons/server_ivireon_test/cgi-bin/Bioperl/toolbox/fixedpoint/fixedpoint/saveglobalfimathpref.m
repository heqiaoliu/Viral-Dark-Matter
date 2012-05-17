function saveglobalfimathpref
% SAVEGLOBALFIMATHPREF Save global fimath as a MATLAB preference
%
%    SAVEGLOBALFIMATHPREF saves the global fimath as a MATLAB preference so 
%    it is persistent between MATLAB sessions. 
%
%
%
%    Example:
%      F = fimath('RoundMode','Floor','OverflowMode','Wrap');
%      globalfimath(F); 
%      saveglobalfimathpref;
%
%    See also REMOVEGLOBALFIMATHPREF, GLOBALFIMATH, RESETGLOBALFIMATH

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 18:51:31 $

% The fimath constructor with no inputs will return the current global fimath
% Remove the 'Path' field (which is a DAStudio field) before saving the struct    
s = rmfield(struct(fimath),'Path');    
setpref('embedded','defaultfimath',s);

    
