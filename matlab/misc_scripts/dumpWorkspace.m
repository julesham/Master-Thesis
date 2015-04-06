    ii = 1;
    while exist([filename,num2str(ii),'.mat'],'file') == 2 % If file exists
        ii = ii+1; 
    end % Don't Overwrite Existing File
    dateAndTime = datestr(now);
    save([filename,num2str(ii)]);