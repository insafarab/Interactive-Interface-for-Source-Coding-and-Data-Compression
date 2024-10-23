function EntropyCodeShow(code,P)
% EntropyCodeShow(code)
% Show an entropy code represented as a cell array, in which the first
% column stores the encoded symbols, the second one stores the
% corresponding codewords, and the third one stores the probabilities.
% When the third column does not exist (for example when code is the output 
% of the huffmandict function), the second argument will be used instead.

if nargin<1
    disp('At least one argument is needed!');
    return;
end

if ~iscell(code)
    disp('The input code must be a cell array!');
    return;
end
code_size=size(code);
if code_size(2)==1
    disp('The input code must have at least two columns!');
    return;
end
if (code_size(2)==2 && nargin>=2)
    P=reshape(P,numel(P),1); % Ensure P is a column vector.
    P(P==0)=[]; % Remove zero probabilities.
    P_size=numel(P);
    if P_size>code_size(1)
        disp('The number of probabilities must not exceed the number of codewords!');
        return;
    end
    if P_size<code_size(1)
        P=[P;zeros(code_size(1)-P_size,1)]; % Pad zeros at the end of P.
    end
    % Transform P to a column cell vector and then append it to code as the
    % third column.
    code(:,3)=num2cell(P/sum(P));
    code_size(2)=3;
end

if ischar(code{1,1})
    symbol_type='%s';
elseif isinteger(code{1,1})
	symbol_type='%d';
elseif isfloat(code{1,1})
    symbol_type='%g';
else
    disp('Unknown symbol type!');
    return;
end

fprintf(sprintf('X={%s',symbol_type),code{1,1});
for i=2:code_size(1)
    fprintf(sprintf(' %s',symbol_type),code{i,1});
end
fprintf('}\n');
% Estimate the codeword length variance.
code_l=zeros(1,code_size(1));
for i=1:code_size(1)
    code_l(i)=numel(code{i,2});
end
if code_size(2)>=3 % Show the probabilities only when P is given.
    fprintf('P=[%g',code{1,3});
    fprintf(' %g', cell2mat(code(2:end,3)));
    fprintf(']\n');
end
fprintf('\nHuffman code f:X->Y={0,1} (%d entries):\n',code_size(1));
m=size(code,1);
for i=1:m
    fprintf(sprintf('f(x(%d)) = f(%s) =',i,symbol_type),code{i,1});
    fprintf(' %d',code{i,2});
    fprintf('\n');
end
fprintf('\nMinimal codeword length = %d, maximal codeword length = %d.\n',...
    min(code_l),max(code_l));
if code_size(2)>=3 % Show the probabilities only when P is given.
    ACwL=0;
    for i=1:code_size(1)
        ACwL=ACwL+code{i,3}*code_l(i);
    end
    entropy_P=entropyMRS([code{:,3}]);
    fprintf('Average codeword length = %g, H(X) = %g, redudancy = %g.\n',...
        ACwL,entropy_P,ACwL-entropy_P);
    log2m=ceil(log2(m));
    fprintf('Compression ratio w.r.t. naive binary coding = %d/%g = %g.\n',log2m,ACwL,log2m/ACwL);
end
fprintf('Codeword length variance = %g.\n',var(code_l));
