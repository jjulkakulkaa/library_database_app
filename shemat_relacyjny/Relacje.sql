create table Klienci(
    pesel number(11) primary key,
    imie varchar2(50) not null,
    nazwisko varchar2(50) not null,
    data_urodzenia date not null,
    adres varchar2(100) not null,
    karta_biblioteczna number(9)
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
        references Promocje(wartosc),
    autor 
        references Autorzy(id_autora),
    gatunek
        references Gatunki(nazwa),
    wydawnictwo
        references Wydawnictwa(nazwa) 

);

create table Wypozyczenia(
    id_wypozyczenia number(9) primary key,
    data_wypozyczenia date not null,
    data_zwrotu date,
    karta_wypozyczajacego 
        references Klienci(karta_biblioteczna) not null,
    id_obslugujacego 
        references Pracownicy(pesel) not null,
    id_ksiazki 
        references Ksiazki(id_ksiazki) not null
);

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
        references Klienci(pesel) not null,
    id_ksiazki 
        references Ksiazki(id_ksiazki) not null,
    primary key(
        tresc, 
        id_klienta, 
        id_ksiazki)
);

create table Promocje(
    wartosc number(6,2) not null,
    id_ksiazki
        references Ksiazki(id_ksiazki) not null ,
    primary key(
        id_ksiazki,
        wartosc
    )
);
