function defaultPositions(h)
% DEFAULTPOSITION defines the excel sheet import GUI relative positions

% Author: Rong Chen 
% Copyright 2005-2008 The MathWorks, Inc.

% Account for wide character widths
sfVector = hgconvertunits(h.Parent.Figure,[0 0 1 0],'Characters','Pixels',h.Parent.Figure);
if sfVector(3)>5
    charWidthScaleFactor = ceil(sfVector(3)/4);
else
    charWidthScaleFactor = 1;
end

% -------------------------------------------------------------------------
% standard
% -------------------------------------------------------------------------
h.DefaultPos.heightbtn = 23;
h.DefaultPos.heightradio = 18;
h.DefaultPos.heighttxt = 18;    
h.DefaultPos.heightcomb = 18;    
h.DefaultPos.heightedt = 21;    
h.DefaultPos.separation = 5; 

% -------------------------------------------------------------------------
% panels overall
% -------------------------------------------------------------------------
% left position and width are the same for all the panels
% bottom position and height are different for each panels
% lineup is for alignment of the controls
h.DefaultPos.leftoffsetpnl = 10;      
h.DefaultPos.widthpnl = h.Parent.DefaultPos.widthDynamicPnl;
h.DefaultPos.indent = 10;

% -------------------------------------------------------------------------
% panel: time
% -------------------------------------------------------------------------
% basic
h.DefaultPos.bottomoffsetTimepnl=h.DefaultPos.separation+35;
h.DefaultPos.heightTimepnl = 120;
% select sheet
h.DefaultPos.TXTtimeSheetleftoffset=h.DefaultPos.indent;
h.DefaultPos.TXTtimeSheetbottomoffset=75;
h.DefaultPos.TXTtimeSheetwidth = 125*charWidthScaleFactor;
h.DefaultPos.COMBtimeSheetleftoffset=h.DefaultPos.TXTtimeSheetleftoffset+h.DefaultPos.TXTtimeSheetwidth+h.DefaultPos.separation;
h.DefaultPos.COMBtimeSheetwidth = 180*charWidthScaleFactor;    
% panel: current sheet
% select column/row
h.DefaultPos.TXTtimeIndexleftoffset=h.DefaultPos.indent-5;
h.DefaultPos.TXTtimeIndexbottomoffset=37;
h.DefaultPos.TXTtimeIndexwidth = 125*charWidthScaleFactor;    
h.DefaultPos.COMBtimeIndexleftoffset=h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation;
h.DefaultPos.COMBtimeIndexwidth = 120*charWidthScaleFactor;    
h.DefaultPos.TXTtimeSheetFormatleftoffset = h.DefaultPos.COMBtimeIndexleftoffset+...
    h.DefaultPos.COMBtimeIndexwidth+h.DefaultPos.separation;
h.DefaultPos.TXTtimeSheetFormatbottomoffset=37;
h.DefaultPos.TXTtimeSheetFormatwidth = 60*charWidthScaleFactor;    
h.DefaultPos.COMBtimeSheetFormatleftoffset = h.DefaultPos.TXTtimeSheetFormatleftoffset+...
     h.DefaultPos.TXTtimeSheetFormatwidth+h.DefaultPos.separation;
h.DefaultPos.COMBtimeSheetFormatwidth=150*charWidthScaleFactor;    
% select column/row
h.DefaultPos.TXTtimeSheetStartleftoffset=h.DefaultPos.indent-5;
h.DefaultPos.TXTtimeSheetStartbottomoffset=5;
h.DefaultPos.TXTtimeSheetStartwidth = 125*charWidthScaleFactor;
h.DefaultPos.EDTtimeSheetStartleftoffset = h.DefaultPos.TXTtimeSheetStartleftoffset+...
    h.DefaultPos.TXTtimeSheetStartwidth+h.DefaultPos.separation;
h.DefaultPos.EDTtimeSheetStartwidth = 120*charWidthScaleFactor;    
h.DefaultPos.TXTtimeSheetEndleftoffset = h.DefaultPos.EDTtimeSheetStartleftoffset+...
    h.DefaultPos.EDTtimeSheetStartwidth+h.DefaultPos.separation;
