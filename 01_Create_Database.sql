-- 01_Create_Database.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

use master;
go

If(db_id(N'Corona') IS NOT NULL)
begin
	drop database Corona;
end
go

create database Corona;
go
use Corona;

--
-- Tabellen
--


/*
-- Datum
*/

create table Datum
(
	DatumID 	int 			not null identity(1,1),
    Datum		date			not null,
    constraint pk_datum primary key (DatumID)
);

/*
-- AttributTyp
*/

create table AttributTyp
(
	AttributTypID 	int 			not null identity(1,1),
    AttributTyp		varchar(100)	not null,
    constraint pk_attributtyp primary key (AttributTypID)
);

/*
-- Attribut
*/

create table Attribut
(
	AttributID 		int		not null identity(1,1),
	AttributTypID 	int		not null,
    Wert			int		not null,
    constraint pk_attribut primary key (AttributID)
);

/*
-- AttributCoronaDaten
*/

create table AttributCoronaDaten
(
	AttributCoronaDatenID 	int		not null identity(1,1),
	AttributID 				int		not null,
	CoronaDatenID 			int		not null,
	DatumID					int		not null,
    constraint pk_attributcoronadaten primary key (AttributCoronaDatenID)
);

/*
-- Kanton
*/

create table Kanton
(
	KantonID 	int 			not null identity(1,1),
    Bezeichnung	varchar(100)	not null,
    Kurzzeichen	varchar(3)	    not null,
    constraint pk_kanton primary key (KantonID)
);

/*
-- CoronaDaten
*/

create table CoronaDaten
(
	CoronaDatenID 			int 	not null identity(1,1),
    KantonID				int		not null,
    DatumID					int		not null,
	Getestet				int		null, -- ncumul_tested
	Positiv					int		null, -- ncumul_conf
	NeuHospitalisiert		int		null, -- new_hosp
	Hospitalisiert			int		null, -- current_hosp
	AufIPS					int		null, -- current_icu
	MitBeatmung				int		null, -- current_vent
	Verstorben				int		null, -- ncumul_deceased
	Isoliert				int		null, -- current_isolated
	InQuarantaene			int		null, -- current_quarantined_total
    constraint pk_coronadaten primary key (CoronaDatenID)
);


--
-- Foreign key constraints
--

alter table CoronaDaten
	add constraint fk_coronadaten_kanton foreign key (KantonID) references Kanton(KantonID);
	
alter table CoronaDaten
	add constraint fk_coronadaten_datum foreign key (DatumID) references Datum(DatumID);

alter table AttributCoronaDaten
	add constraint fk_attributcoronadaten_datum foreign key (DatumID) references Datum(DatumID);
	
alter table AttributCoronaDaten
	add constraint fk_attributcoronadaten_coronadaten foreign key (CoronaDatenID) references CoronaDaten(CoronaDatenID);
	
alter table AttributCoronaDaten
	add constraint fk_attributcoronadaten_attribut foreign key (AttributID) references Attribut(AttributID);

alter table Attribut
	add constraint fk_attribut_attributtyp foreign key (AttributTypID) references AttributTyp(AttributTypID);