function vrrecordcallback(fig, str)
%VRRECORDCALLBACK Recording callback function.
%   Called from VR figure to handle AVI recording.
%
%   VRRECORDCALLBACK(F, 'start') prepares AVI recording for figure F.
%   VRRECORDCALLBACK(F, 'frame') stores a frame for figure F.
%   VRRECORDCALLBACK(F, 'stop') stops AVI recording and stores the file.
%
%   Not to be used directly.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2009/01/16 11:08:04 $ $Author: batserve $


persistent vr_rec_aviobj;

fig = vrgcbf;

% prepare the AVI recording
switch(lower(str))
  case 'start'

    % generate the filename for the .AVI file from template and world filename
    ftmpl = get(fig, 'Record2DFileName');
    wfile = get(get(fig, 'World'), 'FileName');
    file = vrsfunc('GenerateFile', ftmpl, wfile);
    if isempty(file)
      warning('VR:cantopenfile', 'Can''t open AVI file, recording suppressed.');
      vr_rec_aviobj = [];
      return
    end

    % auto-select the AVI codec to use
    aviparam = {file};
    cmethod = get(fig, 'Record2DCompressMethod');
    if ~isempty(cmethod)
      switch(lower(cmethod))
        case 'auto'
          cmethod = findcodec;
        case 'lossless'
          cmethod = 'None';
      end
      aviparam = [aviparam {'Compression', cmethod}];
    end

    % create the AVI file
    cqual = get(fig, 'Record2DCompressQuality');
    if ~isempty(cqual)
      aviparam = [aviparam {'Quality', cqual}];
    end
    fps = get(fig, 'Record2DFPS');
    if ~isempty(fps)
      aviparam = [aviparam {'fps', fps}];
    end

    % create the AVI file
    try
      vr_rec_aviobj = avifile(aviparam{:});
    catch ME
      clear vr_rec_aviobj;
      warning('VR:avierror', 'Invalid AVI parameter, recording suppressed.\nError message: %s', ME.message);
    end
  
% record a frame
  case 'frame'

    % do nothing if recording object is not available
    if isempty(vr_rec_aviobj)
      return;
    end

    % capture the scene shot and store it to the AVI file
    try
      vr_rec_aviobj = addframe(vr_rec_aviobj, capture(fig));
    catch ME
      vr_rec_aviobj = close(vr_rec_aviobj);
      clear vr_rec_aviobj;
      warning('VR:avierror', 'Error adding frame to AVI file, recording suppressed.\nError message: %s', ME.message);
    end

  
% finish AVI recording and save the file
  case 'stop'

    % do nothing if recording object is not available
    if isempty(vr_rec_aviobj)
      return;
    end

    % close the AVI file, saving it
    vr_rec_aviobj = close(vr_rec_aviobj);
    clear vr_rec_aviobj;

% any other command is invalid
  otherwise

    error('VR:badcommand', ['Unrecognized command ''' str '''.']);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = findcodec
% find a present codec from a list of known codecs

% get all available codecs
% only Indeo and Cinepak codecs support truecolor images
codecs = enumcodecs;
known = { 'iv50', 'Indeo5';    % Intel Indeo 5
          'iv32', 'Indeo3';    % Intel Indeo 3
          'cvid', 'Cinepak'    % Cinepak 
        };  

% conditionally remove Indeo codecs based on the same tests as in AVIFILE
% AVIFILE may prohibit Indeo even if it's available
if ispc
  if mmcompinfo('video','video 5.1') == -1
    codecs(strcmpi(codecs, 'iv50')) = [];
  end
  if mmcompinfo('video','Intel Indeo(R) Video R3.2') == -1
    codecs(strcmpi(codecs, 'iv32')) = [];
  end
end

% test if known codecs are present on the machine
for i=1:size(known, 1)
  if any(strcmpi(known{i, 1}, codecs))
    c = known{i, 2};
    return;
  end
end

% none found
c = 'None';
