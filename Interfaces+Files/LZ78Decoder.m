function [x,dict]=LZ78Decoder(y,N)
% [x,dict]=LZ78Decoder(y,N)
% Decode a cell array y, which is the output of the LZ78Encoder function.

x=[];
if nargin<1
    disp('At least one argument is needed!');
    return;
end

if nargin<2
    N=0; % The dictionary will grow without any limit.
end

if N>0
    dict=cell(1,N);
else
    dict={};
end
dict_i=0;

y_n=size(y,1);
x_i=0;
for i=1:y_n
    if y{i,1}>0
        dict_entry=dict{y{i,1}};
        x=[x dict_entry];
        x_i=x_i+numel(dict_entry);
    else
        dict_entry=[];
    end
    if isempty(y{i,2}) % Must be the end of message.
        break;
    else
        x_i=x_i+1;
        x(x_i)=y{i,2};
    end
    if (N<=0 || dict_i<N)
        dict_i=dict_i+1;
        dict{dict_i}=[dict_entry y{i,2}];
    end
end
if N>0
    dict(dict_i+1:end)=[]; % Remove unused elements in dict.
end
