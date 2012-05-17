% $Revision: 1.1.6.1 $
% $Date: 2009/03/31 00:13:43 $
%
% Copyright 1994-2009 The MathWorks, Inc.
%
% Abstract:
%   Inspect code script for sfcndemo_sfun_rtwdwork

function rtwdwork_inspect(f)

dirname = 'sfcndemo_sfun_rtwdwork_ert_rtw';

if ~exist(dirname)
  try rtwbuild('sfcndemo_sfun_rtwdwork'); end %#ok<TRYNC>
end

edit(fullfile('.',dirname,f));



