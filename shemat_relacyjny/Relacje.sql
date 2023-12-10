create table Klienci(
    pesel number(11) primary key,
    imie varchar2(50) not null,
    nazwisko varchar2(50) not null,
    data_urodzenia date not null,
    adres varchar2(100) not null
);




create table Karty_biblioteczne(
    karta_biblioteczna number(9)
        primary key,
    pesel 
        references Klienci(pesel)
        not null unique
);

create table Pracownicy(
    pesel number(11) primary key,
    imie varchar2(50) not null,
    nazwisko varchar2(50) not null,
    adres varchar2(100) not null,
    stanowisko varchar2(50) not null
);

create table Gatunki(
    nazwa varchar2(50) primary key,
);

create table Wydawnictwa(
    nazwa varchar2(50) primary key,
    rok_zalozenia date not null,
    adres varchar2(100) not null,
);

create table Autorzy(
    id_autora number(6) primary key,
    imie varchar2(50) not null,
    nazwisko varchar2(50) not null,
    narodowosc varchar2(50) not null
);

create table Ksiazki(
    id_ksiazki number(9) primary key,
    tytul varchar2(50) not null,
    cena number(6,2),
    autor 
        references Autorzy(id_autora)
        not null,
    gatunek
        references Gatunki(nazwa)
        not null,
    wydawnictwo
        references Wydawnictwa(nazwa)
        not null 

);

create table Autorzy_ksiazek(
    id_autora 
        references Autorzy(id_autora),
    id_ksiazki 
        references Ksiazki(id_ksiazki),
    primary key(
        id_autora,
        id_ksiazki
    )
    
);

create table Wypozyczenia(
    id_wypozyczenia number(9) primary key ,
    data_wypozyczenia date not null,
    data_zwrotu date,
    karta_biblioteczna
        references Karty_biblioteczne(karta_biblioteczna) not null,
    id_obslugujacego 
        references Pracownicy(pesel) not null,
    id_ksiazki 
        references Ksiazki(id_ksiazki) not null,
    
);



create table Zamowienia(
    numer_zamowienia number(9) primary key,
    data_zamowienia date not null,
    status in('w trakcie realizacji', 'zrealizowane'),
    id_klienta  
        references Klienci(pesel) not null,
    id_obslugujacego 
        references Pracownicy(pesel) not null
);


create table Zamowione_ksiazki(
    numer_zamowienia 
        references Zamowienia(numer_zamowienia) not null,
    id_ksiazki 
        references Ksiazki(id_ksiazki) not null,
    primary key(
        numer_zamowienia,
        id_ksiazki)
);


create table Opinie_klientow(
    tresc varchar2(300) not null,
    id_klienta 
        references Klienci(pesel) ,
    id_ksiazki 
        references Ksiazki(id_ksiazki),
    primary key(
        tresc, 
        id_klienta, 
        id_ksiazki)
);

create table Promocje(
    wartosc number(6,2) not null,
    id_ksiazki
        references Ksiazki(id_ksiazki) ,
    primary key(
        id_ksiazki,
        wartosc
    )
);


-- Sekwencje
create sequence id_autora_seq start with 1 increment by 1;
create sequence id_ksiazki_seq start with 1 increment by 1;
create sequence id_wypozyczenia_seq start with 1 increment by 1;
create sequence numer_zamowienia_seq start with 1 increment by 1;

-- Triggery
create or replace trigger id_autora_trg
before insert on Autorzy
for each row
begin
    select id_autora_seq.nextval
    into :new.id_autora
    from dual;
end;
/
create or replace trigger id_ksiazki_trg
before insert on Ksiazki
for each row
begin
    select id_ksiazki_seq.nextval
    into :new.id_ksiazki
    from dual;
end;
/
create or replace trigger id_wypozyczenia_trg
before insert on Wypozyczenia
for each row
begin
    select id_wypozyczenia_seq.nextval
    into :new.id_wypozyczenia
    from dual;
end;
/
create or replace trigger numer_zamowienia_trg
before insert on Zamowienia
for each row
begin
    select numer_zamowienia_seq.nextval
    into :new.numer_zamowienia
    from dual;
