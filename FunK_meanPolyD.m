%function [dotID groupNumber]=clustering()

function [res_cell, centroid, bigDegreeSet] = FunK_meanPolyD(data,k,length )
% input£º
%      data : m * n  ,m is data dimension, n is data amount
%      k : clustering class number
%       length: data length for used
% output£º
%     res_cell:  save the agents subscript
%¡¡¡¡ centroid : center of each class
    
    SIZE = size(data,1);
    length1 = floor(length*SIZE);
    dataTemp = data(:,1:length1);
    data = dataTemp;
    data = data';

    [dim,n] = size(data);
    seed = zeros(dim, k);
    oldSeed = zeros(dim, k);
    res = zeros(k,n);
    record = zeros(1,k);
    res_cell= cell(1,k);
    


%% initial seed, gurantee the seeds are different
    tt = zeros(1,k);
    for i = 1:k
        flag = 1;
        while flag
            t = round(rand()*n);
            flag = 0;
            for j = 1:k
                if t == tt(j)
                    flag = 1;
                    break;
                end
            end
        end
        tt(i) = t;
        seed(:,i) = data(:,t);
    end

%% go to kmeans convergence
    while 1
        record(:) = 0; 
        for i = 1:n 
            distMin = 1; 
            for j = 2:k
                a = dot(data(:,i)-seed(:,distMin),data(:,i)-seed(:,distMin));
                b = dot(data(:,i)-seed(:,j),data(:,i)-seed(:,j));
                if a > b
                    distMin = j;
                end
            end
            record(distMin) = record(distMin)+1;
            res(distMin,record(distMin)) = i;
        end

        oldSeed = seed;
        seed(:) = 0;
        for i = 1:k 
           for j = 1:record(i) 
              seed(:,i) = seed(:,i) + data(:,res(i,j));
           end
           seed(:,i) = seed(:,i)/record(i); 
        end
        if seed == oldSeed
            for i =1:k
               res_cell{1,i} = res(i,1:record(i)); 
            end
            centroid = seed;
            break; 
        end
    end
    
 %% find the class with small agents, this is the hub nodes set
    for i=2:k
        if  (size(cell2mat(res_cell(i-1)),2) < size(cell2mat(res_cell(i)),2))
            bigDegreeSet = cell2mat(res_cell(i-1));
        else
            bigDegreeSet = cell2mat(res_cell(i));
        end
    end

end