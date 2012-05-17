function profData = exprofile_process_data(rawdata, profileInfo)
%EXPROFILE_PROCESS_DATA processes RAWDATA producing a report and MATLAB graphic
%
%   EXPROFILE_PROCESS_DATA processes the data from the target and produces a 
%   html report and MATLAB graphic. RAWDATA is the data collected from the
%   target that needs to be processed. PROFILEINFO is target specific
%   information required in the analysis of RAWDATA.

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/06/16 20:13:40 $

disp('Processing data, please wait ...');
disp(' ');

% Unpack the raw data
profData = exprofile_unpack(rawdata, profileInfo);

% Display the data as a MATLAB graphic
profData = exprofile_plot(profData);

% Display an HTML report
exprofile_report(profData);
