function defaultPositions(h)
% DEFAULTPOSITION defines the excel sheet import GUI relative positions

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

% -------------------------------------------------------------------------
% standard
% -------------------------------------------------------------------------
h.DefaultPos.heightbtn=23;
h.DefaultPos.heightradio=18;
h.DefaultPos.heighttxt=18;    
h.DefaultPos.heightcomb=18;    
h.DefaultPos.heightedt=21;    
h.DefaultPos.separation=10;

% -------------------------------------------------------------------------
% panels overall
% -------------------------------------------------------------------------
% left position and width are the same for all the panels
% bottom position and height are different for each panels
% lineup is for alignment of the controls
h.DefaultPos.leftoffsetpnl=10;      
h.DefaultPos.widthpnl=h.Parent.DefaultPos.widthDynamicPnl;
h.DefaultPos.indent=10;

% -------------------------------------------------------------------------
% panel: time
% -------------------------------------------------------------------------
% basic
h.DefaultPos.bottomoffsetTimepnl=h.DefaultPos.separation+35;
h.DefaultPos.heightTimepnl=120;
% select sheet
h.DefaultPos.TXTtimeSheetleftoffset=h.DefaultPos.indent;
h.DefaultPos.TXTtimeSheetbottomoffset=75;
h.DefaultPos.TXTtimeSheetwidth = 125; %140 jgo   
h.DefaultPos.COMBtimeSheetleftoffset=h.DefaultPos.TXTtimeSheetleftoffset+h.DefaultPos.TXTtimeSheetwidth+h.DefaultPos.separation;
h.DefaultPos.COMBtimeSheetwidth=180;    
% panel: current sheet
% select column/row
h.DefaultPos.TXTtimeIndexleftoffset=h.DefaultPos.indent-5;
h.DefaultPos.TXTtimeIndexbottomoffset=37;
h.DefaultPos.TXTtimeIndexwidth = 125; %140 jgo    
h.DefaultPos.COMBtimeIndexleftoffset=h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation;
h.DefaultPos.COMBtimeIndexwidth=120;    
h.DefaultPos.TXTtimeSheetFormatleftoffset=h.DefaultPos.COMBtimeIndexleftoffset+...
    h.DefaultPos.COMBtimeIndexwidth+h.DefaultPos.separation;
h.DefaultPos.TXTtimeSheetFormatbottomoffset=37;
h.DefaultPos.TXTtimeSheetFormatwidth = 60;%80 jgo    
h.DefaultPos.COMBtimeSheetFormatleftoffset=h.DefaultPos.TXTtimeSheetFormatleftoffset+...
    h.DefaultPos.TXTtimeSheetFormatwidth+h.DefaultPos.separation;
h.DefaultPos.COMBtimeSheetFormatwidth=150;    
% select column/row
h.DefaultPos.TXTtimeSheetStartleftoffset=h.DefaultPos.indent-5;
h.DefaultPos.TXTtimeSheetStartbottomoffset=5;
h.DefaultPos.TXTtimeSheetStartwidth = 125; %140 jgo
h.DefaultPos.EDTtimeSheetStartleftoffset=h.DefaultPos.TXTtimeSheetStartleftoffset+...
    h.DefaultPos.TXTtimeSheetStartwidth+h.DefaultPos.separation;
h.DefaultPos.EDTtimeSheetStartwidth=120;    
h.DefaultPos.TXTtimeSheetEndleftoffset = h.DefaultPos.EDTtimeSheetStartleftoffset+...
    h.DefaultPos.EDTtimeSheetStartwidth+h.DefaultPos.separation;
h.DefaultPos.TXTtimeSheetEndbottomoffset=5;
h.DefaultPos.TXTtimeSheetEndwidth = 60;%80 jgo;     
h.DefaultPos.EDTtimeSheetEndleftoffset = h.DefaultPos.TXTtimeSheetEndleftoffset+...
    h.DefaultPos.TXTtimeSheetEndwidth+h.DefaultPos.separation;
h.DefaultPos.EDTtimeSheetEndwidth=150; 
h.DefaultPos.EDTtimeManualEndwidth = 40;%jgo added
h.DefaultPos.TXTtimeSheetIntervalleftoffset = h.DefaultPos.EDTtimeSheetEndleftoffset+...
    h.DefaultPos.EDTtimeSheetEndwidth;
