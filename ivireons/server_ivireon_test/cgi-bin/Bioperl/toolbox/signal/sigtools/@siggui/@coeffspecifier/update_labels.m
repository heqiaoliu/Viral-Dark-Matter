function update_labels(hCoeff, eventData)
%UPDATE_LABELS Update the labels and visibility of the Coefficient Specifier

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/03/13 19:50:25 $

if ~isrendered(hCoeff) , return; end

% Make all the controls invisible and then turn on the correct ones
h = get(hCoeff,'Handles');

set(h.ebs,'Visible','Off');
set(h.lbls,'Visible','Off');
set(h.clrpbs,'Visible','Off');

visState    = get(hCoeff,'Visible');
enabState   = get(hCoeff,'Enable');
shortstruct = getshortstruct(hCoeff);

labels  = get(hCoeff,'Labels');
lblStrs = labels.(shortstruct);

for i = 1:length(lblStrs)

    % Turn on the 'shortstruct' specific labels. 
    set(h.lbls(i),...
        'Visible',visState,...
        'String',lblStrs{i});
end

% Turn on the correct number of edit boxes.
set(h.ebs(1:length(lblStrs)),...
    'Visible',visState,...
    'Enable',enabState,...
    'BackgroundColor','White');

% Turn on the correct number of "Clear" Push buttons.
set(h.clrpbs(1:length(lblStrs)),...
    'Visible',visState,...
    'Enable',enabState);

% The "Ladder coeff" parameter is not valid for "Lattice allpass",
% however it exists within the structure, so we disable both uicontrols.
if strcmp(shortstruct,'latcallpass')
    setenableprop(h.ebs(2),'Off');
    set(h.clrpbs(2),'Enable','Off');
end

% [EOF]
