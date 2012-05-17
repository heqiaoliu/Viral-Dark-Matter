function dlgstruct = syntaxddg(h, name)
% Copyright 2005 The MathWorks, Inc.

    panel1.Type = 'panel';
    panel1.LayoutGrid = [2 1];
    panel1.RowSpan = [1 1];
    panel1.ColSpan = [1 1];

    cb.Name = 'Enable syntax highlighting';
    cb.Type = 'checkbox';
    cb.RowSpan = [1 1];
    cb.ColSpan = [1 1];
    cb.ObjectProperty = 'Enabled';
    cb.Source = Stateflow.SyntaxHighlighter;

    colors.Name = 'Edit colors';
    colors.Type = 'group';
    colors.LayoutGrid = [3 5];
    colors.RowSpan = [2 2];
    colors.ColSpan = [1 1];
    colors.ColStretch = [0 0 1 0 0];
    colors.Items = [ ...
        get_widgets(h, 'Keyword', 2, 1) ...
        get_widgets(h, 'Comment', 3, 1) ...
        get_widgets(h, 'Event', 4, 1) ...
        get_widgets(h, 'Graphical Function', 2, 2) ...
        get_widgets(h, 'String', 3, 2) ...
        get_widgets(h, 'Number', 4, 2) ...
        ];    
    
    panel1.Items = [ {cb}, {colors} ];


% Data and functions are not currently parsed correctly.
% If/when they are, these lines can be added to enable highlighting
%        get_widgets(h, 'Data', 5, 1) ...
%        get_widgets(h, 'Function', 5, 2) ...

    


    %%%%%%%%%%%%%%%%%%%%%%%
    % Main dialog
    %%%%%%%%%%%%%%%%%%%%%%%

    dlgstruct.DialogTitle = 'Syntax Highlight Preferences';

    dlgstruct.DialogTag = create_unique_dialog_tag_l();
    dlgstruct.PreApplyCallback = 'sf';
    dlgstruct.PreApplyArgs = {'Private', 'syntaxddg_preapply_callback', '%source'};
    dlgstruct.Items =  {panel1};


%--------------------------------------------------------------------------
function unique_tag = create_unique_dialog_tag_l()

    unique_tag = '_DDG_Syntax_Dialog_Tag_';


function ddgColor = get_ddg_color(shColor)
    ddgColor = 254*shColor;
    

function [blcell] = get_widgets(h, type, row, col)

    label.Type = 'text';
    label.Name = [ type ':'];
    label.RowSpan = [row row];
    label.ColSpan = 3*[col col] - [2 2];


    button.RowSpan = [row row];
    button.ColSpan = 3*[col col] - [1 1];
    button.Type = 'pushbutton';
    button.Name = '';
    button.BackgroundColor = get_ddg_color(h.getColor(type));
    button.MinimumSize = [70 35];
    button.MaximumSize = [70 35];
    
    button.MatlabMethod = 'sf';
    button.MatlabArgs = {'Private', 'pickcolor', '%dialog', '%source', type};

    blcell = {button, label};
    