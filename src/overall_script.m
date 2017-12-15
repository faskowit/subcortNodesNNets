%% master script
% Josh Faskowitz, 2017
% 
% Code for final project in class. Make sure you have the Brain Connectvity
% Toolbox in your path if you want this stuff to work. Note, the methods
% here were a quick n' dirty proof-of-concept and do not represent the
% optimal analysis. There is external code, hopefully I followed all the
% licenses. See LICENSE for the license here. 
%

clearvars
clc

projectDir = '/home/jfaskowi/JOSHSTUFF/sandbox/subcortTrkProj/' ;
addpath(genpath(strcat(projectDir)));

% ADD path to latest version of BCT here!!
% 

%% read data
% for both parcellations

read_data(projectDir,'68');
read_data(projectDir,'150');

%% extreact network data

netStats150 = extract_data(projectDir,'150');
netStats68 = extract_data(projectDir,'68');

%% analyze data

analyze_data(projectDir,'150',netStats150);
analyze_data(projectDir,'68',netStats68);

analyze_data2(projectDir,'150',netStats150);
analyze_data2(projectDir,'68',netStats68);

%% done, there should be pics in the results folder