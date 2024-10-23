function s=HuffmanFileSave(filename,x)
% s=HuffmanFileSave(filename,x)
% Losslessly compressed a sequence of integers x with Huffman coding and 
% save the encoded data in a file.

s=0;

if nargin<2
    disp('Two arguments are needed!');
    return;
end

if exist(filename,'file')
    button=questdlg('The target file exists! Do you really want to overwrite it?',...
        'Overwrite question','Yes','No','No');
    if strcmp(button,'No')
        return;
    end
end
fid=fopen(filename,'w');
if fid==-1
    disp('Failed to create a file for saving the compressed data!');
    return;
end

disp('Compressing data...');
x=double(x);
X=[min(x(:)):max(x(:))];
P=hist(x(:),X);
code=HuffmanCode(X,P);
y=EntropyEncoder(x,code);

disp('Writing data into file...');
try,
    y_size=size(y);
    fwrite(fid,numel(y_size),'uint8'); % Write the dimension of the data.
    fwrite(fid,y_size,'uint'); % Write the data size.
    
    symbols=[code{:,1}];
    n=numel(symbols);
    fwrite(fid,n,'uint'); % Write number of symbols.
    fwrite(fid,symbols,'uint'); % Write a list of symbols.
    for i=1:n
        fwrite(fid,numel(code{i,2}),'uint'); % Write a codeword length.
        fwrite(fid,code{i,2},'ubit1'); % Write a codeword.
    end
    
    fwrite(fid,[y{:}],'ubit1'); % Write the encoded data.
catch, ME
    fclose(fid);
    throw(ME);
end

s=ftell(fid);

fclose(fid);

disp('Writing data into file finished!');
