function rtwmemprofile(varargin)
%RTWMEMPROFILE invokes the generation of html file for RAM/ROM usage.
%   Used at command line to manually regenerate report.

%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   $Date: 2006/12/20 07:47:21 $
  switch nargin
   case 0
    model = bdroot;
    if strcmp(model,'')
      disp('Unable to locate a model, specify a model name.');
      return;
    end
   case 1
    model = varargin{1};
   otherwise
      disp('Specify one model name');
      return;
  end
    
  try
    load_system(model);
  catch
    disp(['Unable to locate model: ',model]);
    return;
  end
  [dummy, gensettings] = rtwprivate('getSTFInfo', model);
  
  % Only support overall model builds, subsystem builds are not (yet) supported.
  builddir = gensettings.RelativeBuildDir;
  if exist(builddir,'dir') ~= 7
    disp('Cannot find RTW build directory.');
    return;
  end
  savedpwd = pwd;
  cd(builddir);
  try
    if exist('htmlreport.m','file') ~= 2
      disp('Cannot find file ''htmlreport'' in RTW build directory.');
      return;
    end
    htmlreport;
  catch
      % silent catch
  end
  cd(savedpwd);
