function resetglobalfimath
% RESETGLOBALFIMATH Resets global fimath to factory setting
%
%   RESETGLOBALFIMATH resets the user configured global fimath to the factory setting:
%    
%                RoundMode: nearest
%             OverflowMode: saturate
%              ProductMode: FullPrecision
%     MaxProductWordLength: 128
%                  SumMode: FullPrecision
%         MaxSumWordLength: 128
%            CastBeforeSum: true
%    
%
%
%   Example:
%     F = fimath('RoundMode','Floor','OverflowMode','Wrap');
%     globalfimath(F);
%     F1 = fimath; % Will be the same as F
%     A = fi(pi); % A's fimath will be the same as F     
%     resetglobalfimath;
%     A = fi(pi); % A's fimath will now be the factory setting    
%
%   See also GLOBALFIMATH, SAVEGLOBALFIMATHPREF, REMOVEGLOBALFIMATHPREF    
    
%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 18:51:29 $
    
embedded.fimath.ResetGlobalFimath;
