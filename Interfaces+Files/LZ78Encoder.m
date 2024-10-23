function [y,dict]=LZ78Encoder(x,N)
% [y,dict]=LZ78Encoder(x)
% Encode an input message x with LZ78 dictionary-based coding.
% x is treated as a 1-D signal.
% N is the maximal size of the dictionary (default = 0: the dictionary can
% grow without any limit).

y=[];
dict=[];

if nargin<1
    disp('At least one argument is needed!');
    return;
end

if nargin<2
    N=0; % The dictionary will grow without any limit.
end

x=x(:)'; % Transform x into a row vector.
x_n=numel(unique(x));

if N>0
    if N<x_n
        disp('The dictionary size has to be larger than the number of distinct characters in x!');
        return;
    end
    dict=cell(1,N);
else
    dict={};
end

y_i=0;
dict_i=0;
while 1
    n=numel(x);
    index=0;
    % Find the longest segment of symbols in the dictionary.
    for i=1:n
        index1=IsInDict(x(1:i),dict);
        if index1==0 % If x(1:i) is not in the dictionary.
            if (N<=0 || dict_i<N) % If the dictionary size does not have a limit or if the limit has not been reached.
                dict_i=dict_i+1;
                dict{dict_i}=x(1:i); % Expand the dictionary.
            end
            x(1:i-1)=[]; % Remove encoded symbols.
            break;
        else
            index=index1; % Record the last found index.
        end
    end
    
    y_i=y_i+1;
    y{y_i,1}=index;
    if (index1>0 || isempty(x)) % If index1>0, the end of message has been reached.
        y{y_i,2}=[];
        break;
    else
        y{y_i,2}=x(1);
        x=x(2:end);
        if isempty(x)
            break;
        end
    end
end
if N>0
    dict(dict_i+1:end)=[]; % Remove unused elements in dict.
end
