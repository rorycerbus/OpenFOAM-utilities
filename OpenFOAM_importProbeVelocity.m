% script to retrieve OpenFOAM p and U data and interpolate

clc; clear all

option = 1; % 0 is no interpolate, 1 is interpolate
directory = '/Users/soda/Documents/Physics/OpenFOAM/pipe/iris/Re3000_100D_probes/';
filename = 'U';
probes = 6; % (remember that OpenFOAM numbering starts from 0!)
% the probe output is a text file with N rows and M columns
% N = headers plus all the times
% M = number of probes times 3 plus 1 for time
% the following makes a string of '%f' to import each as floating point numbers
probestr = '%f %f %f %f'; % first is time
for i = 2:probes
    probestr = ([probestr ' %f %f %f']);
end

% import velocity
fileID = fopen([directory filename],'r');
U = textscan(fileID,probestr,'headerlines',probes+2,... %the number of headers is 2 plus a list of the probes
    'delimiter',' ()','collectoutput',1,'multipledelimsasone',true);
fclose(fileID);
U = cell2mat(U); % convert the cell to a matrix
t = U(:,1); % time is the first column
for i = 1:probes
    ux(:,i) = U(:,(i-1)*3+2); % x components
    uy(:,i) = U(:,(i-1)*3+3); % y component
    uz(:,i) = U(:,(i-1)*3+4); % z components
end

% remember that the times may be unequally spaced depending on the time
% control settings in controlDict
