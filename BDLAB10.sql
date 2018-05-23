BEGIN
   DBMS_OUTPUT.ENABLE (1000);
END;

--polecenia ustalajace sekwencje
CREATE SEQUENCE EMPNOSEQ START WITH 208 INCREMENT BY 1;

--drop nie jest normalnie ustawiony
--DROP SEQUENCE EMPNOSEQ;

CREATE OR REPLACE PROCEDURE insertEMPLOYEE
(p_FIRST_NAME in VARCHAR, p_LAST_NAME in VARCHAR, p_EMAIL in VARCHAR, p_PHONE_NUMBER in NUMBER, p_HIRE_DATE IN DATE,
p_JOB_ID in VARCHAR, p_SALARY IN NUMBER, p_COMMISSION_PCT in NUMBER, p_MANAGER_ID in NUMBER, p_DEPARTMENT_ID IN NUMBER) is
empno NUMBER(6);
fname VARCHAR2(20);
lname VARCHAR2(25);
mail Varchar2(25);
Pnumb Varchar(20);
HDATE DATE;
JOBID Varchar(10);
JOBIDBUFFER number(6);
SAL NUMBER(8,2);
ComPCT NUMBER(2,2);
MANNO NUMBER(6);
MANNOBUFFER NUMBER(6);
DEPTNO NUMBER(4);
DEPTNOBUFFER NUMBER(6);

MIN_SAL NUMBER := null;
MAX_SAL NUMBER := null;

LAST_NAME_NOT_FOUND EXCEPTION;
EMAIL_NOT_FOUND EXCEPTION;
HIRE_DATE_WRONG EXCEPTION;
HIRE_DATE_NOT_FOUND EXCEPTION;
JOB_ID_NOT_EXISTS EXCEPTION;
JOB_ID_WRONG EXCEPTION;
WRONG_SALARY EXCEPTION;
MANAGER_ID_NOT_EXISTS EXCEPTION;
MANAGER_ID_WRONG EXCEPTION;
DEPARTMENT_ID_NOT_EXISTS EXCEPTION;

BEGIN
    --dla wpisania id pracownika
    SELECT EMPNOSEQ.nextval into empno from dual;
    
    --dla wyboru imienia
    IF p_FIRST_NAME is NOT NULL THEN
    fname := p_FIRST_NAME;
    else
    fname := null;
    END if;
    
    --dla wyboru nazwiska
    IF p_LAST_NAME is NOT NULL THEN
    lname:= p_LAST_NAME;
    ELSE
    RAISE LAST_NAME_NOT_FOUND;
    END IF;
    
    --dla numeru telefonu
    IF p_PHONE_NUMBER is NOT NULL THEN
    Pnumb := p_PHONE_NUMBER;
    ELSE
    Pnumb := null;
    END IF;
  
    --dla emaila - przy braku maila podnosi wyjatek
    IF p_EMAIL is NOT NULL THEN
    mail := p_EMAIL;
    ELSE
    RAISE EMAIL_NOT_FOUND;
    END IF;
  
    --dla daty zatrudnienia - przy jej braku lub wystapieniu przyszlej daty podnoszone wyjatki
    IF p_HIRE_DATE is NOT NULL THEN
        IF p_HIRE_DATE <= SYSDATE THEN
        HDATE := p_HIRE_DATE;
        ELSE
        RAISE HIRE_DATE_WRONG;
        END IF;
    ELSE 
    RAISE HIRE_DATE_NOT_FOUND;
    END IF;
    
     --dla kodu dzialu
    IF p_JOB_ID is NOT NULL THEN    
    
    SELECT COUNT(*) INTO JOBIDBUFFER FROM EMPS WHERE JOB_ID = p_JOB_ID;
    
    ELSE
    RAISE JOB_ID_NOT_EXISTS;
    END IF;
    
    IF JOBIDBUFFER = 0 THEN
        RAISE JOB_ID_WRONG;
    ELSE
        JOBID := p_JOB_ID;
    END IF;
    
    --dla pensji - jesli nie jest zerem sprawdza, czy w widelkach dla stanowiskach, jeslni nie ma, jest wyliczana srednia
    IF p_SALARY is NOT NULL THEN
        
        SELECT distinct(MAX(SALARY)) INTO MAX_SAL FROM EMPS WHERE JOB_ID = P_JOB_ID;
        SELECT distinct(MIN(SALARY)) INTO MIN_SAL FROM EMPS WHERE JOB_ID = P_JOB_ID;
        
        IF P_SALARY >= MIN_SAL AND P_SALARY <= MAX_SAL THEN
        SAL := p_SALARY;
        ELSE
        RAISE WRONG_SALARY;
        END IF;
    
    ELSE
        SELECT distinct(AVG(SALARY))into SAL FROM EMPS
        WHERE JOB_ID = p_JOB_ID;
    END IF;
    
    --commision pct
    IF p_COMMISSION_PCT IS NOT NULL THEN
    COMPCT := P_COMMISSION_PCT;
    ELSE
        COMPCT := null;
    END IF;
    
    --wybor kierownika
    IF P_MANAGER_ID IS NOT NULL THEN
        SELECT count(*) INTO MANNOBUFFER FROM EMPS
        WHERE MANAGER_ID = P_MANAGER_ID;

    ELSE
        RAISE MANAGER_ID_NOT_EXISTS;
    END IF;
    
    IF MANNOBUFFER<>0 THEN
        MANNO := P_MANAGER_ID;
    ELSE
        RAISE MANAGER_ID_WRONG;
    END IF;

    --dla wyboru dzialu
    IF p_DEPARTMENT_ID IS NOT NULL THEN

        SELECT count(*) INTO DEPTNOBUFFER FROM EMPS
        WHERE DEPARTMENT_ID = p_DEPARTMENT_ID;

    END IF;
    
    IF DEPTNOBUFFER <> 0 OR P_DEPARTMENT_ID = null THEN
        DEPTNO :=p_DEPARTMENT_ID;
    ELSE
        RAISE DEPARTMENT_ID_NOT_EXISTS;
    END IF;
    -- koniec sekcji wywolywania wyjatkow
    
    SET Transaction READ WRITE name 'insertEMPLOYEE';
     dbms_output.put_line('ustawil transakcje');
    INSERT INTO EMPS(EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID) VALUES(empno, fname, lname, mail, pnumb, HDATE, JOBID, SAL, COMPCT, MANNO, DEPTNO);
     dbms_output.put_line('wrzucil');
    commit;
    
    
    EXCEPTION
    WHEN DEPARTMENT_ID_NOT_EXISTS THEN
    dbms_output.put_line('Nie ma dzialu o takim numerze');
    WHEN MANAGER_ID_NOT_EXISTS THEN
    dbms_output.put_line('Nie podano managera');
    WHEN MANAGER_ID_WRONG THEN
    dbms_output.put_line('Nie ma managera o takim numerze');
    WHEN WRONG_SALARY THEN
    dbms_output.put_line('Pensja spoza zakresu dla tego stanowiska');
    WHEN JOB_ID_NOT_EXISTS THEN
    dbms_output.put_line('Nie wpisane stanowisko pracy');
    WHEN JOB_ID_WRONG THEN
    dbms_output.put_line('Podane nieistniejace stanowisko pracy');
    WHEN HIRE_DATE_NOT_FOUND THEN
    dbms_output.put_line('Nie ma daty zatrudnienia');
    WHEN HIRE_DATE_WRONG THEN
    dbms_output.put_line('Przyszla data zatrudnienia');
    WHEN EMAIL_NOT_FOUND THEN
    dbms_output.put_line('Brak adresu Email');
    WHEN LAST_NAME_NOT_FOUND THEN
    dbms_output.put_line('Brak Nazwiska');
    When OTHERS THEN
    dbms_output.put_line('Nieznany problem');
    
