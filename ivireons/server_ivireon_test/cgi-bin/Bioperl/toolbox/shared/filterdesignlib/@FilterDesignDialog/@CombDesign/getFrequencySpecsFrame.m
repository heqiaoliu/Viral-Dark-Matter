function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME   Get the frequencySpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/11 16:04:54 $

% Add the constraints popup.
items = getConstraintsWidgets(this, 'Frequency', 1);

% Add the quality factor in the 2nd row but he bandwidth in the 3rd.  We
% want the quality factor above the freq units because it does not use them
if strcmp(this.FrequencyConstraints, 'Quality Factor')
    [q_lbl, q] = getWidgetSchema(this, 'Q', FilterDesignDialog.message('QLabel'), 'edit', 2, 1);
    items = [items {q_lbl q}];
    row = 3;
else
    [bw_lbl, bw] = getWidgetSchema(this, 'BW', FilterDesignDialog.message('BWLabel'), 'edit', 3, 1);
    items = [items {bw_lbl bw}];
    row = 2;
end

% Add the Frequency Units widgets
items = getFrequencyUnitsWidgets(this, row, items);
items{end}.DialogRefresh = true;
freqs_lbl.Name = FilterDesignDialog.message([this.CombType 'Frequencies']);
freqs_lbl.Type = 'text';
freqs_lbl.RowSpan = [4 4];
freqs_lbl.ColSpan = [1 1];
freqs_lbl.Tag = 'FrequenciesLabel';

freqString = getFrequencyString(this);

freqs.Name = freqString;
freqs.Type = 'text';
freqs.RowSpan = [4 4];
freqs.ColSpan = [2 4];
freqs.Tag = 'Frequencies';

items = [items {freqs_lbl freqs}];

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [4 4];
fspecs.RowStretch = [0 0 0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';

% -------------------------------------------------------------------------
function freqString = getFrequencyString(this)

% Get the frequencies string.
hd = getFDesign(this, this);
if isempty(hd)
    freqString = 'Cannot calculate without Filter Design Toolbox.';
else
    freqValues = hd.([this.CombType 'Frequencies']);
    if ~strcmp(this.FrequencyUnits, 'Normalized (0 to 1)')
        freqValues = convertfrequnits(freqValues, 'hz', this.FrequencyUnits);
    end
    precision = 5;
    freqString = mat2str(freqValues, precision);
    
    % If the string is too large, try replacing numbers with '...', but make
    % sure we keep at least 2 at the start so that the user can see how big the
    % notch gaps are. Also add on the last point so users can see if it ends at
    % nyquist/2 or earlier.
    indx = length(freqValues)-2;
    while length(freqString) > 58 && indx > 2
        freqString = mat2str(freqValues(1:indx), precision);
        freqString = sprintf('%s ... %s]', freqString(1:end-1), ...
            mat2str(freqValues(end), precision));
        indx = indx-1;
    end
end

% [EOF]
