classdef ReportOptions
% ReporterOption specifies various variable report options.

% Copyright 2010 The MathWorks, Inc.

  properties
    
    % SizeLimit is the allowable hypotenuse of a table.
    % If the table size exceeds this size, it will be
    % reported as a sequence of paragraphs, each containing a row.
    SizeLimit = 32
    
    % DepthLimit is the maximum depth to which the variable reporter
    % expands a cell array or structured object. Beyond that depth,
    % the report generator inserts a text report for a cell or property
    % value that is itself a cell array or structured object.
    DepthLimit = 10
    
    % ObjectLimit is the maximum number of embedded objects reported
    % for a hierarchical variable.
    ObjectLimit = 200
    
    % DisplayTable specifies the format of the report for a variable.
    % Valid options include:
    %
    %  * 'table'
    %  * 'para'
    %  * 'text'
    %  * 'auto' (one of the above chosen by the report generator based
    %            on the variable's data type)
    DisplayTable = 'auto'
    
    % TitleMode specifies the title to be generated for the variable
    % report. Valid options are:
    %
    %  * 'none'
    %  * 'auto'
    %  * 'manual' (custom title)
    TitleMode = 'auto'
    
    % Title of report if the TitleMode is 'manual'.
    CustomTitle = ''
    
    % Do not report empty variables or properties.
    IgnoreIfEmpty = false
    
    % Do not report a property that has a default value
    IgnoreIfDefault = false
    
    % Show a variable's data type in its title.
    ShowTypeInHeading = false
    
    ShowTableGrids = true
    
    MakeTablePageWide = false
    
  end
 
  methods
    
    function moOptions = ReportOptions(varargin)
    % moOptions = ReportOptions(varargin) constructs a report options
    % object. The constructor optionally accepts a UDD object, e.g.,
    % the source object for a DDG dialog that allows a user to specify
    % the options interactively. The option property names of the UDD object
    % must match the option property names of this object.
      if nargin == 1 
        moOpts = varargin{1};
        if ~isempty(moOpts)
          if moOpts.SizeLimit == 0
            moOptions.SizeLimit = inf;
          else
            moOptions.SizeLimit = moOpts.SizeLimit;
          end
          moOptions.DepthLimit = moOpts.DepthLimit;
          moOptions.ObjectLimit = moOpts.ObjectLimit;
          moOptions.DisplayTable = moOpts.DisplayTable;
          moOptions.TitleMode = moOpts.TitleMode;
          moOptions.CustomTitle = rptgen.parseExpressionText(moOpts.CustomTitle);
          moOptions.IgnoreIfEmpty = moOpts.IgnoreIfEmpty;
          moOptions.IgnoreIfDefault = moOpts.IgnoreIfDefault;
          moOptions.ShowTypeInHeading = moOpts.ShowTypeInHeading;
          moOptions.ShowTableGrids = moOpts.ShowTableGrids;
          moOptions.MakeTablePageWide = moOpts.MakeTablePageWide;
        end
      end
    end
    
    function tf = makeTitle(moOpt)
      tf = ~strcmp(moOpt.TitleMode, 'none');
    end
    
    
  end % of dynamic methods
  
 
  
end