END;
/

--zbior testujacy

--prawidlowy rekord
begin
insertEMPLOYEE('bill', 'mitchell',  'bmitchell', '6492394093', '10/06/21', 'SA_REP', 8400, null, 145, 10); 
end;
/

--rekord bez nazwiska
begin
insertEMPLOYEE('bill', null,  'bbyford', '6492394093', '10/06/21', 'SA_REP', 8400, null, 145, 10); 
end;
/

--rekord bez maila
begin
insertEMPLOYEE('bill', 'jones',  null, '6492394093', '10/06/21', 'SA_REP', 8400, null, 145, 10); 
end;
/

--rekord bez daty
begin
insertEMPLOYEE('bill', 'smith',  'bsmith', '6492394093', null, 'SA_REP', 8400, null, 145, 10); 
end;
/

--rekord bez stanowiska
begin
insertEMPLOYEE('bill', 'byford',  'bbyford', '6492394093', '10/06/21', null, 8400, null, 145, 10); 
end;
/

--rekord bez kierownika
begin
insertEMPLOYEE('bill', 'byford',  'bbyford', '6492394093', '10/06/21', 'SA_REP', 8400, null, null, 10); 
end;
/

--rekord z przyszla data zatrudnienia
begin
insertEMPLOYEE('bill', 'byford',  'bbyford', '6492394093', '19/06/21', 'SA_REP', 8400, null, 145, 10); 
end;
/

--rekord z blednym stanowiskiem
begin
insertEMPLOYEE('bill', 'byford',  'bbyford', '6492394093', '10/06/21', 'netives', 8400, null, 145, 10); 
end;
/

--rekord z bledna pensja
begin
insertEMPLOYEE('bill', 'byford',  'bbyford', '6492394093', '10/06/21', 'SA_REP', 840, null, 145, 10); 
end;
/

--rekord z blednym kierownikiem
begin
insertEMPLOYEE('bill', 'byford',  'bbyford', '6492394093', '10/06/21', 'SA_REP', 8400, null, 908, 10); 
end;
/

--rekord z blednym dzialem
begin
insertEMPLOYEE('bill', 'byford',  'bbyford', '6492394093', '10/06/21', 'SA_REP', 8400, null, 145, 13); 
end;
/



