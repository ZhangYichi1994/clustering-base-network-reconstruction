%% Network structure construction based on the strategies and unity data
% Input: Stra--strategies data; Unity--unity data
% Input:  Index--0-3
% Input:  Length--the length of data, Length*SIZE
% Input:  b--coefficient of game model 
% Output: Adj--Reconstructed Adjacent Matrix; 
function Adj=Net_Construction(Stra,Unity,bigDegreeSet,Index,Length,b)
    SIZE = size(Stra,1);
    Adj = zeros(SIZE,SIZE);    
    %% calculate U=Fai*x
    Length1 = floor(Length*SIZE);
    Unity_temp = Unity(:,1:Length1);
    Unity_use=reshape(Unity_temp', Length1*SIZE,1);% calculate Unity
    Stra_temp = Stra(:,1:Length1);
    
    Stra_use=zeros(Length1*SIZE,SIZE*SIZE);    
    for k=1:SIZE
        TEMP=zeros(Length1,SIZE);
        player1=k;
        for t = 1:Length1 
            stra_player1=Stra_temp(player1,t);
            for i=1:SIZE
                player2=i;
                stra_player2=Stra_temp(player2,t);
                TEMP(t,i)=Payoff(stra_player1,stra_player2,b);
            end
        end
        aa=(k-1)*Length1;
        bb=(k-1)*SIZE;
        for row = 1:Length1
            for col = 1:SIZE                
                Stra_use(aa+row,bb+col)= TEMP(row,col); % get Fai
            end
        end       
    end   

    %%  traditional compressive sensing---l1 norm 
    if (Index==0)
        for i = 1:SIZE
            payoffTemp = Unity_temp(i,1:Length1);
            payoffTemp = payoffTemp';   % get Y
			player1 = i;
            for t = 1:Length1 
                stra_player1=Stra_temp(player1,t);
                for j=1:SIZE
                    player2=j;
                    stra_player2=Stra_temp(player2,t);
                    TEMP(t,player2)=Payoff(stra_player1,stra_player2,b);
                end
            end
            straTemp = TEMP;            % get phi           
            cvx_begin
                variable x(SIZE);
                minimize(norm(x,1))
                subject to 
                payoffTemp == straTemp * x;
            cvx_end           
            Adj(:,i) = x;
        end
    end    
   %% traditional compressive sensing with noise	-	LASSO
    if (Index==1)
        for i = 1:SIZE
            payoffTemp = Unity_temp(i,1:Length1);
            payoffTemp = payoffTemp';   % get Y
			player1 = i;
            for t = 1:Length1 
                stra_player1=Stra_temp(player1,t);
                for j=1:SIZE
                    player2=j;
                    stra_player2=Stra_temp(player2,t);
                    TEMP(t,player2)=Payoff(stra_player1,stra_player2,b);
                end
            end
            straTemp = TEMP;            % get phi           
            cvx_begin
                variable x(SIZE);
                minimize(0.0001*norm(x,1)+0.5*norm(payoffTemp - straTemp*x,2));
            cvx_end          
            Adj(:,i) = x;
        end
    end
%% CBM
    if(Index == 2)   
        [x history1] = basis_pursuit_box(Stra_use,Unity_use,1,1);
        Adj=reshape(x,SIZE,SIZE);
        for i = 1:size(bigDegreeSet,2)        %find the big degree set and replace the unreliable value
            dot = bigDegreeSet(i);
            for j = 1:SIZE             
                whetherFind = find(bigDegreeSet == j);
                if (isempty(whetherFind))             % neighbor is a hub node
                    Adj(dot,j) = Adj(j,dot);
                end
            end
        end
    end   
%% CBM with noise
    if(Index == 3)
        [x history] = lasso_box(Stra_use,Unity_use,0.0001,1,1);
        Adj=reshape(x,SIZE,SIZE);
        for i = 1:size(bigDegreeSet,2)        %find the big degree set and replace the unreliable value
            dot = bigDegreeSet(i);
            for j = 1:SIZE             
                whetherFind = find(bigDegreeSet == j);
                if (isempty(whetherFind))             % neighbor is a hub node
                    Adj(dot,j) = Adj(j,dot);
                end
            end
        end
    end
end

