function opampdemo_annotate(flag)
% Annotations for opampdemo

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $   $Date: 2005/06/27 22:31:02 $
switch flag
    case 1
        CC = [1 0 1];
        line('Parent',gca,'LineWidth',2,'Color',CC,'XData',[2e3 2e3],'YData',[25 95]);
        patch('Parent',gca,'EdgeColor',CC,'FaceColor',CC,'XData',[1.6e3 2e3 2.5e3],'YData',[40 25 40]);
        line('Parent',gca,'LineWidth',2,'Color',CC,'XData',[2e3 1e7],'YData',[10 10]);
        patch('Parent',gca,'EdgeColor',CC,'FaceColor',CC,'XData',[7e6 1e7 7e6],'YData',[2 10 18]);
        text('Parent',gca,'Position',[2e3 82],'String',' Reduced LF gain',...
            'Hor','left','Ver','top');
        text('Parent',gca,'Position',[1.3e5 24],'String','Increased system bandwidth',...
            'Hor','center','Ver','bottom');
        
    case 2
        text('Parent',gca,'Position',[2.4e-6 15],'String','Excessive ringing  \rightarrow  poor phase margin',...
            'Hor','left','Ver','middle');
    case 3
        CC = [1 0 1];
        ln = line('LineStyle','-','Color',CC,...
            'XData',[.25e-6 .32e-6],'YData',[12 5]);
        patch('EdgeColor',CC,'FaceColor',CC,...
            'XData',[.32e-6 .29e-6 .34e-6],'YData',[5 5.6 5.8]);
        text('Position',[.32e-6 4.9], 'String','   Increasing C',...
            'Color',CC,'Hor','center','Ver','top');
        text('Position',[.20e-6 13.2],'String','0 pF',...
            'Color',CC,'Hor','right','Ver','middle');
        text('Position',[.34e-6 12],  'String','1 pF',...
            'Color',CC,'Hor','center','Ver','bottom');
        text('Position',[.38e-6 7.8], 'String','3 pF',...
            'Color',CC,'Hor','left','Ver','top');
        set(gca,'Ylim',[0 14]);
        
    case 4
        text('Position',[2.2 58],'String','\leftarrow Peak Phase Margin @ C = 2pF',...
            'Hor','left','Ver','middle');
        
end