end;
/



-- Pakiet podprogramów

create or replace package biblioteka_pkg is
    -- Procedura do dodawania klienta
    procedure dodaj_klienta(
        v_pesel number,
        v_imie varchar2,
        v_nazwisko varchar2,
        v_data_urodzenia date,
        v_adres varchar2,
    );

    -- Funkcja do obliczania sumy wartości zamówień dla danego klienta
    function wartosc_zamowienia(v_pesel number) return number;

    -- Procedura do dodawania pracownika
    procedure dodaj_pracownika(
        v_pesel number,
        v_imie varchar2,
        v_nazwisko varchar2,
        v_adres varchar2,
        v_stanowisko varchar2
    );

    -- Procedura do dodawania książki
    procedure dodaj_ksiazke(
        v_tytul varchar2,
        v_cena number,
        v_wartosc_promocji number,
        v_id_autora number,
        v_nazwa_gatunku varchar2,
        v_nazwa_wydawnictwa varchar2
    );


    procedure dodaj_zamowionie(
        v_lista_ksiazek SYS.ODCIVARCHAR2LIST,
        v_id_klienta number,
        v_id_obslugujacego number
    )

    PROCEDURE dodaj_wypozyczenie(
        v_tytul_ksiazki VARCHAR2,
        v_karta_biblioteczna NUMBER,
        v_id_obslugujacego NUMBER,
        v_cena NUMBER;
    )

    PROCEDURE dodaj_opinie(
        v_tresc varchar2,
        v_pesel number,
        v_tytul_ksiazki varchar2
    )

    PROCEDURE dodaj_karte_biblioteczna(
    v_pesel number
    )

    PROCEDURE dodaj_promocje(
        v_tytul_ksiazki varchar2,
        v_wartosc_promocji number
    ) 

    PROCEDURE dodaj_autora(
        v_imie varchar2,
        v_nazwisko varchar2,
        v_narodowosc varchar2
    )

    PROCEDURE dodaj_autora_ksiazki(
        v_imie_autora varchar2,
        v_nazwisko_autora varchar2,
        v_tytul_ksiazki varchar2
    ) 


    PROCEDURE dodaj_gatunek(
        v_nazwa varchar2
    )

    CREATE OR REPLACE PROCEDURE dodaj_wydawnictwo(
        v_nazwa varchar2,
        v_rok_zalozenia date,
        v_adres varchar2
    )


end biblioteka_pkg;
/

create or replace package body biblioteka_pkg is
    procedure dodaj_klienta(
        v_pesel number,
        v_imie varchar2,
        v_nazwisko varchar2,
        v_data_urodzenia date,
        v_adres varchar2,
        v_karta_biblioteczna number
    ) is
    begin
        insert into Klienci(pesel, imie, nazwisko, data_urodzenia, v_adres)
        values (v_pesel, v_imie, v_nazwisko, v_data_urodzenia, v_adres);
    end dodaj_klienta;

    function wartosc_zamowienia(v_nr_zamowienia number) return number is
        v_suma number := 0;
    begin
        select sum(wartosc_ksiazki)
        into v_suma
        from Zamowione_ksiazki
        where numer_zamowienia = v_nr_zamowienia;

        return v_suma;
    end wartosc_zamowienia;

    procedure dodaj_pracownika(
        v_pesel number,
        v_imie varchar2,
        v_nazwisko varchar2,
        v_adres varchar2,
        v_stanowisko varchar2
    ) is
    begin
        insert into Pracownicy(pesel, imie, nazwisko, adres, stanowisko)
        values (v_pesel, v_imie, v_nazwisko, v_adres, v_stanowisko);
    end dodaj_pracownika;

    procedure dodaj_ksiazke(
        v_tytul varchar2,
        v_cena number,
        v_wartosc_promocji number,
        v_id_autora number,
        v_nazwa_gatunku varchar2,
        v_nazwa_wydawnictwa varchar2
    ) is
    begin
        insert into Ksiazki(tytul, cena, wartosc_promocji, autor, gatunek, wydawnictwo)
        values (v_tytul, v_cena, v_wartosc_promocji, v_id_autora, v_nazwa_gatunku, v_nazwa_wydawnictwa);
    
    end dodaj_ksiazke;

    procedure dodaj_zamowienie(
    v_lista_ksiazek SYS.ODCIVARCHAR2LIST,
    v_id_klienta number,
    v_id_obslugujacego number
) is
    v_numer_zamowienia number;
    v_wartosc_zamowienia NUMBER;