h.DefaultPos.TXTtimeSheetEndbottomoffset=5;
h.DefaultPos.TXTtimeSheetEndwidth = 60*charWidthScaleFactor;
h.DefaultPos.EDTtimeSheetEndleftoffset = h.DefaultPos.TXTtimeSheetEndleftoffset+...
    h.DefaultPos.TXTtimeSheetEndwidth+h.DefaultPos.separation;
h.DefaultPos.EDTtimeSheetEndwidth = 150*charWidthScaleFactor;
h.DefaultPos.EDTtimeManualEndwidth = 40*charWidthScaleFactor;
h.DefaultPos.TXTtimeSheetIntervalleftoffset = h.DefaultPos.EDTtimeSheetEndleftoffset+...
    h.DefaultPos.EDTtimeSheetEndwidth;
h.DefaultPos.TXTtimeManualIntervalleftoffset = h.DefaultPos.EDTtimeSheetEndleftoffset+...
    h.DefaultPos.EDTtimeManualEndwidth;
h.DefaultPos.TXTtimeSheetIntervalbottomoffset=5;
h.DefaultPos.TXTtimeSheetIntervalwidth = 80*charWidthScaleFactor;
h.DefaultPos.TXTtimeManualIntervalwidth = 55*charWidthScaleFactor;
h.DefaultPos.EDTtimeSheetIntervalleftoffset = h.DefaultPos.TXTtimeSheetIntervalleftoffset+...
    h.DefaultPos.TXTtimeSheetIntervalwidth+h.DefaultPos.separation;
h.DefaultPos.EDTtimeManualIntervalleftoffset = h.DefaultPos.TXTtimeManualIntervalleftoffset+...
    h.DefaultPos.TXTtimeManualIntervalwidth+h.DefaultPos.separation;%jgo added
h.DefaultPos.EDTtimeSheetIntervalwidth = 50*charWidthScaleFactor;
h.DefaultPos.UNITtimeSheetIntervalleftoffset = h.DefaultPos.EDTtimeSheetIntervalleftoffset+...
    h.DefaultPos.EDTtimeSheetIntervalwidth+h.DefaultPos.separation;
h.DefaultPos.UNITtimeSheetIntervalwidth = 45*charWidthScaleFactor;    

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
h.DefaultPos.TXTdataSamplewidth = 125*charWidthScaleFactor; 
h.DefaultPos.COMBdataSampleleftoffset=h.DefaultPos.TXTdataSampleleftoffset+h.DefaultPos.TXTdataSamplewidth+h.DefaultPos.separation;
h.DefaultPos.COMBdataSamplewidth = 180*charWidthScaleFactor;    
% row/column range
h.DefaultPos.TXTdataleftoffset=h.DefaultPos.indent;
h.DefaultPos.TXTdatabottomoffset=10;
h.DefaultPos.TXTdatawidth = 125*charWidthScaleFactor;
h.DefaultPos.TXTfromleftoffset = h.DefaultPos.TXTdataleftoffset+...
    h.DefaultPos.TXTdatawidth+h.DefaultPos.separation;    
h.DefaultPos.TXTfromwidth = 70*charWidthScaleFactor;
h.DefaultPos.EDTfromleftoffset=h.DefaultPos.TXTfromleftoffset+h.DefaultPos.TXTfromwidth+h.DefaultPos.separation;    
h.DefaultPos.EDTfromwidth = 60*charWidthScaleFactor;
h.DefaultPos.TXTtoleftoffset=h.DefaultPos.EDTfromleftoffset+h.DefaultPos.EDTfromwidth+15;   
h.DefaultPos.TXTtowidth = 100*charWidthScaleFactor;   
h.DefaultPos.EDTtoleftoffset=h.DefaultPos.TXTtoleftoffset+h.DefaultPos.TXTtowidth+h.DefaultPos.separation;    
h.DefaultPos.EDTtowidth = 80*charWidthScaleFactor;

