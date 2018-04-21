% script to retrieve OpenFOAM full p and U data
% interpolation is an option
% WARNING! YOU MUST FIRST DO THE FOLLOWING:
% run "writeCellCentres -latestTime" in the command line of the run
% directory (if OpenFOAM 4)
% run "postProcess -fun writeCellCentres -latestTime" in the command line
% of the run directory (OpenFOAM 5)


clc; clear all

%times to retrieve data from
times = 56.2:0.1:56.2;
dx = 0.0002; % interpolated grid spacing
option = 0; % 1 = interpolate, 0 = no interpolate
% if we do not interpolate, then the data will be left as matrices with the
% row corresponding to a specific x,y,z location (same row index in the
% x,y,z column vectors) and each column is a particular time

directory = '/Users/soda/OpenFOAM/couette/Re100/'; % the run directory which contains all the data
positionTime = times(end); % this is which time (folder) the cell centre files are located
% below we import the cell center locations in x, y and z
% in OpenFOAM 4, the cell centres are named "ccx", etc. with 22 header rows
% in OpenFOAM 5, the cell centres are named "Cx", etc. with 23 header rows
x = importdata([directory num2str(round(positionTime,4,'decimals')) '/ccx'],'\n',22);
x = x.data;
y = importdata([directory num2str(round(positionTime,4,'decimals')) '/ccy'],'\n',22);
y = y.data;
z = importdata([directory num2str(round(positionTime,4,'decimals')) '/ccz'],'\n',22);
z = z.data;

% initializing the variables will depend on whether we are going to
% interpolate or not the potentially unevenly spaced data
if option == 1
    [X,Y] = meshgrid([min(x):dx:max(x)],[min(y):dx:max(y)]);
    Xi = reshape(X,[length(X(:,1))*length(X(1,:)) 1]);
    Yi = reshape(Y,[length(Y(:,1))*length(Y(1,:)) 1]);
    u = zeros([size(X) length(times)]);
    v = zeros([size(X) length(times)]);
    w = zeros([size(X) length(times)]);
    p = zeros([size(X) length(times)]);
elseif option == 0
    u = zeros([length(x) length(times)]);
    v = zeros([length(x) length(times)]);
    w = zeros([length(x) length(times)]);
    p = zeros([length(x) length(times)]);
end

% for loop to import the data
for q = 1:length(times)
    
    disp(['t = ' num2str(times(q))]);
    
    % velocity
    fileID = fopen([directory num2str(times(q)) '/U'],'r');
    U = textscan(fileID,'%f %f %f',length(x),'headerlines',22,...
        'delimiter',' ()','collectoutput',1,'multipledelimsasone',true);
    fclose(fileID);
    U = cell2mat(U);
    if option == 1
    % interpolate velocity
        FU = scatteredInterpolant(x,y,U(:,1));
        Ui = FU(Xi,Yi);
        u(:,:,q) = reshape(Ui,size(X));
        FV = scatteredInterpolant(x,y,U(:,2));
        Vi = FV(Xi,Yi);
        v(:,:,q) = reshape(Vi,size(X));
    elseif option == 0
        u(:,q) = U(:,1);
        v(:,q) = U(:,2);
        w(:,q) = U(:,3);
    end
    
    % pressure
    fileID = fopen([directory num2str(times(q)) '/p'],'r');
    P = textscan(fileID,'%f',length(x),'headerlines',22,...
        'delimiter',' ()','collectoutput',1,'multipledelimsasone',true);
    fclose(fileID);
    P = cell2mat(P);
    if option == 1
        % interpolate
        FP = scatteredInterpolant(x,y,P);
        Pi = FP(Xi,Yi);
        p(:,:,q) = reshape(Pi,size(X));
    elseif option == 0
        p(:,q) = P;
    end
    
end