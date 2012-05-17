function [ax,un,yn] = getCurrentAxes(this)
% Return currently viewed axes for idnlhw plot

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/10/19 20:30:29

% current panel
str = this.getTag;
currentpanel = findobj(this.MainPanels,'type','uipanel','Tag',str);
un = []; yn = [];

switch lower(this.Current.Block)
    case 'input'
        un = this.Current.InputComboValue;
        if ~this.isGUI
            un = max(1,un-1);
        end
        ax = findobj(currentpanel,'type','axes','tag',['Input:',this.IONames.u{un}]);
    case 'output'
        yn = this.Current.OutputComboValue;
        if ~this.isGUI
            yn = max(1,yn-1);
        end
        ax = findobj(currentpanel,'type','axes','tag',['Output:',this.IONames.y{yn}]);
    case 'linear'
        Ind = this.Current.LinearComboValue;
        [uname,yname] = this.decipherIOPair(Ind);
        ax = findobj(currentpanel,'type','axes');
        %uname = this.IONames.u{un}; yname = this.IONames.y{yn};
        un = find(strcmp(this.IONames.u,uname));
        yn = find(strcmp(this.IONames.y,yname));

        Type = this.Current.LinearPlotTypeComboValue;
        switch Type
            case {1,3,4}
                ax_tag = [uname,':',yname];
                ax = findobj(ax,'tag',ax_tag);
            case 2
                magtag = ['Mag:',uname,':',yname];
                phasetag = ['Phase:',uname,':',yname];
                ax1 = findobj(ax,'tag',magtag);
                ax2 = findobj(ax,'tag',phasetag);
                ax = [ax1,ax2];
            otherwise
                ax = [];
        end
end
