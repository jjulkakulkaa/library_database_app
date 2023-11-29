create table Klienci(
    pesel number(11) primary key,
    imie varchar2(50) not null,
    nazwisko varchar2(50) not null,
    data_urodzenia date not null,
    adres varchar2(100) not null,
    karta_biblioteczna number(9)
);


/*
dodatkowa tabela na klientow co maja karte biblio
w tabeli wypozyczenia zamiast powiazywac z karta_biblioteczna z tabeli Klienci powiazuja sie z karta biblio z tej tabeli
*/

create table Karty_biblioteczne_klientow(
    karta_biblioteczna
        references Klienci(karta_biblioteczna)
        not null,
    pesel 
        references Klienci(pesel),
    primary key(
        karta_biblioteczna,
    )
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
    wartosc_promocji  
        references Promocje(wartosc)
        not null,
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
        references Karty_biblioteczne_klientow(karta_biblioteczna) not null,
    id_obslugujacego 
        references Pracownicy(pesel) not null,
    id_ksiazki 
        references Ksiazki(id_ksiazki) not null,
    
);


/*

*/
-- create table Wypozyczenia_klienta(
--     karta_biblioteczna
--         references Klienci(karta_biblioteczna),
--     id_wypozyczenia
--         references Wypozyczenia(id_wypozyczenia),
--     primary key(
--         karta_biblioteczna,
--         id_wypozyczenia
--     )
-- );

create table Zamowienia(
    numer number(9) primary key,
    data_zamowienia date not null,
    wartosc_zamowienia number(6,2) not null,
    status in('w trakcie realizacji', 'zrealizowane'),
    id_klienta  
        references Klienci(pesel) not null,
    id_obslugujacego 
        references Pracownicy(pesel) not null,
    id_ksiazki 
        references Ksiazki(id_ksiazki) not null
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
    into :new.numer
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
        v_karta_biblioteczna number
    );

    -- Funkcja do obliczania sumy wartości zamówień dla danego klienta
    function suma_wartosci_zamowien(v_pesel number) return number;
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
        insert into Klienci(pesel, imie, nazwisko, data_urodzenia, adres, karta_biblioteczna)
        values (v_pesel, v_imie, v_nazwisko, v_data_urodzenia, v_adres, v_karta_biblioteczna);
    end dodaj_klienta;

    function suma_wartosci_zamowien(v_pesel number) return number is
        v_suma number := 0;
    begin
        select sum(wartosc_zamowienia)
        into v_suma
        from Zamowienia
        where id_klienta = v_pesel;

        return v_suma;
    end suma_wartosci_zamowien;
end biblioteka_pkg;
/

-- Indeksy
create unique index klienci_i on Klienci(pesel);
create unique index kart_bibliotecznych_i on Karty_biblioteczne_klientow(karta_biblioteczna);
create unique index pracownicy_i on Pracownicy(pesel);
create unique index gatunki_i on Gatunki(nazwa);
create unique index wydawnictwa_i on Wydawnictwa(nazwa);
create unique index autorzy_i on Autorzy(id_autora);
create unique index ksiazki_i on Ksiazki(id_ksiazki);
create unique index wypozyczenia_i on Wypozyczenia(id_wypozyczenia);
create unique index zamowienia_i on Zamowienia(numer);
create index opinie_i on Opinie_klientow(id_klienta, id_ksiazki);
create index promocje_i on Promocje(id_ksiazki, wartosc);


