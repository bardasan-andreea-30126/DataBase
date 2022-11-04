--Proiect baze de date
--Biblioteca
--Studenti: Bardasan Maria Andreea, Ani Vasilica Andrada, Marka Ruben-Sebastian
--Grupa: 30126
            
--creare baza de date
create database db_ProiectBiblioteca

--folosirea bazei de date create
use db_ProiectBiblioteca

--crearea tabelelor necesare
CREATE TABLE Edituri (Nume varchar(30) PRIMARY KEY,Adresa varchar(30) NULL,NrTelefon varchar(15) NULL);
CREATE TABLE Carti (IDCarte int PRIMARY KEY, Titlu varchar(30), NumeEditura varchar(30) references Edituri);
CREATE TABLE Autori (IDCarte int references Carti,NumeAutor varchar(30) PRIMARY KEY);
CREATE TABLE Debitori (NrCard int PRIMARY KEY,Nume varchar(30),Adresa varchar(50) NULL,NrTelefon varchar(10) NULL);
CREATE TABLE Sediu (IDSediu int PRIMARY KEY,NumeSediu varchar(30),Adresa varchar(30));
CREATE TABLE Imprumuturi (IDCarte int references Carti,IDSediu int references Sediu,NrCard int references Debitori,Data_imprumut date,Data_retur date);
CREATE TABLE Copii (IDCarte int references Carti,IDSediu int,NrCopii int);
CREATE TABLE Sediu_Test  ( IDSediu int IDENTITY, Sediu_Action text ); 


--popularea tabelelor cu valori
INSERT INTO Edituri
VALUES
      ('Mega','Avram Iancu, 12','031.632.4101'),
	  ('Litera','Memorandumului, 100','031.100.6699'),
	  ('Nemira','Calea Turzii, 1','031.200.4600'),
	  ('Libris','Calea Traian, 5','031.300.4610'),
	  ('Elefant','Dambovitei 13','031.456.4610');

INSERT INTO Carti
VALUES
       (1,'Tata','Mega'),
	   (2,'Arta manipularii', 'Litera'),
	   (3,'Fluturi','Nemira'),
	   (4,'Scufita rosie','Libris'),
	   (5,'Casa bunicii','Elefant');

INSERT INTO Autori
VALUES
      (1,'Ion Agarbiceanu'),
	  (2,'Grigorie Babus'),
	  (3,'Mateiu Caragiale'),
	  (4,'Vasile Chira'),
	  (5,'Ion Ghetie');

INSERT INTO Debitori
VALUES
      (1,'Ion Popescu','Ion Ghica 18','0742483801'),
	  (2,'Dan Luca','Ortoaia 12','0752531092'),
	  (3,'Maria Ileana','General Dragalina 100','0782938129'),
	  (4,'Marian Stan','Dambovitei 52','0791923011'),
	  (5,'Klaus Iohannis','Somesului 12','0731900311');

INSERT INTO Sediu
VALUES
      (1,'Central','George Baritiu 12'),
	  (2,'Memo','Memorandumului 1'),
	  (3,'UTCN','Observatorului 5'),
	  (4,'UMF','Clinicii 12'),
	  (5,'UBB','Dambovitei 0');

INSERT INTO Copii
VALUES
      (1,1,5),
	  (2,2,6),
	  (3,3,7),
	  (4,4,8),
	  (5,5,9),
	  (1,2,0),
	  (2,1,0);

INSERT INTO Imprumuturi
VALUES
      (1,1,1,'2016-08-19','2016-09-19'),
	  (2,2,2,'2016-08-19','2016-09-19'),
	  (4,3,3,'2016-08-19','2016-09-19'),
	  (3,4,4,'2016-09-18','2016-10-18'),
	  (5,5,5,'2016-09-12','2016-10-12');

--pana aici andreea

--selectarea valorilor din tabele pt vizionare
select * from Carti

select * from Autori

select * from Debitori

select * from Edituri

select * from Copii

select * from Imprumuturi

select * from Sediu

select * from Sediu_Test

