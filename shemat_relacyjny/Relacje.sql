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
