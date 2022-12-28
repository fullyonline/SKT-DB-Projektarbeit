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
    Datum					date	not null,
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