function [tmf,envVal,mexOpts] = modelrefsim_default_tmf
% MODELREFSIM_DEFAULT_TMF Returns the "default" template makefile for use with modelrefsim.tlc
%
% See get_tmf_for_target in the toolbox/rtw/private directory for more 
% information.

% Copyright 1994-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9.8.1 $ $Date: 2010/07/12 15:22:33 $

  [tmf,envVal,mexOpts] = get_tmf_for_target('modelrefsim');
  switch computer
    case 'PCWIN'
      if ~ismember(tmf,{'modelrefsim_vc.tmf'...
                        'modelrefsim_watc.tmf'...
                        'modelrefsim_lcc.tmf'})
          DAStudio.warning('RTW:buildProcess:switchingToDefaultTMF');
          tmf = 'modelrefsim_lcc.tmf';
          envVal = '';
      end
    otherwise
      % do nothing
  end
  
  
%end modelrefsim_default_tmf.m

% LocalWords:  PCWIN vc watc lcc
