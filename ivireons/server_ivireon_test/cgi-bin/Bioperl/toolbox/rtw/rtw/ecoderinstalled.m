function ret = ecoderinstalled(modelName)
% ECODERINSTALLED - Check whether ecoder is installed for current
% user.  This includes testing for an ecoder license (but NOT checking
% it out) and testing for a particular file associated with ecoder.
% Return 1 if installed, otherwise return 0.


% Copyright 1994-2009 The MathWorks, Inc.
%
% $RCSfile: ecoderinstalled.m,v $
% $Revision: 1.5.6.7 $

% modelName parameter is not used in this function, keep it anyway for
% backwards compatiability.

    mlock;
    persistent pathExist;
    
    if isempty(pathExist)
        %  avoid use exist() to check for the existence of Contents.m to improve performance g560268
%        pathExist = exist([matlabroot '/toolbox/rtw/targets/ecoder/Contents'],'file') == 2;
        pathExist =  ~isempty(dir([matlabroot '/toolbox/rtw/targets/ecoder/Contents.m']));     
    end
    
    ret = license('test', 'RTW_Embedded_Coder') && pathExist;
