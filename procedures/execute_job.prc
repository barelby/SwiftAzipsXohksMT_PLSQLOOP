create or replace procedure execute_job(p_func VARCHAR2) is
    l_lock_handler  VARCHAR(128);
    l_lock_code     NUMBER;
BEGIN
    dbms_output.put_line('allocating');
    dbms_lock.allocate_unique(p_func, l_lock_handler);
    l_lock_code := dbms_lock.request(l_lock_handler, dbms_lock.x_mode, timeout => 0);
    dbms_output.put_line(l_lock_code);
    IF l_lock_code = 0 THEN
        dbms_output.put_line('Start job ' || p_func);
        EXECUTE IMMEDIATE 'begin '|| p_func ||'; end;';
        l_lock_code := dbms_lock.release(l_lock_handler);
    ELSE dbms_output.put_line('Job ' || p_func ||' not started - another instance is still runing');
    END IF;
    
END execute_job;
/
