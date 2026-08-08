USE mm_src_metrostarlet;

DROP TABLE IF EXISTS LOCATION;
DROP TABLE IF EXISTS VENTE;
DROP TABLE IF EXISTS JOUE_DANS;
DROP TABLE IF EXISTS EXEMPLAIRE_LOCATION;
DROP TABLE IF EXISTS EXEMPLAIRE_VENTE;
DROP TABLE IF EXISTS ACTEUR;
DROP TABLE IF EXISTS FILM;
DROP TABLE IF EXISTS CLIENT;

CREATE TABLE CLIENT (
    client_id VARCHAR(32) PRIMARY KEY,
    nom VARCHAR(100),
    prenom_milieu VARCHAR(100),
    prenom_usage VARCHAR(100),
    genre VARCHAR(20),
    date_naissance DATE,
    adresse VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE FILM (
    film_id INT PRIMARY KEY,
    titre VARCHAR(255),
    annee_production SMALLINT,
    scenariste VARCHAR(255),
    realisateur VARCHAR(255),
    date_sortie DATETIME,
    prix_sortie DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE ACTEUR (
    acteur_id INT PRIMARY KEY,
    nom_acteur VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE JOUE_DANS (
    acteur_id INT NOT NULL,
    film_id INT NOT NULL,
    PRIMARY KEY (acteur_id, film_id),
    CONSTRAINT fk_metro_joue_dans_acteur
        FOREIGN KEY (acteur_id) REFERENCES ACTEUR(acteur_id),
    CONSTRAINT fk_metro_joue_dans_film
        FOREIGN KEY (film_id) REFERENCES FILM(film_id)
) ENGINE=InnoDB;

CREATE TABLE EXEMPLAIRE_LOCATION (
    exemplaire_location_id INT PRIMARY KEY,
    film_id INT NOT NULL,
    categorie_exemplaire VARCHAR(50),
    retire_du_circuit TINYINT(1),
    CONSTRAINT fk_metro_exemplaire_location_film
        FOREIGN KEY (film_id) REFERENCES FILM(film_id),
    INDEX idx_metro_exemplaire_location_film (film_id)
) ENGINE=InnoDB;

CREATE TABLE EXEMPLAIRE_VENTE (
    exemplaire_vente_id INT PRIMARY KEY,
    film_id INT NOT NULL,
    categorie_exemplaire VARCHAR(50),
    etat_neuf TINYINT(1),
    CONSTRAINT fk_metro_exemplaire_vente_film
        FOREIGN KEY (film_id) REFERENCES FILM(film_id),
    INDEX idx_metro_exemplaire_vente_film (film_id)
) ENGINE=InnoDB;

CREATE TABLE LOCATION (
    exemplaire_location_id INT NOT NULL,
    client_id VARCHAR(32) NOT NULL,
    date_debut DATETIME NOT NULL,
    date_fin DATETIME,
    prix_journalier DECIMAL(10,2),
    PRIMARY KEY (exemplaire_location_id, client_id, date_debut),
    CONSTRAINT fk_metro_location_exemplaire
        FOREIGN KEY (exemplaire_location_id)
        REFERENCES EXEMPLAIRE_LOCATION(exemplaire_location_id),
    CONSTRAINT fk_metro_location_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    INDEX idx_metro_location_client (client_id),
    INDEX idx_metro_location_date_debut (date_debut)
) ENGINE=InnoDB;

CREATE TABLE VENTE (
    exemplaire_vente_id INT PRIMARY KEY,
    client_id VARCHAR(32) NOT NULL,
    date_vente DATETIME,
    prix_vente DECIMAL(10,2),
    CONSTRAINT fk_metro_vente_exemplaire
        FOREIGN KEY (exemplaire_vente_id)
        REFERENCES EXEMPLAIRE_VENTE(exemplaire_vente_id),
    CONSTRAINT fk_metro_vente_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    INDEX idx_metro_vente_client (client_id),
    INDEX idx_metro_vente_date (date_vente)
) ENGINE=InnoDB;
