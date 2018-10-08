clear all;clc;close all;
%% %%%%%%%%%%%%%%%%%% Main Program  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load the Original Network Connection List Data, and Transfer the Connection List to Adjacent Matrix
% Input: Connection List
% Output: Adjacent Matrix
%   Cele1 = load('dataSet/sf-25-1.txt');%Import the network data, Connection List
% Cele1 = load('dataSet/sf-50.txt');%Import the network data, Connection List
Cele1 = load('dataSet/karate.txt');%Import the network data, Connection List
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
Length=0.4; % data ratio
classNumber = 2;% clustering class number

%% Get the Evolutionary Game Data, Including the Strategies and Unity
[Stra,Unity] = Game(Adj,b);

%%  clustering G(or A), to explore the group porperty of X
[res_cell, centroid, bigDegreeSet] = FunK_meanPolyD(Unity,classNumber,Length);%  kæ˘÷µæ€¿‡    

%% Reconstruct the Network Structure Based on the Evolutionary Game Data
% % compressive sensing l1-norm
Index=0;
Adj_Re_comp = Net_Construction(Stra,Unity,bigDegreeSet,Index,Length,b);
adj=reshape(Adj,SIZE*SIZE,1);
adj_Re=reshape(Adj_Re_comp,SIZE*SIZE,1);
accuracy_compressiveSensing = EvaluationFcn(adj_Re,adj);
prec_rec(adj_Re,adj,'holdFigure', 1); %ROC and PR

% CBM 
Index=2;
Adj_Re_ADMMBOX = Net_Construction(Stra,Unity,bigDegreeSet,Index,Length,b);
adj=reshape(Adj,SIZE*SIZE,1);
adj_Re=reshape(Adj_Re_ADMMBOX,SIZE*SIZE,1);
accuracy_ADMM_BOX = EvaluationFcn(adj_Re,adj);
prec_rec(adj_Re,adj,'holdFigure', 2); %ROC and PR

%% Adjust the curves
set(gcf,'color','w');
legend('Baseline','CST','CBM');




