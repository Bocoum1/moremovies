USE mm_integrated;

DROP TABLE IF EXISTS LOCATION;
DROP TABLE IF EXISTS VENTE;
DROP TABLE IF EXISTS JOUE_DANS;
DROP TABLE IF EXISTS ACTEUR;
DROP TABLE IF EXISTS GADGET;
DROP TABLE IF EXISTS FILM;
DROP TABLE IF EXISTS PRODUIT;
DROP TABLE IF EXISTS CLIENT;
DROP TABLE IF EXISTS MAGASIN;

CREATE TABLE MAGASIN (
    magasin_id INT PRIMARY KEY,
    nom_magasin VARCHAR(100) NOT NULL

    client_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    prenom_milieu VARCHAR(100),
    genre VARCHAR(10),
    date_naissance DATE,
    adresse VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE PRODUIT (
    produit_id INT AUTO_INCREMENT PRIMARY KEY,
    type_produit VARCHAR(20) NOT NULL,
    titre VARCHAR(255),
    prix_catalogue DECIMAL(10,2),
    INDEX idx_integrated_produit_type (type_produit)
) ENGINE=InnoDB;

CREATE TABLE FILM (
    produit_id INT PRIMARY KEY,
    annee_production SMALLINT,
    scenariste VARCHAR(255),
    realisateur VARCHAR(255),
    date_sortie DATETIME,
    CONSTRAINT fk_integrated_film_produit
        FOREIGN KEY (produit_id) REFERENCES PRODUIT(produit_id)
) ENGINE=InnoDB;

CREATE TABLE GADGET (
    produit_id INT PRIMARY KEY,
    categorie_gadget VARCHAR(50),
    CONSTRAINT fk_integrated_gadget_produit
        FOREIGN KEY (produit_id) REFERENCES PRODUIT(produit_id)
) ENGINE=InnoDB;

CREATE TABLE ACTEUR (
    acteur_id INT AUTO_INCREMENT PRIMARY KEY,
    nom_acteur VARCHAR(255),
    sexe VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE JOUE_DANS (
    acteur_id INT NOT NULL,
    produit_id INT NOT NULL,
    PRIMARY KEY (acteur_id, produit_id),
    CONSTRAINT fk_integrated_joue_dans_acteur
        FOREIGN KEY (acteur_id) REFERENCES ACTEUR(acteur_id),
    CONSTRAINT fk_integrated_joue_dans_film
        FOREIGN KEY (produit_id) REFERENCES FILM(produit_id)
) ENGINE=InnoDB;

CREATE TABLE VENTE (
    vente_id INT AUTO_INCREMENT PRIMARY KEY,
    magasin_id INT NOT NULL,
    client_id INT NOT NULL,
    produit_id INT NOT NULL,
    date_vente DATETIME,
    prix_vente DECIMAL(10,2),
    CONSTRAINT fk_integrated_vente_magasin
        FOREIGN KEY (magasin_id) REFERENCES MAGASIN(magasin_id),
    CONSTRAINT fk_integrated_vente_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_integrated_vente_produit
        FOREIGN KEY (produit_id) REFERENCES PRODUIT(produit_id),
    INDEX idx_integrated_vente_magasin (magasin_id),
    INDEX idx_integrated_vente_client (client_id),
    INDEX idx_integrated_vente_produit (produit_id),
    INDEX idx_integrated_vente_date (date_vente)
) ENGINE=InnoDB;

CREATE TABLE LOCATION (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    magasin_id INT NOT NULL,
    client_id INT NOT NULL,
    produit_id INT NOT NULL,
    date_debut DATETIME NOT NULL,
    date_fin DATETIME,
    prix_location DECIMAL(10,2),
    CONSTRAINT fk_integrated_location_magasin
        FOREIGN KEY (magasin_id) REFERENCES MAGASIN(magasin_id),
    CONSTRAINT fk_integrated_location_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_integrated_location_produit
        FOREIGN KEY (produit_id) REFERENCES PRODUIT(produit_id),
    INDEX idx_integrated_location_magasin (magasin_id),
    INDEX idx_integrated_location_client (client_id),
    INDEX idx_integrated_location_produit (produit_id),
    INDEX idx_integrated_location_date_debut (date_debut)
) ENGINE=InnoDB;
