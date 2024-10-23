function [x,dict]=LZWDecoder(y,X,N)
% [x,dict]=LZWDecoder(y,X,N)
% Decode a sequence of indices as the output of LZWEncoder.
% N is the maximal size of the dictionary (default = 0: the dictionary can
% grow without any limit).

x=[];
dict={};
if nargin<2
    disp('At least two parameters are needed!');
    return;
end
if nargin<3
    N=0; % The dictionary will grow without any limit.
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
dict_i=X_n;

y_n=numel(y);

dict_entry_last=[];
if y(1)<=dict_i
    dict_entry_last=dict{y(1)}; % Set the first decoded entry.
    x=dict_entry_last; % The first symbol of the encoded message.
else % The first index in y must be in [1,dict_n].
    fprintf('Error: y(1)=%d > %d+1=%d!\n',y(1),dict_i,dict_i+1);
end
for i=2:y_n
    if y(i)>dict_i+1
        fprintf('Error: y(%d)=%d > %d+1=%d!\n',i,y(i),dict_i,dict_i+1);
        continue;
    end
    if (N<=0 || dict_i<N) % If the dictionary size does not have a limit or if the limit has not been reached.
        if y(i)<=dict_i % Normal decoding.
            dict{dict_i+1}=[dict_entry_last dict{y(i)}(1)]; % Update the dictionary.
        elseif y(i)==dict_i+1 % Special decoding.
            dict{dict_i+1}=[dict_entry_last dict_entry_last(1)]; % Update the dictionary.
        end
        dict_i=dict_i+1;
    end
    dict_entry_last=dict{y(i)}; % Update the last decoded entry.
    x=[x dict_entry_last]; % Expand the decoded message.
end
if N>0
    dict(dict_i+1:end)=[]; % Remove unused elements in dict.
end
