function [y,dict]=LZWEncoder(x,X,N)
% [y,dict]=LZWEncoder(x,X,N)
% Encode an input message x with LZW compression algorithm.
% x is treated as a 1-D signal.
% X is the set of symbols.
% N is the maximal size of the dictionary (default = 0: the dictionary can
% grow without any limit).

y=[];
dict={};
if nargin<1
    disp('At least one argument is needed!');
    return;
end

x=x(:)'; % Transform x into a row vector.

if nargin<3
    N=0; % The dictionary will grow without any limit.
    if nargin<2
        X=unique(x);
    end
end

X_n=numel(X);
if N>0
    if N<X_n
        disp('The dictionary size has to be larger than the alphabet size!');
        return;
    end
    dict=cell(1,N);
end
dict(1:X_n)=num2cell(X); % Initialize dictionary to be X.

y=zeros(1,numel(x)); % Initialize y to be of the same size as x, in order to speedup the compression process.

y_i=0;
dict_i=X_n;
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
    y(y_i)=index; % Expand the output.
    if (index1>0 || isempty(x)) % If index1>0, the end of message has been reached.
        break;
    end
end
y(y_i+1:end)=[]; % Remove unused elements in y.
if N>0
    dict(dict_i+1:end)=[]; % Remove unused elements in dict.
end
