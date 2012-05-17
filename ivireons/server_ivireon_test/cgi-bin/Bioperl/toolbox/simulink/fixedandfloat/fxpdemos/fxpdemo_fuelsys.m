function fxpdemo_fuelsys(varargin)
% Opens and configures sldemo_fuelsys for a Simulink Fixed-Point demo. The
% fuel_rate_control subsystem is configured for single precision data
% types and unevenly spaced lookup table data unless 'fixed' and 'pow2'
% are passed as arguments (order does not matter.)
%
% %Examples
% fxpdemo_fuelsys                 % single and uneven spaced lookup tables
% fxpdemo_fuelsys('fixed')        % fixed-point
% fxpdemo_fuelsys('pow2')         % Evenly spaced ^2 lookup tables
% fxpdemo_fuelsys('fixed','pow2') % fixed-point and ^2 spaced tables

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2009/05/14 17:50:36 $

model = 'sldemo_fuelsys';
close_system(model,0) 
open_system(model)

if nargin > 0
    if strmatch('fixed',varargin,'exact')
        sldemo_fuelsys_data(model,'switch_data_type','fixed');
    end
    if strmatch('pow2',varargin,'exact')
        sldemo_fuelsys_data(model,'switch_lookup_data','pow2');
    end
end

sldemo_fuelsys_data(model,'set_info_text','fxpdemo_fuelsys_publish');
sldemo_fuelsys_data(model,'top_level_logging','on')
set_param(model,'ShowPortDataTypes','on');
set_param(model,'Dirty','off')