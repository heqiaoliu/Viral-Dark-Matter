function vrcapturecallback(fig)
%VRCAPTURECALLBACK Frame capture callback function.
%   Called from VR figure to handle frame capture.
%
%   VRCAPTURECALLBACK(F) captures figure F into a graphic file defined 
%   by CaptureFileName and CaptureFileFormat figure properties.
%
%   Not to be used directly.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:09:24 $ $Author: batserve $

% generate the filename for the file from template and world filename
ftmpl = get(fig, 'CaptureFileName');
wfile = get(get(fig, 'World'), 'FileName');
file = vrsfunc('GenerateFile', ftmpl, wfile);
captureFormat = get(fig, 'CaptureFileFormat');

if isempty(file)
  warning('VR:cantopenfile', 'Can''t open graphic file, capture suppressed.');
  return
end
try 
  % capture the scene shot and store it to the graphic file
  imwrite(capture(fig), file, captureFormat);
catch ME
  ex = MException('VR:commandfailed', 'IMWRITE command failed for frame capture.\n%s', ME.message);
  ex.addCause(ME);
  throwAsCaller(ex);
end  




