function fonts = listfonts(handle)
%LISTFONTS Get list of available system fonts in cell array.
%   C = LISTFONTS returns list of available system fonts.
%
%   C = LISTFONTS(H) returns system fonts with object's FontName
%   sorted into the list.
%
%   Examples:
%     Example1:
%       list = listfonts
%
%     Example2:
%       h = uicontrol('Style', 'text', 'string', 'My Font');
%       list = listfonts(h)
%
%   See also UISETFONT.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.15.4.5 $  $Date: 2006/11/29 21:53:01 $

persistent systemfonts;
if nargin == 1
    try
        currentfont = {get(handle, 'FontName')};
    catch
        currentfont = {''};
    end
else
    currentfont = {''};
end

isjava = usejava('awt');
  
if isempty(systemfonts)
    if (ispc)
        try
            fonts = winqueryreg('name','HKEY_LOCAL_MACHINE',...
                'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts');
        catch
            try
                fonts = winqueryreg('name','HKEY_LOCAL_MACHINE',...
                    ['SOFTWARE\Microsoft\Windows\' ...
                        'CurrentVersion\Fonts']);
            catch
                fonts = {};
            end
        end

        cleanfonts = cell(1,length(fonts));
        cleanfontcount = 0;
        for n=1:length(fonts)
            subfonts = strread(fonts{n},'%s','delimiter','&');
            for m = 1:length(subfonts);
                font = subfonts{m};
                % strip out anything after '(', a digit, ' bold' or ' italic'
                font = strtok(font,'(');
                inda = find(font >= '0' & font <= '9');
                indb = strfind(font,' Bold');
                indc = strfind(font,' Italic');
                if ~isempty([inda indb indc])
                    font = font(1:min([inda indb indc])-1);
                end        
                % strip trailing spaces
                font = deblank(font);
                
                if ~isempty(font)
                    cleanfontcount = cleanfontcount + 1;
                    cleanfonts{cleanfontcount} = font;
                end
            end
        end
        cleanfonts = cleanfonts(1:cleanfontcount);
        fonts = cleanfonts';
    elseif ((ismac) && (isjava))
        fontlist = com.mathworks.mwswing.MJUtilities.getFontList();
        fonts = cell(fontlist);
    else
        perlCommand = 'perl';
        [dir, name] = fileparts(which(mfilename));  %#ok
        [s, result] = unix([perlCommand ' ' fullfile(dir, 'private', 'listunixfonts.pl')]);
        if (s == 0 && ~isempty(result) && isempty(strfind(result,'Command not found')) && ...
                isempty(strfind(result,'unable to open display')))
            [font, rem] = strtok(result, char(10));
            fonts{1} = font;
            i = 1;
            while (~isempty(rem))
                i = i + 1;
                % The following was suggested to use textscan instead,
                % something like:
                % fonts = textscan(result, '%s');
                % i = length(fonts);
                % We should look at this again in the future.
                [font, rem] = strtok(rem, char(10)); %#ok<STTOK>
                if (~isempty(rem))
                    fonts{i} = font; %#ok
                end
            end
        else
            fonts = {};
        end
        fonts = fonts';
    end
    
    % add postscipt fonts to the system fonts list. these font names are
    % defined in HG source code (not on Mac)
    if ((ismac) && (isjava))
        systemfonts = fonts;
    else
        systemfonts = [fonts; 
            {
                'AvantGarde';
                'Bookman';
                'Courier';
                'Helvetica';
                'Helvetica-Narrow'; 
                'NewCenturySchoolBook';
                'Palatino';
                'Symbol';
                'Times';
                'ZapfChancery';
                'ZapfDingbats'; 
            }];
    end
end

% add the current font to the system font list if it's there
if isempty(currentfont{1})
    fonts = systemfonts;
else
    fonts = [systemfonts; currentfont];
end

% return a sorted and unique font list to the user
[f,i] = unique(lower(fonts));  %#ok
fonts = fonts(i);
