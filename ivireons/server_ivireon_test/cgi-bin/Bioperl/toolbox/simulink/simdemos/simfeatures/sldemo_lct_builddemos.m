%SLDEMO_LCT_BUILDDEMOS build LCT demo S-Functions

%   Copyright 2005-2007 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.6 $
%   $Date: 2008/09/02 19:11:50 $

% single definitions
alldefs = [];
sldemo_lct_bus_script 
bdclose('sldemo_lct_bus');

alldefs = [alldefs; def];
sldemo_lct_cpp_script
bdclose('sldemo_lct_cpp');

alldefs = [alldefs; def];
sldemo_lct_fixpt_params_script
bdclose('sldemo_lct_fixpt_params');

alldefs = [alldefs; def];
sldemo_lct_fixpt_signals_script
bdclose('sldemo_lct_fixpt_signals');

alldefs = [alldefs; def];
sldemo_lct_gain_script
bdclose('sldemo_lct_gain');

alldefs = [alldefs; def];
sldemo_lct_start_term_script
bdclose('sldemo_lct_start_term');

alldefs = [alldefs; def];
sldemo_lct_work_script
bdclose('sldemo_lct_work');

alldefs = [alldefs; def];
sldemo_lct_ndarray_script
bdclose('sldemo_lct_ndarray');

alldefs = [alldefs; def];
sldemo_lct_cplxgain_script 
bdclose('sldemo_lct_cplxgain');

alldefs = [alldefs; def];

% multiple definitions
sldemo_lct_filter_script 
bdclose('sldemo_lct_filter');

alldefs = [alldefs; defs];
sldemo_lct_inherit_dims_script 
bdclose('sldemo_lct_inherit_dims');

alldefs = [alldefs; defs];
sldemo_lct_lut_script
bdclose('sldemo_lct_lut');

alldefs = [alldefs; defs];
sldemo_lct_sampletime_script
bdclose('sldemo_lct_sampletime');

alldefs = [alldefs; defs];

legacy_code('rtwmakecfg_generate',alldefs);
