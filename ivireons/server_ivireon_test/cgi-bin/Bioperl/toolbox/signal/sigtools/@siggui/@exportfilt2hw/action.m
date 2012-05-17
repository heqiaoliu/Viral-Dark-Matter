function success = action(hE)
%ACTION Perform the action of the Export Header Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.5 $  $Date: 2007/12/14 15:18:30 $

if ~ischeader(hE) | validate_filename(hE),
    success = true;
    export_data(hE)
else
    success = false;
end


% --------------------------------------------------------------------
function export_data(hE)
% Call function that exports to CCS

% Form a structure, 's', with the part of the GUI state we
% wish to export, i.e. all relevant information to export

s = generate_exportdata(hE);

hts = getcomponent(hE, '-class', 'siggui.targetselector');
s.brdNo      = evaluatevars(get(hts, 'Board'));
if isempty(s.brdNo),
    error(generatemsgid('invalidBoardNumber'), ...
        'The board number must be an integer.');
end
s.procNo     = evaluatevars(get(hts, 'Processor'));
if isempty(s.procNo),
    error(generatemsgid('invalidProcessorNumber'), ...
        'The processor number must be an integer.');
end
s.exportMode = get(hE, 'ExportMode');
s.warnings   = get(hE, 'DisableWarnings');

try,
    if ischeader(hE),
        % Create the header file
        createcfile(hE, s);

        ccsaddsource(s.brdNo,s.procNo,s.file);
        
    else
        % If in "Write directly to memory" mode call appropriately API
        ccshotcoeff(s,~s.warnings);
    end
    
catch ME,
    if ischeader(hE),
        error(generatemsgid('GUIErr'),'C-Header File has been created at:\n\n%s\n\n%s %s.', s.file, ...
            'However, a proper installation of Code Composer Studio(R)', ...
            'could not be found to load the file');
    else
        throwAsCaller(ME);
    end
end


% --------------------------------------------------------------------
function boolflag = ischeader(hE)

opts = set(hE, 'ExportMode');
xpm  = get(hE, 'ExportMode');

boolflag = (find(strcmpi(xpm, opts)) == 1);

% [EOF]
