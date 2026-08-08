USE mm_src_buckboaster;

DROP TABLE IF EXISTS JOUE_DANS;
DROP TABLE IF EXISTS VENTE;
DROP TABLE IF EXISTS ACTEUR;
DROP TABLE IF EXISTS FILM;
DROP TABLE IF EXISTS PRODUIT;
DROP TABLE IF EXISTS CLIENT;

CREATE TABLE CLIENT (
    client_id VARCHAR(32) PRIMARY KEY,   // Utiliser VARCHAR(32) pour les IDs pour permettre une meilleure intégration avec les autres sources
    prenom VARCHAR(100),
    nom VARCHAR(100),   
    date_naissance DATE,
    sexe VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE FILM (
    film_id VARCHAR(32) PRIMARY KEY, //
    titre VARCHAR(255),
    annee SMALLINT
) ENGINE=InnoDB;

CREATE TABLE ACTEUR (
    acteur_id VARCHAR(32) PRIMARY KEY,
    nom VARCHAR(255),
    sexe VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE PRODUIT (
    produit_id VARCHAR(32) PRIMARY KEY,
    type_produit VARCHAR(20) NOT NULL,
    titre VARCHAR(255),
    prix_catalogue DECIMAL(10,2),
    film_id_source VARCHAR(32) NULL,
    INDEX idx_produit_type (type_produit), // Index pour accélérer les requêtes filtrant par type de produit
    INDEX idx_produit_film_source (film_id_source) // Index pour accélérer les jointures basées sur la source du film
) ENGINE=InnoDB;

CREATE TABLE JOUE_DANS (
    acteur_id VARCHAR(32) NOT NULL,
    film_id VARCHAR(32) NOT NULL,
    PRIMARY KEY (acteur_id, film_id),
    CONSTRAINT fk_buck_joue_dans_acteur
        FOREIGN KEY (acteur_id) REFERENCES ACTEUR(acteur_id),
    CONSTRAINT fk_buck_joue_dans_film
        FOREIGN KEY (film_id) REFERENCES FILM(film_id)
) ENGINE=InnoDB;

CREATE TABLE VENTE (
    vente_id VARCHAR(32) PRIMARY KEY,
    client_id VARCHAR(32) NOT NULL,
    produit_id VARCHAR(32) NOT NULL,
    date_vente DATETIME,
    prix_vente DECIMAL(10,2),
    CONSTRAINT fk_buck_vente_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_buck_vente_produit
        FOREIGN KEY (produit_id) REFERENCES PRODUIT(produit_id),
    INDEX idx_buck_vente_client (client_id), // Index pour accélérer les requêtes filtrant par client
    INDEX idx_buck_vente_produit (produit_id), // Index pour accélérer les requêtes filtrant par produit
    INDEX idx_buck_vente_date (date_vente) // Index pour accélérer les requêtes filtrant par date de vente
) ENGINE=InnoDB;
