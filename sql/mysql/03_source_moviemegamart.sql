USE mm_src_moviemegamart;

DROP TABLE IF EXISTS LOCATION_FILM;
DROP TABLE IF EXISTS VENTE_FILM;
DROP TABLE IF EXISTS VENTE_GADGET;
DROP TABLE IF EXISTS REFERENCE_FILM;
DROP TABLE IF EXISTS MODELE_GADGET;
DROP TABLE IF EXISTS CLIENT;

CREATE TABLE CLIENT (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    nom_client VARCHAR(255),
    sexe_masculin TINYINT(1),
    date_naissance DATE,
    adresse VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE MODELE_GADGET (
    gadget_id INT PRIMARY KEY AUTO_INCREMENT,
    type_gadget VARCHAR(100),
    titre_gadget VARCHAR(255),
    UNIQUE KEY uk_modele_gadget_nature (type_gadget, titre_gadget)
) ENGINE=InnoDB;

CREATE TABLE REFERENCE_FILM (
    film_id INT PRIMARY KEY
) ENGINE=InnoDB;

CREATE TABLE VENTE_GADGET (
    vente_gadget_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    gadget_id INT NOT NULL,
    date_inventaire DATETIME,
    prix_inventaire DECIMAL(10,2),
    date_vente DATETIME,
    prix_vente DECIMAL(10,2),
    CONSTRAINT fk_movie_vente_gadget_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_movie_vente_gadget_modele
        FOREIGN KEY (gadget_id) REFERENCES MODELE_GADGET(gadget_id),
    INDEX idx_movie_vente_gadget_client (client_id),
    INDEX idx_movie_vente_gadget_modele (gadget_id),
    INDEX idx_movie_vente_gadget_date (date_vente)
) ENGINE=InnoDB;

CREATE TABLE VENTE_FILM (
    vente_film_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    film_id INT NOT NULL,
    date_vente DATETIME,
    prix_vente DECIMAL(10,2),
    CONSTRAINT fk_movie_vente_film_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_movie_vente_film_reference
        FOREIGN KEY (film_id) REFERENCES REFERENCE_FILM(film_id),
    INDEX idx_movie_vente_film_client (client_id),
    INDEX idx_movie_vente_film_film (film_id),
    INDEX idx_movie_vente_film_date (date_vente)
) ENGINE=InnoDB;

CREATE TABLE LOCATION_FILM (
    location_film_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    film_id INT NOT NULL,
    date_debut DATETIME,
    date_fin DATETIME,
    prix_location DECIMAL(10,2),
    CONSTRAINT fk_movie_location_film_client
        FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_movie_location_film_reference
        FOREIGN KEY (film_id) REFERENCES REFERENCE_FILM(film_id),
    INDEX idx_movie_location_film_client (client_id),
    INDEX idx_movie_location_film_film (film_id),
    INDEX idx_movie_location_film_date_debut (date_debut)
) ENGINE=InnoDB;
