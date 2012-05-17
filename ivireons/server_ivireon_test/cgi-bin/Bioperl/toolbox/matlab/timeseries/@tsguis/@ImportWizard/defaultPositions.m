function defaultPositions(h)
% DEFAULTPOSITION defines the excel sheet import GUI relative positions

% Author: Rong Chen 
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2006/12/20 07:18:42 $

% -------------------------------------------------------------------------
% standard
% -------------------------------------------------------------------------
h.DefaultPos.heightbtn=23;
h.DefaultPos.heightradio=18;
h.DefaultPos.heighttxt=18;    
h.DefaultPos.heightcomb=18;    
h.DefaultPos.heightedt=21;    
h.DefaultPos.separation=5;%10

% -------------------------------------------------------------------------
% initialize the main figure window size based on the current screen
% size used by the monitor.  ratio is used to define the figure window.
% -------------------------------------------------------------------------
h.DefaultPos.leftratio=0.4;
h.DefaultPos.bottomratio=0.3;
h.DefaultPos.widthratio=0.2;
h.DefaultPos.heightratio=0.4;
h.ScreenSize=get(0,'ScreenSize');
h.DefaultPos.Figure_leftoffset=max(0,h.ScreenSize(3)/2-400);%h.ScreenSize(3)*h.DefaultPos.leftratio;
h.DefaultPos.Figure_bottomoffset=max(0,h.ScreenSize(4)/2-300);%h.ScreenSize(4)*h.DefaultPos.bottomratio;
h.DefaultPos.Figure_width=750;%h.ScreenSize(3)*h.DefaultPos.widthratio;
h.DefaultPos.Figure_height=550;%h.ScreenSize(4)*h.DefaultPos.heightratio;
    
% -------------------------------------------------------------------------
%% set the parameters to determine the positions of the four buttons at the
%% bottom of the figure window
% -------------------------------------------------------------------------
h.DefaultPos.widthbtn=70;
%h.DefaultPos.leftoffsetOKbtn=max(1,h.DefaultPos.Figure_width-3*h.DefaultPos.widthbtn-2*h.DefaultPos.separation-30);
h.DefaultPos.leftoffsetBACKbtn=max(1,h.DefaultPos.Figure_width-4*h.DefaultPos.widthbtn-3*h.DefaultPos.separation-60);
h.DefaultPos.leftoffsetNEXTbtn=max(1,h.DefaultPos.Figure_width-3*h.DefaultPos.widthbtn-2*h.DefaultPos.separation-60);
h.DefaultPos.leftoffsetCANCELbtn=max(1,h.DefaultPos.Figure_width-2*h.DefaultPos.widthbtn-h.DefaultPos.separation-30);
h.DefaultPos.leftoffsetHELPbtn=max(1,h.DefaultPos.Figure_width-h.DefaultPos.widthbtn-30);
h.DefaultPos.bottomoffsetbtn=10;

% -------------------------------------------------------------------------
% panels overall
% -------------------------------------------------------------------------
% left position and width are the same for all the panels
% bottom position and height are different for each panels
% lineup is for alignment of the controls
h.DefaultPos.leftoffsetpnl=10;      
h.DefaultPos.widthpnl=max(1,h.DefaultPos.Figure_width-2*h.DefaultPos.leftoffsetpnl);

% -------------------------------------------------------------------------
% panel: instruction
% -------------------------------------------------------------------------
h.DefaultPos.heightInstructionpnl=100;
h.DefaultPos.bottomoffsetInstructionpnl=h.DefaultPos.Figure_height-...
    h.DefaultPos.heightInstructionpnl-h.DefaultPos.separation;
h.DefaultPos.leftoffsetTXT=h.DefaultPos.separation+h.DefaultPos.separation;
h.DefaultPos.widthTXT=500;
h.DefaultPos.bottomoffsetTXT3=10;
h.DefaultPos.bottomoffsetTXT2=35;
h.DefaultPos.bottomoffsetTXT1=60;

% -------------------------------------------------------------------------
% panel: dynamic (step 2)
% -------------------------------------------------------------------------
h.DefaultPos.leftoffsetDynamicPnl=h.DefaultPos.leftoffsetpnl;
h.DefaultPos.buttomoffsetDynamicPnl=45;
h.DefaultPos.widthDynamicPnl=h.DefaultPos.widthpnl;
h.DefaultPos.heightDynamicPnl=h.DefaultPos.bottomoffsetInstructionpnl-h.DefaultPos.buttomoffsetDynamicPnl-h.DefaultPos.separation-8;

% -------------------------------------------------------------------------
% panel: option (step 3)
% -------------------------------------------------------------------------
% radio buttons
h.DefaultPos.RADIOoptionleftoffset=h.DefaultPos.separation+h.DefaultPos.separation;
h.DefaultPos.RADIOoptionbottomoffset_singleNew=h.DefaultPos.heightDynamicPnl+h.DefaultPos.buttomoffsetDynamicPnl-80;
h.DefaultPos.RADIOoptionbottomoffset_multipleNew=h.DefaultPos.heightDynamicPnl+h.DefaultPos.buttomoffsetDynamicPnl-110;
h.DefaultPos.RADIOoptionbottomoffset_singleINSERT=h.DefaultPos.heightDynamicPnl+h.DefaultPos.buttomoffsetDynamicPnl-140;
h.DefaultPos.RADIOoptionwidth = 225; %240
% multiple txt
h.DefaultPos.EDToptionleftoffset = h.DefaultPos.RADIOoptionleftoffset+...
    h.DefaultPos.RADIOoptionwidth+h.DefaultPos.separation;
h.DefaultPos.EDToptionwidth=150;%200
h.DefaultPos.TXToptionmultipleleftoffset=3;%10
h.DefaultPos.TXToptionmultiplewidth=75;%130 jgo
h.DefaultPos.EDToptionmultiplewidth=70;