--proceduri stocate
CREATE PROCEDURE Nr_copii_sediu                 --procedura care selecteaza numarul de copii al unei carti dintr-un sediu  --ruben
@NumeSediu varchar(30), @Titlu varchar(30)
AS
    SELECT C.Titlu, S.NumeSediu, CO.NrCopii
	FROM Carti C JOIN Copii CO ON C.IDCarte=CO.IDCarte
	JOIN Sediu S ON CO.IDSediu=S.IDSediu
	WHERE S.NumeSediu LIKE '%'+@NumeSediu+'%'
	AND C.Titlu LIKE '%'+@Titlu+'%'

	exec Nr_copii_sediu 'Central','Tata' 


CREATE PROCEDURE carti_autor_sediu             --procedura care selecteaza  numele cartilor unui autor dintr-un sediu  --andreea
@Autor varchar(30), @Sediu varchar(30)
AS
SELECT C.Titlu, CO.NrCopii
FROM Carti C JOIN Autori A ON C.IDCarte=A.IDCarte
JOIN Copii CO ON CO.IDCarte=C.IDCarte
JOIN Sediu S ON CO.IDSediu = S.IDSediu
WHERE A.NumeAutor=@Autor AND S.NumeSediu=@Sediu

 exec carti_autor_sediu 'Ion Agarbiceanu', 'Central'

 CREATE PROCEDURE debitori_imprumut_carte     --procedura care selecteaza numele debitorilor care au imprumutat o anumita carte  --andrada
 @ID int
 AS
 SELECT D.Nume
FROM Debitori D LEFT JOIN Imprumuturi I
ON D.NrCard=I.NrCard
WHERE I.IDCarte=@ID

 exec debitori_imprumut_carte 2

--functii	
CREATE FUNCTION f_nr_carti_publicate_editura(@NumeEditura varchar(30)) -- functie pentru returnarea numarului de carti publicate de catre o editura   --ruben
RETURNS int
AS
BEGIN
DECLARE @nr_carti int;
SELECT @nr_carti = count(C.IDCarte)
From Carti C 
WHERE C.NumeEditura = @NumeEditura
RETURN @nr_carti;
END

SELECT [dbo].f_nr_carti_publicate_editura('Mega') AS nr_carti


CREATE FUNCTION f_titlu_carte_dupa_id(@IDCarte int) --functie pentru returnarea titlului unei carti dupa ID      --andreea
RETURNS varchar(30)
AS
BEGIN
DECLARE @nume varchar(30);
SELECT @nume = C.Titlu
FROM Carti C 
WHERE C.IDCarte=IDCarte
RETURN @nume
END

SELECT [dbo].f_titlu_carte_dupa_id(2) as titlu

CREATE FUNCTION f_nr_carti_sediu(@IDSediu int) -- functie pentru returnarea numarului de carti dintr-un anume sediu    --andrada
RETURNS int
AS
BEGIN
DECLARE @nr_carti int;
SELECT @nr_carti = SUM(CO.NrCopii)
From Copii CO WHERE CO.IDSediu = @IDSediu
RETURN @nr_carti;
END

SELECT [dbo].f_nr_carti_sediu(3) AS nr_carti

--triggere
CREATE TRIGGER trigger1 on Autori for update as  --nu se poate actualiza numele autorului       --ruben
if(UPDATE(NumeAutor))
Begin
raiserror('NU PUTETI ACTUALIZA NUMELE AUTORULUI',8,2)
Rollback transaction
end

UPDATE Autori
SET NumeAutor = 'Ilie Petre' 
WHERE NumeAutor = 'Ion Agarbiceanu'


CREATE TRIGGER trigger2 on Imprumuturi for delete --nu se pot sterge mai multe imprumuturi in acelasi timp    --ruben
as
Begin
    Declare @i int = (Select count(*) from deleted)
	if(@i>1)
	Begin
		raiserror('Se poate sterge un singur imprumut',7,2)
		Rollback transaction
	End
End

delete from Imprumuturi
where IDCarte = 1


Create Trigger trigger3 on Debitori for update as          --nu se poate updata numele si adresa unui debitor in acelasi timp   --andreea
Begin
	If(update(Nume) and update(Adresa))
	Begin
		raiserror('Nu puteti sa updatati numele si adresa in acelasi timp',7,2)
		rollback transaction
	End
End

UPDATE Debitori
SET Nume = 'Andrei' , Adresa = 'Ghica 18'
WHERE NrCard = 1

