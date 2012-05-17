function updatestates( ...
            h, ...
            enableProbe, ...
            numSamplesProcessed, ...
            pathGains, ...
            forceDisableProbe)
         
%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/12/04 22:16:35 $

h.PrivateData.EnableProbe = boolean(round(enableProbe));

% Update path gain history.
PGH = h.PathGainHistory;
if PGH.Enable
    PGH.update(pathGains);
end

% Updated PathGains property.
if (h.StoreHistory)
    % Store all path gain vectors.
    h.PathGains = pathGains;
    h.HistoryStored = true;
elseif (h.StorePathGains)
    % Store all path gain vectors.
    h.PathGains = pathGains;
else
    % Store last path gain vector.
    h.PathGains = pathGains(end, :);
end

% Update number of samples processed.
h.NumSamplesProcessed = numSamplesProcessed;

% The assumption here is that the history length is equal to the frame
% size.
h.NumFramesProcessed = h.NumSamplesProcessed/h.PGAndTGBufferSizes;

hData = h.PrivateData;
multipathFig = h.MultipathFigure;
if (hData.EnableProbe && ~forceDisableProbe)
%    Only plot if figure was not recently closed.
%    if (~multipathFig.SimulinkBlkFigClosedFlag)
        % always plot...allows the viz. to open immediately after it is
        % closed (g477993)
        h.plot;
%    end
    
    if ~figexist(h)
        % Make sure enableProbe menu setting is 0.
        set_param(h.SimulinkBlock, 'enableProbe', '0');
        h.PrivateData.EnableProbe = false;
    end
    if (~isempty(hData.ProbeFcn))
        hData.ProbeFcn(h);
    end

end

% Clear figure closed flag.
multipathFig.SimulinkBlkFigClosedFlag = false;
