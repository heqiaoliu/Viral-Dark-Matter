%RTWDEMO_LCT_BUILDDEMOS build LCT demo S-Functions

%   Copyright 2005-2006 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.2 $
%   $Date: 2006/12/20 07:25:09 $

alldefs = [];

% single definitions; make sure to close system and clear any vars created
rtwdemo_lct_bus_script 
close_system('rtwdemo_lct_bus')
clear COUNTERBUS  LIMITBUS    SIGNALBUS   myFixpt
alldefs = [alldefs; def];

rtwdemo_lct_cpp_script 
close_system('rtwdemo_lct_cpp')
alldefs = [alldefs; def];

rtwdemo_lct_fixpt_params_script 
close_system('rtwdemo_lct_fixpt_params')
clear COUNTERBUS Kinline Huint8 SIGNALBUS Kcs KmyFixpt LIMITBUS myFixpt
alldefs = [alldefs; def];

rtwdemo_lct_fixpt_signals_script 
close_system('rtwdemo_lct_fixpt_signals')
clear COUNTERBUS SIGNALBUS LIMITBUS myFixpt
alldefs = [alldefs; def];

rtwdemo_lct_gain_script 
close_system('rtwdemo_lct_gain')
alldefs = [alldefs; def];

rtwdemo_lct_start_term_script 
close_system('rtwdemo_lct_start_term')
alldefs = [alldefs; def];

% multiple definitions; make sure to close system and clear any vars created
rtwdemo_lct_filter_script 
close_system('rtwdemo_lct_filter')
clear FilterGain
alldefs = [alldefs; defs];

rtwdemo_lct_inherit_dims_script 
close_system('rtwdemo_lct_inherit_dims')
alldefs = [alldefs; defs];

rtwdemo_lct_lut_script 
close_system('rtwdemo_lct_lut')
clear LUT3D LUT4D
alldefs = [alldefs; defs];

rtwdemo_lct_work_script 
close_system('rtwdemo_lct_work')
clear COUNTERBUS  LIMITBUS    SIGNALBUS   myFixpt
alldefs = [alldefs; def];

rtwdemo_lct_ndarray_script 
close_system('rtwdemo_lct_ndarray')
alldefs = [alldefs; def];

rtwdemo_lct_cplxgain_script 
close_system('rtwdemo_lct_cplxgain')
alldefs = [alldefs; def];

rtwdemo_lct_sampletime_script 
close_system('rtwdemo_lct_sampletime')
alldefs = [alldefs; defs];

legacy_code('rtwmakecfg_generate',alldefs);

