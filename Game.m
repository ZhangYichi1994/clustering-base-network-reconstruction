%% Generate the evolutionary game data
% Input: Adjacent Matrx--Adj
% Output: Evolutionary game data--Stra and Unity
% Stra--Data of strategies, Stra(i,j)-the strategy of agent i in step j
% Unity--Data of fitness, Unity(i,j)-the fitness of agent i in step j

function [Stra,Unity] = Game(Adj,b)
N = size(Adj,1);% N is the number of nodes of network

Stra=[];
stra=(rand(N,1)>0.5)*1;% initial strategies distribute, cooperation and defection are same
Unity=[];%payoff
for T=1:4*N        %Round of game 
    for i=1:N
        player1=i;%Selecte one node i
        stra_player1=stra(player1);%Get i's strategy
        score1=0;
        Neig=[];
        for j=1:N
            if Adj(player1,j)==1
                Neig=[Neig,j];%Record the neighbors of player1
                player2=j;%Get its neighbor's stategy
                stra_player2=stra(player2);
                score1=score1+Payoff(stra_player1,stra_player2,b);%Get player1's payoff  
            end            
        end
        unity(i)=score1;
    end
    Unity=[Unity,unity'];%i collum is i rount all nodes' payoff
    
    Stra=[Stra,stra];
    for i=1:N        
        player1=i;
        stra_player1=stra(player1);
        Neig=[];
        for j=1:N
            if Adj(player1,j)==1
                Neig=[Neig,j];            
            end            
        end
        Neig_Size=size(Neig,2);% Node own degree
        Neig_rand0=randi(Neig_Size);
        Neig_rand=Neig( Neig_rand0);%Ramdomly select one neighbor         
        player11=Neig_rand;
        Neig1=[];
        for j=1:N
            if Adj(player11,j)==1
                Neig1=[Neig1,j];            
            end            
        end   
        Neig_Size1=size(Neig1,2);% Neighbor's degree
        stra_neig=stra(Neig_rand);
        if stra_neig~=stra_player1
            score1=unity(player1);
            score2=unity(Neig_rand);        
            dscore=score2-score1;
            fermi=dscore/b/max(Neig_Size,Neig_Size1);
            
            if(fermi>rand(1)) 
                stra_player1=stra_neig;
            end
            stra(i)=stra_player1;
        end    
    end
    
end
%%The above process is obtained at each moment, all individual's strategic matrix Stra, the income matrix Unity
end




