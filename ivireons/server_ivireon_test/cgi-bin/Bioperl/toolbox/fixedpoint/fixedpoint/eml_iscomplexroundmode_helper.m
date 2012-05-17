function flag = eml_iscomplexroundmode_helper(F,rmode)
% EML helper function that returns true if F 
% has a roundmode that is round, nearest or convergent

% Copyright 2006-2007 The MathWorks, Inc.
    
nargchk(1,2,nargin);
if ~isfimath(F)
    error('eml:fi:inputNotFimath','Input must be a fimath');
end
if nargin==1
    rmode = '';
end
fRoundMode = get(F,'RoundMode');
if isempty(rmode)
    flag = strcmpi(fRoundMode,'round') ||...
           strcmpi(fRoundMode,'nearest') ||...
           strcmpi(fRoundMode,'convergent') ||...
           strcmpi(fRoundMode,'ceil');
elseif ischar(rmode)
    flag = strcmpi(fRoundMode,rmode);
end
%------------------------------------------------------------------