CREATE TRIGGER trInsertSediu                                                                                                   --andrada
ON Sediu
FOR INSERT  
AS  
BEGIN  
  Declare @IDSediu int 
  SELECT @IDSediu = IDSediu from inserted  
  INSERT INTO Sediu_Test  
  VALUES ('Un nou sediu cu IDSediu = ' + CAST(@IDSediu AS VARCHAR(10)) + ' a fost adaugat la ' + CAST(Getdate() AS VARCHAR(22)))  
END  

INSERT INTO Sediu VALUES (6,'Blue','Fabricii 12')  


CREATE TRIGGER trDeleteSediu                                        --andrada
ON Sediu  
FOR DELETE  
AS  
BEGIN  
  Declare @IDSediu int  
  SELECT @IDSediu = IDSediu from deleted  
  INSERT INTO Sediu_Test  
  VALUES ('Un sediu existent cu IDSediu = ' + CAST(@IDSediu AS VARCHAR(10)) + ' a fost sters la ' + CAST(Getdate() AS VARCHAR(22)))  
END  

DELETE FROM Sediu WHERE IDSediu = 6;  



--Cursor
DECLARE cursor_1 CURSOR             --cursor care afiseaza data de returnare pt cartile imprumutate de catre fiecare debitor   --ruben
FOR SELECT
    IDCarte,
	NrCard,
	Data_retur
	from Imprumuturi

open cursor_1

DECLARE 
@IDCarte1 int,
@NrCard1 int,
@data_retur1 date;

FETCH NEXT FROM cursor_1 INTO 
  @IDCarte1,
  @NrCard1,
  @data_retur1;

WHILE @@FETCH_STATUS = 0
    BEGIN
	print 'Debitorul cu Nr-ul '+ CAST(@NrCard1 AS varchar) + ' trebuie sa returneze cartea cu id-ul ' + CAST(@IDCarte1 AS varchar) + ' pana la data de ' + CAST(@data_retur1 AS varchar);
    FETCH NEXT FROM cursor_1 INTO 
  @IDCarte1,
  @NrCard1,
  @data_retur1;
    END;

close cursor_1;


DECLARE cursor_2 CURSOR              --cursor care afiseaza id-ul cartilor care nu mai sunt in stoc la un anumit sediu        --andreea
FOR SELECT
    IDCarte,
	IDSediu,
	NrCopii
	from Copii

open cursor_2

DECLARE 
@IDCarte2 int,
@IDSediu2 int,
@NrCopii2 int;

FETCH NEXT FROM cursor_2 into
@IDCarte2,
@IDSediu2,
@NrCopii2;

WHILE @@FETCH_STATUS = 0
    BEGIN
	IF (@NrCopii2 = 0) 
	BEGIN
	PRINT 'Cartea cu ID-ul ' + CAST(@IDCarte2 as varchar) + ' nu se mai afla in stoc la sediul cu ID-ul ' + CAST(@IDSediu2 as varchar);
	end
	FETCH NEXT FROM cursor_2 into
    @IDCarte2,
    @IDSediu2,
    @NrCopii2;
    END;

close cursor_2;



DECLARE cursor_3 CURSOR            --cursor care afiseaza cartile publicate de catre editura Libris                  --andrada
FOR SELECT
Titlu,
NumeEditura
from Carti

open cursor_3

DECLARE
@Titlu3 varchar(30),
@NumeEditura3 varchar(30);

FETCH NEXT FROM cursor_3 into
@Titlu3,
@NumeEditura3;

PRINT 'Cartile publicate de catre editura Libris sunt: '
WHILE @@FETCH_STATUS = 0
     BEGIN
	 IF(@NumeEditura3 LIKE 'Libris')
	 BEGIN
	 Print @Titlu3
	 END
	 FETCH NEXT FROM cursor_3 into
@Titlu3,
@NumeEditura3;
END;

close cursor_3

CREATE VIEW view1 AS
SELECT A.NumeAutor ,COUNT(A.IDCarte) as nr_carti
FROM Edituri E INNER JOIN Carti C  on C.NumeEditura = E.Nume  INNER JOIN Autori A on A.IDCarte = C.IDCarte
WHERE E.Nume = 'Libris'
GROUP BY A.NumeAutor
HAVING COUNT(A.IDCarte) < 5;









 

