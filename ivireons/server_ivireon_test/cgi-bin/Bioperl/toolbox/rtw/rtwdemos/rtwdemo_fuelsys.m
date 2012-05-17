function rtwdemo_fuelsys(varargin)
% Opens and configures sldemo_fuelsys for a single precision Real-Time
% Workshop demo.

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2009/05/14 17:30:40 $

model = 'sldemo_fuelsys';
close_system(model,0);
open_system(model);
rtwconfiguredemo(model,'ERT','float');
sldemo_fuelsys_data(model,'set_info_text','rtwdemo_fuelsys_publish');
sldemo_fuelsys_data(model,'top_level_logging','off');
set_param(model,'ShowPortDataTypes','on');
set_param(model,'SampleTimeColors','on');
set_param(model,'Dirty','off')