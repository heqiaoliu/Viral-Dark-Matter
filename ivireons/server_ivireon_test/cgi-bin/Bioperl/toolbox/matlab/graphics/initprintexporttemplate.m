function initprintexporttemplate( varargin )
%INITPRINTTEMPLATE Initialize the figure's PrintTemplate

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/09/18 15:57:08 $

% Turn off the new printtemplate by default until the backwards compatibility
% issues are completely worked out.
return;

% This function will be called every time a figure is created.  Will
% initialize the printtemplate and exporttemplates from the default
% stylesheet file (if one exists).  In order to improve efficiency, the
% file is read only the first time a figure is created.  The values are
% cached (using persistent variables in this function), and the
% print/export templates of subsequent figures will be initialized from the
% cached values.

% Calling this function with 3 args tries will modify the already cached
% values for the printtemaplate and/or the exporttemplate.  The second arg 
% will tell whether the print or the export cache is being modified, 
% and the 3rd arg is the new value to cache.

persistent defpt;
persistent defet;

isNewAPI = usejava('swing') && ...
         (com.mathworks.page.export.PrintExportSettings.IsNewPreviewUsed() == true);

h = varargin{1};
if isNewAPI && ~strcmp(get(h, 'tag'), 'TMWFigurePrintPreview')
    % If nargs > 1, then the cached value of the printtemplate/export
    % template is being modified.  The second arg will tell whether the
    % print or the export cache is being modified, and the 3rd arg is the
    % new value to cache.
    if nargin > 1
      switch varargin{2}
        case 'print'
          defpt = varargin{3};
        case 'export'
          defet = varargin{3};
      end
    else
      defpt = Linitprinttemplate(h, defpt);
      defet = Linitexporttemplate(h, defet);      

      %% Remove the print setup and page setup menuitems
      menuitems = [findall(h, 'type', 'uimenu', 'label', 'Print Set&up...'), ...
                   findall(h, 'type', 'uimenu', 'label', 'Pa&ge Setup...')];
      set(menuitems, 'Visible', 'off');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function defpt = Linitprinttemplate(fig, defpt)

% If the figure had been deserialized, it will have its own printtemplate,
% don't mess with it!
pt = get(fig, 'PrintTemplate');
if ~isempty(pt)
    % Update newer properties, ifthe version is 1
    if ~isfield(pt, 'VersionNumber') || pt.VersionNumber == 1
      pt.StyleSheet = 'default';
      pt.VersionNumber = 2;    
      pt.FontName = '';
      pt.FontSize = 0;
      pt.FontSizeType = 'screen';
      pt.FontAngle = '';
      pt.FontWeight = '';
      pt.FontColor = '';
      pt.LineWidth = 0;
      pt.LineWidthType = 'screen';
      pt.LineMinWidth = 0;
      pt.LineStyle = '';
      pt.LineColor = '';   
      pt.PrintActiveX = 0;
      pt.GrayScale = 0;
      pt.BkColor= 'white';
    end    
    setprinttemplate(fig, pt);
    return;
end

% Read the default stylesheet (file) if defpt is empty; else, just use it
if isempty(defpt)
  defpt = readDefProps([prefdir '/PrintSetup/default.txt']);
  if isempty(defpt)
    defpt = printtemplate;          
  end    
end

% Update newer properties, ifthe version is 1
if defpt.VersionNumber == 1
  defpt.StyleSheet = 'default';
  defpt.VersionNumber = 2;    
  defpt.FontName = '';
  defpt.FontSize = 0;
  defpt.FontSizeType = 'screen';
  defpt.FontAngle = '';
  defpt.FontWeight = '';
  defpt.FontColor = '';
  defpt.LineWidth = 0;
  defpt.LineWidthType = 'screen';
  defpt.LineMinWidth = 0;
  defpt.LineStyle = '';
  defpt.LineColor = '';   
  defpt.PrintActiveX = 0;
  defpt.GrayScale = 0;
  defpt.BkColor= 'white';
end    
setprinttemplate(fig, defpt);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function defpt = Linitexporttemplate(fig, defpt)

% If the figure had been deserialized, it will have its own printtemplate,
% don't mess with it!
pt = get(fig, 'ExportTemplate');
if ~isempty(pt)
    % Update newer properties, ifthe version is 1
    if pt.VersionNumber == 1
      pt.StyleSheet = 'default';
      pt.VersionNumber = 2;    
      pt.FontName = '';
      pt.FontSize = 0;
      pt.FontSizeType = 'screen';
      pt.FontAngle = '';
      pt.FontWeight = '';
      pt.FontColor = '';
      pt.LineWidth = 0;
      pt.LineWidthType = 'screen';
      pt.LineMinWidth = 0;
      pt.LineStyle = '';
      pt.LineColor = '';   
      pt.PrintActiveX = 0;
      pt.GrayScale = 0;
      pt.BkColor= 'white';
    end    
    set(fig, 'ExportTemplate', pt);
    return;
end

% Read the default stylesheet (file) if defpt is empty; else, just use it
if isempty(defpt)
  defpt = readDefProps([prefdir '/ExportSetup/default.txt']);
  if isempty(defpt)
    defpt = printtemplate;          
  end    
end

% Update newer properties, ifthe version is 1
if defpt.VersionNumber == 1
  defpt.StyleSheet = 'default';
  defpt.VersionNumber = 2;    
  defpt.FontName = '';
  defpt.FontSize = 0;
  defpt.FontSizeType = 'screen';
  defpt.FontAngle = '';
  defpt.FontWeight = '';
  defpt.FontColor = '';
  defpt.LineWidth = 0;
  defpt.LineWidthType = 'screen';
  defpt.LineMinWidth = 0;
  defpt.LineStyle = '';
  defpt.LineColor = '';   
  defpt.PrintActiveX = 0;
  defpt.GrayScale = 0;
  defpt.BkColor= 'white';
end    
set(fig, 'ExportTemplate', defpt);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function props = readDefProps(filename)
props = [];
if exist(filename, 'file')
    [p,v] = textread(filename,'%s%[^\n]%*[^\n]');
    nfields = length(p);
    t = cell(2,nfields);
    t(1,:) = p(1:nfields);
    for i=1:nfields
        val = v{i};
        val(find(val=='''')) = []; %Strip of the quotes
        if isempty(val), val = ''; end
        
        % Handle number and arrays
        if strncmp(val, '[', 1) %Array
            num = str2num(val);
        else
            num = str2double(val);
            if isnan(num), num = val; end
        end
        t{2,i} = num; 
        
    end
    props = struct(t{:});
end