begin
    select numer_zamowienia_seq.nextval into v_numer_zamowienia from dual;

    -- Wstawianie kazdej zamowionej ksiazki do Zamowione_ksiazki
    for i in 1..v_lista_ksiazek.count loop
        insert into Zamowione_ksiazki(numer_zamowienia, id_ksiazki)
        values (v_numer_zamowienia, (select id_ksiazki from Ksiazki where tytul = v_lista_ksiazek(i)));
    end loop;

     -- Obliczanie wartości zamówienia
    v_wartosc_zamowienia := wartosc_zamowienia(v_numer_zamowienia);

    -- Wstawianie rekordu do Zamowienia
    INSERT INTO Zamowienia(numer_zamowienia, data_zamowienia, status, id_klienta, id_obslugujacego, wartosc_zamowienia)
    VALUES (v_numer_zamowienia, SYSDATE, 'w trakcie realizacji', v_id_klienta, v_id_obslugujacego, v_wartosc_zamowienia);

   
end dodaj_zamowienie;

PROCEDURE dodaj_wypozyczenie(
    v_tytul_ksiazki VARCHAR2,
    v_karta_biblioteczna NUMBER,
    v_id_obslugujacego NUMBER,
    v_cena NUMBER;
) IS
    v_id_ksiazki NUMBER;
    v_data_zwrotu DATE;
BEGIN
    
    SELECT id_ksiazki, cena INTO v_id_ksiazki
    FROM Ksiazki
    WHERE tytul = v_tytul_ksiazki;

 IF v_cena IS NOT NULL THEN
        
        DBMS_OUTPUT.PUT_LINE('Ksiazka jest na sprzedaz, nie może być wypożyczona.');
    ELSE
        IF EXISTS (
            SELECT 1
            FROM Wypozyczenia
            WHERE id_ksiazki = v_id_ksiazki
        ) THEN
            DBMS_OUTPUT.PUT_LINE('Ksiazka jest już wypożyczona.');
        ELSE
            -- zwrot za 14 dni
            v_data_zwrotu := SYSDATE + 14;

            INSERT INTO Wypozyczenia(id_wypozyczenia, data_wypozyczenia, data_zwrotu, karta_biblioteczna, id_obslugujacego, id_ksiazki)
            VALUES (id_wypozyczenia_seq.NEXTVAL, SYSDATE, v_data_zwrotu, v_karta_biblioteczna, v_id_obslugujacego, v_id_ksiazki);
            
            DBMS_OUTPUT.PUT_LINE('Ksiazka została wypożyczona.');
        END IF;
    END IF;
    
END dodaj_wypozyczenie;

PROCEDURE dodaj_opinie(
    v_tresc varchar2,
    v_pesel number,
    v_tytul_ksiazki varchar2
) IS
BEGIN
    INSERT INTO Opinie_klientow(tresc, id_klienta, id_ksiazki)
    VALUES (v_tresc, v_pesel, (SELECT id_ksiazki FROM Ksiazki WHERE tytul = v_tytul_ksiazki));
    
    DBMS_OUTPUT.PUT_LINE('Opinia dodana pomyślnie.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania opinii: ' || SQLERRM);
END dodaj_opinie;

-- Procedura do dodawania karty bibliotecznej klienta
PROCEDURE dodaj_karte_biblioteczna(
    v_pesel number
) IS
BEGIN
    INSERT INTO Karty_biblioteczne(karta_biblioteczna, pesel)
    VALUES (numer_karty_bibliotecznej_seq.NEXTVAL, v_pesel);
    
    DBMS_OUTPUT.PUT_LINE('Karta biblioteczna dodana pomyślnie.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania karty bibliotecznej: ' || SQLERRM);
