function opampdemo_figs(slidenum)
% Creates pictures for OPAMPDEMO demo. Save resulting
% figure as PNG file to include in demo.

%   Authors: A. DiVergilio
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/06/07 14:35:30 $

tag = '';

%---Common layout parameters
p = localParameters;
ax = gca;

%---Slides
switch slidenum
   case 1
      % Op amp drawing
      localCanvas(ax)
      delete(findobj(get(gcbf,'Children'),'flat','UserData','DeleteMe'));
      axis(ax,'equal');
      text('Parent',ax,'String','Ideal Op Amp','Position',[.5 .8],...
         'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle','Tag',tag);
      opamp('Parent',ax,'Position',[.2 .3 .6 .2],'FaceColor',[1 1 .9],'FontSize',p.fs2,'FontWeight',p.fw2,...
         'Name','a','ShowTerminals',1,'Label',{'Vp','Vn','Vo'},'Info2','Vo = a(Vp - Vn)','Tag',tag);

   case 2
      % Op amp w/ feedback
      localCanvas(ax)
      axis(ax,'equal'); set(ax,'XLim',[0 1.2],'YLim',[0 1.2],'visible','off');
      x = 0.7;
      y = 0.8;
      opamp('Parent',ax,'Position',[x-.6 y-.1 .6 .2],'FaceColor',[1 1 .9],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Name','a','Tag',tag);
      resistor('Parent',ax,'Position',[x-.30 y-.35],'Size',.25,'Tag',tag);
      text('Parent',ax,'String','R2','Position',[x-0.30+.2 y-.42],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center','Ver','top','Tag',tag);
      resistor('Parent',ax,'Position',[x-.45 y-.40],'Size',.25,'Angle',-90,'Tag',tag);
      text('Parent',ax,'String','R1','Position',[x-0.38 y-.40-.2],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle','Tag',tag);
      wire('Parent',ax,'XData',x+[-.75 -.6 NaN -.6 -.6 -.3 NaN -.45 -.45 NaN -.05 .05 .05 NaN 0 .2 NaN -.45 -.45],...
         'YData',y+[.1 .1 NaN -.1 -.35 -.35 NaN -.35 -.40 NaN -.35 -.35 0 NaN 0 0 NaN -.65 -.7],'Tag',tag);
      ground('Parent',ax,'Position',[x-.45 y-.70],'Size',.14,'Tag',tag);
      line('Parent',ax,'LineStyle','--','LineWidth',1,'Clipping','off',...
         'XData',x+[-.55 0 0 -.55 -.55],'YData',y+[-.68 -.68 -.25 -.25 -.68],'Tag',tag);
      text('Parent',ax,'String',' Feedback network, b(s)','Position',[x y-.6],...
         'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
      xx = x + [-.75 -.6 .2];
      yy = y + [.1 -.225 0];
      line('Parent',ax,'LineWidth',2,'LineStyle','none','Marker','o','MarkerSize',6,...
         'MarkerFaceColor','w','XData',xx([1 3]),'YData',yy([1 3]),'Tag',tag);
      text('Parent',ax,'String','Vp  ','Position',[xx(1) yy(1)],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String','Vn ', 'Position',[xx(2) yy(2)],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String','  Vo','Position',[xx(3) yy(3)],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);

   case {3,4}
      cla
      set(ax,'visible','off')
      if (slidenum==3)
         axis(ax,'equal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
      end
      y1 = 0.65;
      y2 = 0.15;
      x1 = -0.1;
      x2 = 1.04;
      rw1 = .74;
      rw2 = .4;
      xstart = x1-.1;
      xend = x2+.15;
      sumblock('Parent',ax,'Position',[x1 y1],'Radius',p.sbr,'LabelRadius',3*p.sbr,'Tag',tag);
      sysblock('Parent',ax,'Position',[(x2+x1)/2-rw1/2 y1-.15 rw1 .30],...
         'Name','op amp, a(s)','Numerator','a_{0}','Denominator','(1+s/\omega_{1})(1+s/\omega_{2})',...
         'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
      sysblock('Parent',ax,'Position',[(x2+x1)/2-rw2/2 y2-.15 rw2 .30],...
         'Name','feedback network, b(s)','Numerator','R1','Denominator','R1 + R2',...
         'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
      wire('Parent',ax,'XData',[xstart x1-p.sbr],         'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[x1+p.sbr (x2+x1)/2-rw1/2],'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[(x2+x1)/2+rw1/2 xend],    'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[x2 x2 (x2+x1)/2+rw2/2],   'YData',[y1 y2 y2],      'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[(x2+x1)/2-rw2/2 x1 x1],   'YData',[y2 y2 y1-p.sbr],'ArrowSize',p.as,'Tag',tag);
      text('Parent',ax,'String','Vp ','Position',[xstart y1],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String','Vn ','Position',[x1 y2],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String',' Vo','Position',[xend y1],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);
      if (slidenum==9)
         text('Parent',ax,'String',{'Vo/Vp = 10','(dc)'},'Position',[x2+.05 y1+.14],...
            'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','middle','Tag',tag);
         text('Parent',ax,'String',{'R1 = 10000','R2 = 90000'},'Position',[x2-.18 y2-.14],...
            'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
      end

   case 5
      % With lead compensator
      localCanvas(ax)
      axis(ax,'equal'); set(ax,'XLim',[0 1.2],'YLim',[-.1 1.1]);
      x = 0.8;
      y = 0.8+.08;
      dd = 0.2;
      text('Parent',ax,'Position',[x-1 y-.3],'String',{'Feedback','Lead','Compensation'},...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Color',[.8 0 0],'Hor','center','Ver','middle','Tag',tag);
      opamp('Parent',ax,'Position',[x-.6 y-.1 .6 .2],'FaceColor',[1 1 .9],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Name','a','Tag',tag);
      capacitor('Parent',ax,'Position',[x-.30 y-.35+.02],'Size',.25,'Color',[.8 0 0],'Tag',tag);
      text('Parent',ax,'String','C','Position',[x-0.30+.2 y-.42+.02],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Color',[.8 0 0],'Hor','center','Ver','top','Tag',tag);
      resistor('Parent',ax,'Position',[x-.30 y-.35-dd],'Size',.25,'Tag',tag);
      text('Parent',ax,'String','R2','Position',[x-0.30+.2 y-.42-dd],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center','Ver','top','Tag',tag);
      resistor('Parent',ax,'Position',[x-.45 y-.40-dd],'Size',.25,'Angle',-90,'Tag',tag);
      text('Parent',ax,'String','R1','Position',[x-0.38 y-.40-.2-dd],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle','Tag',tag);
      wire('Parent',ax,'XData',x+[-.75 -.6 NaN -.6 -.6 -.3 NaN -.45 -.45 NaN -.05 .05+.05 .05+.05 NaN 0 .2+.05 NaN -.45 -.45],...
         'YData',y+[.1 .1 NaN -.1 -.35-dd -.35-dd NaN -.35-dd -.40-dd NaN -.35-dd -.35-dd 0 NaN 0 0 NaN -.65-dd -.7-dd],'Tag',tag);
      wire('Parent',ax,'Color',[.8 0 0],'XData',x+[-.35 -.35 -.3 NaN -.05 0 0],...
         'YData',y+[-.35-dd -.35+.02 -.35+.02 NaN -.35+.02 -.35+.02 -.35-dd],'Tag',tag);
      ground('Parent',ax,'Position',[x-.45 y-.70-dd],'Size',.14,'Tag',tag);
      line('Parent',ax,'LineStyle','--','LineWidth',1,...
         'XData',x+[-.55 0.05 0.05 -.55 -.55],'YData',y+[-.68-dd -.68-dd -.25 -.25 -.68-dd],'Tag',tag);
      text('Parent',ax,'String',' Feedback network, b(s)','Position',[x+.05 y-.6-dd],...
         'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
      xx = x + [-.75 -.6 .2+.05];
      yy = y + [.1 -.225-dd 0];
      line('Parent',ax,'LineWidth',2,'LineStyle','none','Marker','o',...
         'MarkerSize',6,'MarkerFaceColor','w','XData',xx([1 3]),'YData',yy([1 3]),'Tag',tag);
      text('Parent',ax,'String','Vp  ','Position',[xx(1) yy(1)],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String','Vn ', 'Position',[xx(2) yy(2)],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String','  Vo','Position',[xx(3) yy(3)],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);

   case 6
      % Block diagram
      cla
      axis(ax,'equal'); set(ax,'XLim',[0 1],'YLim',[-.1 1]);
      y1 = 0.65;
      y2 = 0.15;
      x1 = -0.0;
      x2 = 1.04;
      rw1 = .74;
      rw2 = .56;
      xstart = x1-.2;
      xend = x2+.15;
      sumblock('Parent',ax,'Position',[x1 y1],'Radius',p.sbr,'LabelRadius',3*p.sbr,'Tag',tag);
      sysblock('Parent',ax,'Position',[(x2+x1)/2-rw1/2 y1-.15 rw1 .30],...
         'Name','op amp, a(s)','Numerator','a_{0}','Denominator','(1+s/\omega_{1})(1+s/\omega_{2})',...
         'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
      sysblock('Parent',ax,'Position',[(x2+x1)/2-rw2/2 y2-.15 rw2 .30],...
         'Name',{'feedback network,','b(s)'},'Gain','K ','Numerator','1 + \tau_{z} s','Denominator','1 + \tau_{p} s',...
         'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
      wire('Parent',ax,'XData',[xstart x1-p.sbr],         'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[x1+p.sbr (x2+x1)/2-rw1/2],'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[(x2+x1)/2+rw1/2 xend],    'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[x2 x2 (x2+x1)/2+rw2/2],   'YData',[y1 y2 y2],      'ArrowSize',p.as,'Tag',tag);
      wire('Parent',ax,'XData',[(x2+x1)/2-rw2/2 x1 x1],   'YData',[y2 y2 y1-p.sbr],'ArrowSize',p.as,'Tag',tag);
      text('Parent',ax,'String','Vp ','Position',[xstart y1],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String','Vn ','Position',[x1 y2],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
      text('Parent',ax,'String',' Vo','Position',[xend y1],...
         'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);
      text('Parent',ax,'String',{'K_{ } = R1 / (R1 + R2)','\tau_{z} = R2 \cdot C','\tau_{p} = K \cdot \tau_{z}'},...
         'Position',[x2-.2 y2-.19],'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);

   case 7
      % LTI array
      cla
      x1 = .3;
      y1 = 0;
      dx = .03;
      dy = .03;
      w = .6;
      h = .6;
      text('Parent',ax,'Position',[x1-2.5*dx+w/2 0.8],'String','LTI Model Array:  b\_array(s)',...
         'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','bottom','Tag',tag);
      sysblock('Parent',ax,'Position',[x1-4*dx y1+4*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
      sysblock('Parent',ax,'Position',[x1-3*dx y1+3*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
      sysblock('Parent',ax,'Position',[x1-2*dx y1+2*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
      sysblock('Parent',ax,'Position',[x1-1*dx y1+1*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
      sysblock('Parent',ax,'Position',[x1-0*dx y1+0*dy w h],'FaceColor',[1 1 .9],'Tag',tag,...
         'Name','(n x 1 array)','Num','b\_array(:,:,n)','FontSize',p.fs1,'FontWeight',p.fw1);

end

%%%%%%%%%%%%%%%
% localCanvas %
%%%%%%%%%%%%%%%
function localCanvas(ax)
%---Reset axes properties for use as a drawing canvas
delete(findobj(allchild(ax),'flat','Serializable','on'));
reset(ax);
set(ax,'Visible','off',...%'XLim',[0 1],'YLim',[0 1],...
   'DefaultLineClipping','off','DefaultTextClipping','off','DefaultPatchClipping','off');

%%%%%%%%%%%%%%%%%%%
% localParameters %
%%%%%%%%%%%%%%%%%%%
function p_out = localParameters
%---Parameters/systems used in demo
persistent p;
if isempty(p)
   if ispc
      p.fs1 = 8;
      p.fs2 = 10;
      p.fs3 = 12;
   else
      p.fs1 = 10;
      p.fs2 = 12;
      p.fs3 = 14;
   end
   p.fw1 = 'normal';
   p.fw2 = 'bold';
   p.fw3 = 'bold';
   p.as = .05;  %---Arrow size
   p.sbr = .04; %---Sumblock radius
   %     p.s = tf('s');
   %     p.a0 = 1e5;
   %     p.w1 = 1e4;
   %     p.w2 = 1e6;
   %     p.R1 = 10e3;
   %     p.R2 = 90e3;
   %     p.Frequency1 = logspace(3,8,256);
   %     p.Time1 = [0:.01:1]*6e-4;
   %     p.Time2 = [0:.005:1]*1.0e-5;
   %     p.Time3 = [0:.005:1]*1.5e-6;
   %     p.a = p.a0/(1+p.s/p.w1)/(1+p.s/p.w2);
   %     p.a_norm = p.a/dcgain(p.a);
   %     p.b = p.R1/(p.R1+p.R2);
   %     p.A = feedback(p.a,p.b);
   %     p.L = p.a*p.b;
   %     p.S = feedback(1,p.L);
   %     p.K = p.R1/(p.R1+p.R2);
   %     p.C = [1:.2:3]*1e-12;
   %     for n = 1:length(p.C)
   %         b_array(:,:,n) = tf([p.K*p.R2*p.C(n) p.K],[p.K*p.R2*p.C(n) 1]);
   %     end
   %     p.b_array = b_array;
   %     p.A_array = feedback(p.a,p.b_array);
   %     p.L_array = p.a*p.b_array;
   %     [p.Gm,p.Pm,p.Wcg,p.Wcp] = margin(p.L_array);
   %     p.A_comp = p.A_array(:,:,6);
end
p_out = p;
