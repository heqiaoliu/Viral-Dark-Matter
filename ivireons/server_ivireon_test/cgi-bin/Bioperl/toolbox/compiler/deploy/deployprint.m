function deployprint(varargin)
% DEPLOYPRINT Manage printing in a deployed application.
%
%   This function works around a bug in the MCR's implementation of 
% printing on Windows. Choosing "Print" from the File menu of a deployed
% application does not work, on Windows. 
%
% Also, need to force printopt.m into the CTF.
%
%#function printopt

if (ispc)

    % Get the location of the temp directory
    tfile = tempname;

    [printArgs, fig, printer, file] = parsePrintArgs(varargin);

    % We don't support File -> Print Setup from MATLAB (users wanting
    % Print Setup must do it from the print dialog box).

    if strcmp(fig, '-setup')
	title = 'Unsupported Feature';
	msg = 'Print Setup from a MATLAB Figure Window is unsupported in MATLAB Compiler generated applications. Select File | Print to display the print dialog box, which provides equivalent functionality.';
        msgbox(msg, title, 'warn');
        return;
    end

    % Check for a valid figure (it must be a number)
    if isempty(fig) || ~isnumeric(fig)
	    err = 'Unknown value.';
        if isempty(fig)
            err = 'Empty matrix';
        elseif ~isnumeric(fig)
            err = sprintf('Non-numeric value of type ''%s''', class(fig));
	    elseif fig < 0
            err = sprintf('Negative number (%d)', fig);
        end
	    error('MCR:Printing:Internal', ...
              'Internal error: Invalid figure: %s.', err);
    end

    % Get paper units

    paperUnits = get(fig, 'PaperUnits');
    if isempty(paperUnits)
	error('MCR:Printing:Internal', ...
              'Internal error: PaperUnits has no value.');
    end

    % We only support Centimeters and Points as paper units. If the 
    % current figure uses anything else, set the paper units (temporarily)
    % to centimeters (and remember that we need to set it back).
    % TODO: Support normalized units in a more rational way.
    paperUnitsPattern = '(centimeters)|(points)';
    oldPaperUnits = '';
    if isempty(regexp(paperUnits, paperUnitsPattern, 'once'))
        oldPaperUnits = paperUnits;
	paperUnits = 'centimeters';
        set(fig, 'PaperUnits', paperUnits);
    end

    % Get position (left, bottom, width, height) of the figure on the page
    pos = get(fig, 'PaperPosition');
    pos = num2cell(pos);

    % Get the dimensions of the current sheet of paper.
    paper = get(fig, 'PaperSize');
    paper = num2cell(paper);

    % In landscape mode, the image rendered by PrintImage is always
    % 1/3rd of an inch wrong. But this offset is only necessary when the
    % Renderer is OpenGL or Zbuffer. The other renderers have no such 
    % error in them.
    %
    % TODO: Remove this when the mystery of MATLAB's landscape mode
    % printing is resolved. 
    if strcmpi(get(fig, 'Renderer'), 'OpenGL') || ...
       strcmpi(get(fig, 'Renderer'), 'Zbuffer')
        landscapeXFactor = 1.0/3.0;
    else
        landscapeXFactor = 0.0;
    end

    % TODO: Support normalized units in a more rational way.
    switch (paperUnits)
      case 'points'
          landscapeXFactor = landscapeXFactor * 72;
      case 'centimeters'
          landscapeXFactor = landscapeXFactor * 2.54;
      otherwise
          warning('DEPLOYPRINT:BadUnits', ...
            '%s units not supported. Use centimeters or points.', ...
            paperUnits);
    end

    % Paper position
    %   Left   : pos{1}
    %   Bottom : pos{2}
    %   Width  : pos{3}
    %   Height : pos{4}

    % Determine portrait or landscape orientation
    orientation = '-p';

    figOrient = orient(fig);
    if (strcmpi(figOrient, 'landscape'))
        orientation = '-l';

        % Adjust the left and bottom coordinates of the image rectangle
        % if we're printing landscape.

        t = pos{1};

        % Left(landscape) = PaperHeight - Top(portrait)
        pos{1} = paper{2} - (pos{2} + pos{4});

        % Bottom(landscape) = Left(portrait)
        pos{2} = t + landscapeXFactor;

        % Flip paper width and height and the width and height of the 
        % image rectangle if we're printing landscape.

        t = pos{3};
        pos{3} = pos{4};
        pos{4} = t;

        t = paper{1};
        paper{1} = paper{2};
        paper{2} = t;
    end

    % Set name of temporary output file, or use the file name specified by
    % the user.
    if isempty(file)
        tfile = [tfile '.bmp'];
    else
        tfile = file;
    end
    printArgs{end+1} = tfile;
    
    % Convert position and paper size to strings so they can be formatted 
    % into the print command. Use lots of precision.

    prec = 8;
    for k=1:length(pos)
        pos{k} = num2str(pos{k}, prec);
    end

    for k=1:length(paper)
        paper{k} = num2str(paper{k}, prec);
    end

    % Get header information, if present. Don't send empty strings to
    % PrintImage, as that messes up the argument parsing. For example,
    %     -hs "" -hfn Helvetica 
    % will cause the parser to interpret -hfn as the argument to -hs, and 
    % treat Helvetica as a unrecognized flag.

    header = getappdata(fig);
    headerArgs = '';

    if ~isempty(header) && isfield(header, 'PrintHeaderHeaderSpec')
	hd = header.PrintHeaderHeaderSpec;

	% The header contains a date or a string -- either can be
	% empty (if both are empty, don't print any header).
        if ~isempty(hd.string)
            headerArgs = [headerArgs ' -hs "' hd.string '"'];
        end

        if ~isempty(hd.fontname)
            headerArgs = [headerArgs ' -hfn "' hd.fontname '"'];
        end

        if ~isempty(hd.fontsize)
            headerArgs = [headerArgs ' -hfs "' num2str(hd.fontsize) '"'];
        end

	% Date format, font weight, font angle and margin are optional

        % Interpret the date format here, where doing so is easy.
        % If date format is 'none', then don't send it.
        if ~isempty(hd.dateformat) && ...
           strcmp(hd.dateformat, 'none') == false
	    datestring = datestr(now, hd.dateformat);
            headerArgs = [headerArgs ' -hd "' datestring '"'];

        end

        if ~isempty(hd.fontweight) && isempty(hd.fontweight)
            headerArgs = [headerArgs ' -hfw ' hd.fontweight];
        end

        if ~isempty(hd.fontangle) && isempty(hd.fontangle)
            headerArgs = [headerArgs ' -hfa ' hd.fontangle];
        end

        if ~isempty(hd.margin) && isempty(hd.margin)
            headerArgs = [headerArgs ' -hm ' num2str(hd.margin, prec)];
        end

    end

    % Create a file from the content in the figure
    print(fig, printArgs{:});

    % Put the old figure paper units back, if necessary
    % TODO: Support normalized units in a more rational way
    if ~isempty(oldPaperUnits)
        set(fig, 'PaperUnits', oldPaperUnits);
    end

    % If the user specified an output file, we're done. Otherwise,
    % sent the output file to the printer.
    if isempty(file)
        adjustMargins = '';
        if strcmpi(get(fig, 'Renderer'), 'Painters')
            adjustMargins = '-am ';
        end

        cmd = ['PrintImage.exe ' tfile ' ' printer '-d ' adjustMargins ...
            orientation ' -m -pos ' pos{1} ' ' pos{2} ' ' pos{3} ' ' pos{4} ...
               ' -u ' paperUnits ' -paper ' paper{1} ' ' paper{2} ' ' ...
               headerArgs ' '];
        [s, w] = dos(cmd);
        if s ~= 0
            error('MCR:Printing:SystemError', ...
     'Failed to send image (in ''%s'') to the printer. System error:\n  %s',...
            tfile, w);
        end
    end

else
    % ~ispc
    try
        print(varargin{:});
    catch ex
        disp(ex.message);
    end
end

% There are three types of arguments to the print command:
%
%   1. Switches that control the printing operation.
%
%   2. Integer numbers which indicate the figure to print.
%
%   3. A single file name, which specifies the destination of the
%      printed output.
%
% No other types of arguments are permitted. We distinguish between the
% argument types by textual analysis:
%
%   * If the argument begins with a dash, it is a switch.
%       * Note: This prohibits files that begin with a dash.
%
%   * If the argument matches the pattern [0-9]+, it is an integer, and
%     assumed to be the figure number. If we have already seen a figure
%     number, we assume this argument is a file name.
%
%   * If the argument matches neither of the above rules, it is a filename.
%     Only a single file name argument is permitted.
%
% The presence of a filename argument will prevent DEPLOYPRINT from calling
% PrintImage.exe; it will call MATLAB's PRINT function to generate the output
% file and then return. 
%
% This behavior is believed to emulate MATLAB's as closely as practically 
% possible.

function [printArgs, fig, printer, file] = parsePrintArgs(arglist)
    printer = [];
    fig = -1;
    file = '';
    printArgs{1} = '-dbmp';
    for k=1:length(arglist)
        arg = arglist{k};
        if length(arg) >= 2
            prefix = arg(1:2);
        else
            prefix = arg;
        end
        switch prefix
	    % First, a collection of switches we recognize and process
            % specially.

            case '-d'
                % -d is not allowed, unless it it -dwin or -dwinc, both
	        % of which are no-ops.
                match = regexpi('-dwinc?', arg);
                if isempty(match)
                    warning('MCR:Printing:PrintDeviceBMP', ...
                            'Option %s ignored. Using BMP instead.', arg);
                end

            case '-f'
                fig = arg(3:end);

            case '-P'
                printer = [arg(3:end) ' '];
            
            case '-v'
                printer = '-i ';

            % Generic argument processing, according to the rules laid out
            % above.
            otherwise
                % If it is a character string
                if ischar(arg)

                    % And it starts with a dash, it's a switch; send it to
                    % the print command.
                    if regexp(arg, '^\s*-.*\s*$', 'once')
                        printArgs{end+1} = arg;   %#ok -- Quiet, MLINT

                    % If arg is a string that looks like a number, assume that
	            % it is the figure number; only the first number we see
                    % is treated like a figure number.

                    elseif regexp(arg, '^\s*[0-9]+\s*$', 'once')
                        if fig < 0
                            fig = arg;
                        end

                    % A string that doesn't look like a switch or a number
                    % must be a file name. Only one file name is permitted.
                    elseif isempty(file)
                        file = arg;
                    else
                        error('MCR:Printing:DuplicateFileName', ...
   ['The argument ''%s'' looks like a file name, but the output file name '...
   'has already been set to ''%s'''], arg, file);
                        
                    end

                % If it isn't a character string
                else
                    % If arg is a number, assume it is the figure number.
                    if isnumeric(arg)
                        if fig < 0
                            fig = arg;
                        else
                            error('MCR:Printing:DuplicateFigureNumber', ...
   ['The argument %d looks like a figure number, but the figure number '...
   'has already been set to %d.'], arg, fig);
                        end
                    else
                        error('MCR:Printing:BadArgument', ...
                          'Argument #%d is must be a string or a number.', ...
                              k);    
                    end
                end
        end
    end
    % If fig is a string that can be converted to a number, convert it!
    if (ischar(fig) && ~isempty(str2num(fig))), fig = str2num(fig); end %#ok

    % As a last resort, if we don't have a figure window to print yet,
    % try printing the current figure. 
    if (fig == -1), fig = get(0, 'CurrentFigure'); end

% The code below this line is currently not used. I leave it to facilitate
% the support for normalized coordinates, when that becomes necessary.

% Determine paper to figure unit conversion factor.
% Supported paper units are inches, centimeters and points.
% Supported figure units are pixels, inches, centimeters and points.

function factor = paperToFigureUnits(paperUnits, figureUnits) %#ok

    factor = 1.0;

    paperIndex = mapUnitToIndex(paperUnits);
    figureIndex = mapUnitToIndex(figureUnits);

    % If the units are different, the factor is not 1.0
    if (paperIndex ~= figureIndex)
        cf = computeConvertFactor;
        factor = cf(paperIndex, figureIndex);
    end

% Fill in the conversion factor matrix. All ones on the diagonal, of course,
% and the upper and lower triangles are the inverse of one another.
function cf = computeConvertFactor

    [inches, centimeters, points, pixels] = getUnitIndex;
    pixelsPerInch = get(0, 'ScreenPixelsPerInch');

    cf = ones(4,4);

    % Inches to ...
    cf(inches, centimeters) = 2.54;
    cf(inches, points) = 72;
    cf(inches, pixels) = pixelsPerInch;

    % Centimeters to ...
    cf(centimeters, points) = 72 / cf(inches, centimeters);
    cf(centimeters, pixels) = pixelsPerInch / cf(inches, centimeters);

    % Points to ...
    cf(points, pixels) = 1 / (cf(inches, points) / cf(inches, pixels));


    % All the other conversions are the inverse of the conversions we
    % already calculated.
    lcf = cf';
    lcf = 1 ./ lcf;
    cf = triu(cf) + tril(lcf, -1);

    % Put the ones back on the main diagonal.
    [rows, cols] = size(cf);
    cf(1:rows+1:rows*cols) = 1;


% Turn a string unit name into a conversion factor matrix index
function unit = mapUnitToIndex(unit)

    [inches, centimeters, points, pixels] = getUnitIndex;
    if regexpi(unit, 'Pixels')
        unit = pixels;
    elseif regexpi(unit, 'Points')
        unit = points;
    elseif regexpi(unit, 'Inches')
        unit = inches;
    elseif regexpi(unit, 'Centimeters')
        unit = centimeters;
    end

% Define the symbolic name to numeric index mapping of the conversion factor
% matrix.
function [inches, centimeters, points, pixels] = getUnitIndex
    inches = 1; centimeters = 2; points = 3; pixels = 4;
