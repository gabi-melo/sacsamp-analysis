function err = deg2range(err)  
    
    err(err>90) = err(err>90) - 180;
    err(err<-90) = err(err<-90) + 180;
    
end