END dodaj_karte_biblioteczna;

-- Procedura do dodawania promocji
PROCEDURE dodaj_promocje(
    v_tytul_ksiazki varchar2,
    v_wartosc_promocji number
) IS
    v_id_ksiazki number;
BEGIN
    
    SELECT id_ksiazki INTO v_id_ksiazki
    FROM Ksiazki
    WHERE tytul = v_tytul_ksiazki AND cena IS NOT NULL;


    INSERT INTO Promocje(id_ksiazki, wartosc)
    VALUES (v_id_ksiazki, v_wartosc_promocji);

    DBMS_OUTPUT.PUT_LINE('Promocja dodana pomyślnie.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Książka o podanym tytule nie istnieje lub ma cenę null.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania promocji: ' || SQLERRM);
END dodaj_promocje;

PROCEDURE dodaj_autora(
    v_imie varchar2,
    v_nazwisko varchar2,
    v_narodowosc varchar2
) IS
    v_id_autora number;
BEGIN
    INSERT INTO Autorzy(id_autora, imie, nazwisko, narodowosc)
    VALUES (id_autora_seq.NEXTVAL, v_imie, v_nazwisko, v_narodowosc)
    RETURNING id_autora INTO v_id_autora;

    DBMS_OUTPUT.PUT_LINE('Autor dodany pomyślnie.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania autora: ' || SQLERRM);
END dodaj_autora;

PROCEDURE dodaj_autora_ksiazki(
    v_imie_autora varchar2,
    v_nazwisko_autora varchar2,
    v_tytul_ksiazki varchar2
) IS
    v_id_autora number;
    v_id_ksiazki number;
BEGIN
   
    SELECT id_autora INTO v_id_autora
    FROM Autorzy
    WHERE imie = v_imie_autora AND nazwisko = v_nazwisko_autora;

    SELECT id_ksiazki INTO v_id_ksiazki
    FROM Ksiazki
    WHERE tytul = v_tytul_ksiazki;

    INSERT INTO Autorzy_ksiazek(id_autora, id_ksiazki)
    VALUES (v_id_autora, v_id_ksiazki);
    
    DBMS_OUTPUT.PUT_LINE('Autor-Książka relacja dodana pomyślnie.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono autora o podanym imieniu i nazwisku lub książki o podanym tytule.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania relacji autor-książka: ' || SQLERRM);
END dodaj_autora_ksiazki;

PROCEDURE dodaj_gatunek(
    v_nazwa varchar2
) IS
BEGIN
    INSERT INTO Gatunki(nazwa)
    VALUES (v_nazwa);
    
    DBMS_OUTPUT.PUT_LINE('Gatunek dodany pomyślnie.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania gatunku: ' || SQLERRM);
END dodaj_gatunek;

PROCEDURE dodaj_wydawnictwo(
    v_nazwa varchar2,
    v_rok_zalozenia date,
    v_adres varchar2
) IS
BEGIN
    INSERT INTO Wydawnictwa(nazwa, rok_zalozenia, adres)
    VALUES (v_nazwa, v_rok_zalozenia, v_adres);
    
    DBMS_OUTPUT.PUT_LINE('Wydawnictwo dodane pomyślnie.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania wydawnictwa: ' || SQLERRM);
END dodaj_wydawnictwo;


end biblioteka_pkg;
/

-- Indeksy
create index karta_biblioteczna_idx on Klienci(karta_biblioteczna);
create index stanowisko_idx on Pracownicy(stanowisko);
create index nazwisko_autora_idx on Autorzy(nazwisko);
create unique index tytul_ksiazki_idx on Ksiazki(tytul);
create index data_wybozyceznia_idx on Wypozyczenia(data_wypozyczenia);
create index data_zwrotu_idx on Wypozyczenia(data_zwrotu);
create index data_zamowienia_idx on Zamowienia(data_zamowienia);
create index status_zamowienia_idx on Zamowienia(status);



