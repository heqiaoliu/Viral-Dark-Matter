function pdedemos
%PDEDEMOS  Set up PDE Toolbox Command-Line Demos. 
%   This GUI shows you how to solve some common PDE problems using the
%   Partial Differential Equation Toolbox functionality. 

%   Magnus Ringh, 11-Oct-1996.
%   Copyright 1994-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/23 14:04:02 $

labelList=str2mat( ...
    'Poisson''s equation',...
    'Helmholtz''s equation',...
    'Minimal surface problem',...
    'Domain decomposition',...
    'Heat equation',...
    'Wave equation',...
    'Adaptive solver',...
    'Fast Poisson solver');

nameList = [...
      'pdedemo1';
      'pdedemo2';
      'pdedemo3';
      'pdedemo4';
      'pdedemo5';
      'pdedemo6';
      'pdedemo7';
      'pdedemo8'];

cmdlnwin(labelList, nameList)

