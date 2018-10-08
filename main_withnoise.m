clear all;clc;close all;
%% %%%%%%%%%%%%%%%%%% Main Program  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load the Original Network Connection List Data, and Transfer the Connection List to Adjacent Matrix
% Input: Connection List
% Output: Adjacent Matrix
%  Cele1 = load('dataSet/sf-25-1.txt');%Import the network data, Connection List
Cele1 = load('dataSet/sf-50.txt');%Import the network data, Connection List
% Cele1 = load('dataSet/karate.txt');%Import the network data, Connection List
% Cele1 = load('dataSet/adjnoun.txt');%Import the network data, Connection List

SIZE = max(max(Cele1(:,1)),max(Cele1(:,2)));
Adj = zeros(SIZE,SIZE);% Get the Size of Adjacent Matrix
% Transfer the Connection List to Adjacent Matrix
for i=1:size(Cele1)
    a=Cele1(i,1);
    b=Cele1(i,2);
    Adj(a,b)=Cele1(i,3);
    Adj(b,a)=Cele1(i,3);   %zhang karate dataset
end
% diag(Adj)=1, self-interaction
for i=1:SIZE
     Adj(i,i)=1;
end

%% set parameters
b=1.2; % Define the game parameter
amp = 0.12;   % Define the amplifier of noise;
Length=0.4; % data ratio
classNumber = 2;% clustering class number
   
%% Get the Evolutionary Game Data, Including the Strategies and Unity
[Stra,Unity] = Game_withnoise(Adj,b,amp);
%%  clustering G(or A), to explore the group porperty of X
[res_cell, centroid, bigDegreeSet] = FunK_meanPolyD(Unity,classNumber,Length);

%% Reconstruct the Network Structure Based on the Evolutionary Game Data
%%        %compressive sensing LASSO
Index=1;
Adj_Re = Net_Construction(Stra,Unity,bigDegreeSet,Index,Length,b);
adj=reshape(Adj,SIZE*SIZE,1);
adj_Re=reshape(Adj_Re,SIZE*SIZE,1);
prec_rec(adj_Re,adj,'holdFigure', 1); %ROC and PR


%%        % LASSO box constraint
Index=3;
Adj_Re = Net_Construction(Stra,Unity,bigDegreeSet,Index,Length,b);
adj=reshape(Adj,SIZE*SIZE,1);
adj_Re=reshape(Adj_Re,SIZE*SIZE,1);
prec_rec(adj_Re,adj,'holdFigure', 2); %ROC and PR
%% Adjust the curves
set(gcf,'color','w');
legend('Baseline','CST','CBM');