h.DefaultPos.TXTtimeManualIntervalleftoffset = h.DefaultPos.EDTtimeSheetEndleftoffset+...
    h.DefaultPos.EDTtimeManualEndwidth;%jgo added
h.DefaultPos.TXTtimeSheetIntervalbottomoffset=5;
h.DefaultPos.TXTtimeSheetIntervalwidth=80; 
h.DefaultPos.TXTtimeManualIntervalwidth = 50;%jgo added
h.DefaultPos.EDTtimeSheetIntervalleftoffset = h.DefaultPos.TXTtimeSheetIntervalleftoffset+...
    h.DefaultPos.TXTtimeSheetIntervalwidth+h.DefaultPos.separation;
h.DefaultPos.EDTtimeManualIntervalleftoffset = h.DefaultPos.TXTtimeManualIntervalleftoffset+...
    h.DefaultPos.TXTtimeManualIntervalwidth+h.DefaultPos.separation;%jgo added
h.DefaultPos.EDTtimeSheetIntervalwidth=50;%60 jgo    
h.DefaultPos.UNITtimeSheetIntervalleftoffset=h.DefaultPos.EDTtimeSheetIntervalleftoffset+h.DefaultPos.EDTtimeSheetIntervalwidth+h.DefaultPos.separation;
h.DefaultPos.UNITtimeSheetIntervalwidth=45;    

% -------------------------------------------------------------------------
% panel: data
% -------------------------------------------------------------------------
% basic
h.DefaultPos.bottomoffsetDatapnl=h.DefaultPos.bottomoffsetTimepnl+h.DefaultPos.heightTimepnl+h.DefaultPos.separation;
h.DefaultPos.heightDatapnl=h.Parent.DefaultPos.bottomoffsetInstructionpnl-h.DefaultPos.bottomoffsetDatapnl-h.DefaultPos.separation;
% activex control positions
h.DefaultPos.activexoffset=10; % for right and bottom activex control
h.DefaultPos.activexleftoffset=h.DefaultPos.indent; % for left activex control
h.DefaultPos.activexbottomoffset=80; % for top activex control
h.DefaultPos.Table_leftoffset=h.DefaultPos.leftoffsetpnl+h.DefaultPos.activexleftoffset;
h.DefaultPos.Table_bottomoffset=h.DefaultPos.bottomoffsetDatapnl+h.DefaultPos.activexbottomoffset;
h.DefaultPos.Table_width=max(1,h.DefaultPos.widthpnl-h.DefaultPos.activexleftoffset-h.DefaultPos.activexoffset);
h.DefaultPos.Table_height=max(1,h.DefaultPos.heightDatapnl-h.DefaultPos.activexbottomoffset-2*h.DefaultPos.activexoffset);
% row/column selection
h.DefaultPos.TXTdataSampleleftoffset=h.DefaultPos.indent;
h.DefaultPos.TXTdataSamplebottomoffset=45;
h.DefaultPos.TXTdataSamplewidth = 125; %140 jgo    
h.DefaultPos.COMBdataSampleleftoffset=h.DefaultPos.TXTdataSampleleftoffset+h.DefaultPos.TXTdataSamplewidth+h.DefaultPos.separation;
h.DefaultPos.COMBdataSamplewidth=180;    
% row/column range
h.DefaultPos.TXTdatabottomoffset=10;
h.DefaultPos.TXTfromleftoffset=h.DefaultPos.indent;    
h.DefaultPos.TXTfromwidth=125; %140 jgo
h.DefaultPos.EDTfromleftoffset = h.DefaultPos.TXTfromleftoffset+...
    h.DefaultPos.TXTfromwidth+h.DefaultPos.separation;    
h.DefaultPos.EDTfromwidth=105; %140 jgo
h.DefaultPos.TXTtoleftoffset=h.DefaultPos.EDTfromleftoffset+h.DefaultPos.EDTfromwidth+25;%jgo 80;    
h.DefaultPos.TXTtowidth=100; %120 
h.DefaultPos.EDTtoleftoffset=h.DefaultPos.TXTtoleftoffset+h.DefaultPos.TXTtowidth+h.DefaultPos.separation;    
h.DefaultPos.EDTtowidth=120;

