echo off
%   CASE STUDIES IN LINEAR SYSTEM IDENTIFICATION
%   *********************************************
%
%   In this selection of case studies we illustrate typical techniques
%   and useful tricks when dealing with various system identification
%   problems.
%   
%   Case studies:
%
%   1) A glass tube manufacturing process
%   2) Energizing a transformer
%
%   0) Quit
%
 
%   L. Ljung
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $ $Date: 2009/05/23 08:02:21 $


help cs
k = input('Select a case study number: ');
if isempty(k),k=3;end
if k == 0, return, end
if k==1, echodemo cs1, end
if k==2, echodemo cs2, end

