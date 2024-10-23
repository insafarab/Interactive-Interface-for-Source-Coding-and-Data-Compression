%************************
%Huffman Coding Example
%
% By me 
%************************
%setup the MATLAB console
clc;
clear all;
close all;
%define the character string
Message='GSEII-DEUX ';
auto_prob=1;
if (auto_prob == 1)
    %Automatically calculate the probability distribution
    %Get ASCII version of each charachter
    %Each ASCII value represents the probability of finding the character
    prob = double (Message);
else
    %Manually define the probability distribution
    prob=[10 26 32 36 40 45 50 62];
end
num_bits=ceil(log2(length(prob)))
disp('Caractère probabilité');
for i=1:length(prob)
    display(strcat(Message(i),'-->',num2str(prob(i))));
end
total=sum(prob)
for i=1:length(Message)
    sorted_Msg{i}=Message(i);
end
%save initial set of symbols and probabilities for later use
init_Msg=sorted_Msg;
init_prob=prob;
sorted_prob=prob;
rear=1;
while(length(sorted_prob)>1)
    %Sort probs
    [sorted_prob, indeces]=sort(sorted_prob,'ascend');
    %sort string based on indeces
    sorted_Msg=sorted_Msg(indeces);
    %Create new Symbol
    new_node=strcat(sorted_Msg(2),sorted_Msg(1));
    new_prob=sum(sorted_prob(1:2));
    %Dequeue used symbols from "old" queue
    sorted_Msg=sorted_Msg(3:length(sorted_Msg));
    sorted_prob=sorted_prob(3:length(sorted_prob));
    % Add new symbol back to "old" queue
sorted_Msg = [sorted_Msg, new_node];
sorted_prob = [sorted_prob, new_prob];
    %Add new symbol to "new" queue
    newq_str(rear)=new_node;
    newq_prob(rear)=new_prob;
    rear=rear+1;
end
tree=[newq_str,init_Msg];
tree_prob=[newq_prob,init_prob];
%Sort all tree elements
[sorted_tree_prob,indeces]=sort(tree_prob,'descend');
sorted_tree=tree(indeces);
parent(1)=0;
num_children=2;
for i=2:length(sorted_tree)
    %Extract my symbol
    me =sorted_tree{i};
    %Find my parent's symbol(search until shortest macth is found)
    count=1;
    parent_maybe=sorted_tree{i-count};
    diff=strfind(parent_maybe,me);
    while(isempty(diff))
        count=count+1;
        parent_maybe=sorted_tree{i-count};
        diff=strfind(parent_maybe,me);
    end
    parent(i)=i-count;
end
treeplot(parent);
title(strcat('Arbre de codage de Huffman-"',Message,'"'));
display(sorted_tree)
display(sorted_tree_prob)
[xs,ys,h,s]=treelayout(parent);
text(xs,ys,sorted_tree);
for i=2:length(sorted_tree)
    %Get my coordinate
    my_x=xs(i);
    my_y=ys(i);
    %Get parent coordinate
    parent_x=xs(parent(i));
    parent_y=ys(parent(i));
    %calculate weight coordinate (midpoint)
    mid_x=(my_x+parent_x)/2;
    mid_y= (my_y + parent_y)/2;
    %Calculate weight (positive slope =1, negative =0)
    slope = (parent_y - my_y)/(parent_x - my_x);
    if (slope>0)
        weight(i)=1;
    else
        weight(i)=0;
    end
    text(mid_x,mid_y,num2str(weight(i)));
end
for i=1:length(sorted_tree)
    %initialize code
    code{i} = '';
    %loop until root is found
    index=i;
    p=parent(index);
    while(p~=0)
        %turn weight into code symbol
        w= num2str(weight(index));
        %concatenate code symbol
        code{i}=strcat(w,code{i});
        %continue toward root
        index=parent(index);
        p=parent(index);
    end
end
codeBook=[sorted_tree',code']