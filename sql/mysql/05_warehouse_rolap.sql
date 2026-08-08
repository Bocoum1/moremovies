USE mm_warehouse;

DROP TABLE IF EXISTS AGG_CA_MOIS_MAGASIN;
DROP TABLE IF EXISTS AGG_LOCATION_MOIS_MAGASIN_PRODUIT;
DROP TABLE IF EXISTS AGG_VENTE_MOIS_MAGASIN_PRODUIT;
DROP TABLE IF EXISTS FACT_LOCATION;
DROP TABLE IF EXISTS FACT_VENTE;
DROP TABLE IF EXISTS DIM_PERIODE;
DROP TABLE IF EXISTS DIM_CLIENT;
DROP TABLE IF EXISTS DIM_PRODUIT;
DROP TABLE IF EXISTS DIM_MAGASIN;

CREATE TABLE DIM_MAGASIN (
    magasin_key INT PRIMARY KEY,
    magasin_id_source INT,
    nom_magasin VARCHAR(100),
    reseau VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE DIM_PRODUIT (
    produit_key INT PRIMARY KEY,
    produit_id_source INT,
    titre VARCHAR(255),
    type_produit VARCHAR(20),
    categorie_produit VARCHAR(50),
    annee_production SMALLINT,
    scenariste VARCHAR(255),
    realisateur VARCHAR(255),
    INDEX idx_dim_produit_type (type_produit),
    INDEX idx_dim_produit_categorie (categorie_produit)
) ENGINE=InnoDB;

CREATE TABLE DIM_CLIENT (
    client_key INT PRIMARY KEY,
    client_id_source INT,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    genre VARCHAR(10),
    date_naissance DATE,
    age INT,
    tranche_age VARCHAR(30),
    groupe_age VARCHAR(30),
    adresse VARCHAR(255),
    INDEX idx_dim_client_genre (genre),
    INDEX idx_dim_client_tranche_age (tranche_age),
    INDEX idx_dim_client_groupe_age (groupe_age)
) ENGINE=InnoDB;

CREATE TABLE DIM_PERIODE (
    date_key INT PRIMARY KEY,
    date_complete DATE,
    jour_du_mois INT,
    mois INT,
    libelle_mois VARCHAR(20),
    trimestre INT,
    annee INT,
    INDEX idx_dim_periode_annee_mois (annee, mois),
    INDEX idx_dim_periode_annee_trimestre (annee, trimestre)
) ENGINE=InnoDB;

CREATE TABLE FACT_VENTE (
    vente_fact_id BIGINT PRIMARY KEY,
    produit_key INT NOT NULL,
    magasin_key INT NOT NULL,
    client_key INT NOT NULL,
    date_key INT NOT NULL,
    montant_vente DECIMAL(12,2),
    nombre_ventes INT,
    CONSTRAINT fk_fact_vente_produit
        FOREIGN KEY (produit_key) REFERENCES DIM_PRODUIT(produit_key),
    CONSTRAINT fk_fact_vente_magasin
        FOREIGN KEY (magasin_key) REFERENCES DIM_MAGASIN(magasin_key),
    CONSTRAINT fk_fact_vente_client
        FOREIGN KEY (client_key) REFERENCES DIM_CLIENT(client_key),
    CONSTRAINT fk_fact_vente_date
        FOREIGN KEY (date_key) REFERENCES DIM_PERIODE(date_key),
    INDEX idx_fact_vente_date (date_key),
    INDEX idx_fact_vente_produit (produit_key),
    INDEX idx_fact_vente_magasin (magasin_key),
    INDEX idx_fact_vente_client (client_key),
    INDEX idx_fact_vente_magasin_date (magasin_key, date_key),
    INDEX idx_fact_vente_produit_date (produit_key, date_key)
) ENGINE=InnoDB;

CREATE TABLE FACT_LOCATION (
    location_fact_id BIGINT PRIMARY KEY,
    produit_key INT NOT NULL,
    magasin_key INT NOT NULL,
    client_key INT NOT NULL,
    date_key INT NOT NULL,
    montant_location DECIMAL(12,2),
    nombre_locations INT,
    duree_location_jours INT,
    CONSTRAINT fk_fact_location_produit
        FOREIGN KEY (produit_key) REFERENCES DIM_PRODUIT(produit_key),
    CONSTRAINT fk_fact_location_magasin
        FOREIGN KEY (magasin_key) REFERENCES DIM_MAGASIN(magasin_key),
    CONSTRAINT fk_fact_location_client
        FOREIGN KEY (client_key) REFERENCES DIM_CLIENT(client_key),
    CONSTRAINT fk_fact_location_date
        FOREIGN KEY (date_key) REFERENCES DIM_PERIODE(date_key),
    INDEX idx_fact_location_date (date_key),
    INDEX idx_fact_location_produit (produit_key),
    INDEX idx_fact_location_magasin (magasin_key),
    INDEX idx_fact_location_client (client_key),
    INDEX idx_fact_location_magasin_date (magasin_key, date_key),
    INDEX idx_fact_location_produit_date (produit_key, date_key)
) ENGINE=InnoDB;

CREATE TABLE AGG_VENTE_MOIS_MAGASIN_PRODUIT (
    annee INT NOT NULL,
    mois INT NOT NULL,
    magasin_key INT NOT NULL,
    produit_key INT NOT NULL,
    ca_vente DECIMAL(14,2),
    nombre_ventes INT,
    PRIMARY KEY (annee, mois, magasin_key, produit_key),
    CONSTRAINT fk_agg_vente_magasin
        FOREIGN KEY (magasin_key) REFERENCES DIM_MAGASIN(magasin_key),
    CONSTRAINT fk_agg_vente_produit
        FOREIGN KEY (produit_key) REFERENCES DIM_PRODUIT(produit_key)
) ENGINE=InnoDB;

CREATE TABLE AGG_LOCATION_MOIS_MAGASIN_PRODUIT (
    annee INT NOT NULL,
    mois INT NOT NULL,
    magasin_key INT NOT NULL,
    produit_key INT NOT NULL,
    ca_location DECIMAL(14,2),
    nombre_locations INT,
    duree_location_totale INT,
    PRIMARY KEY (annee, mois, magasin_key, produit_key),
    CONSTRAINT fk_agg_location_magasin
        FOREIGN KEY (magasin_key) REFERENCES DIM_MAGASIN(magasin_key),
    CONSTRAINT fk_agg_location_produit
        FOREIGN KEY (produit_key) REFERENCES DIM_PRODUIT(produit_key)
) ENGINE=InnoDB;

CREATE TABLE AGG_CA_MOIS_MAGASIN (
    annee INT NOT NULL,
    mois INT NOT NULL,
    magasin_key INT NOT NULL,
    ca_vente DECIMAL(14,2),
    ca_location DECIMAL(14,2),
    ca_total DECIMAL(14,2),
    PRIMARY KEY (annee, mois, magasin_key),
    CONSTRAINT fk_agg_ca_magasin
        FOREIGN KEY (magasin_key) REFERENCES DIM_MAGASIN(magasin_key)
) ENGINE=InnoDB;
