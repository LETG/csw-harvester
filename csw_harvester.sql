--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.23
-- Dumped by pg_dump version 9.3.2
-- Started on 2016-10-24 09:24:27

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2004 (class 1262 OID 40960)
-- Name: csw_harvester; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE csw_harvester WITH TEMPLATE = template0 ENCODING = 'UTF8';


ALTER DATABASE csw_harvester OWNER TO postgres;

\connect csw_harvester

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 186 (class 3079 OID 11750)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2006 (class 0 OID 0)
-- Dependencies: 186
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 170 (class 1259 OID 49214)
-- Name: contact; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--


CREATE TABLE contact (
    id_dataidentification integer NOT NULL,
    id_responsibleparty bigint NOT NULL,
    type_contact character(150)
);


ALTER TABLE public.contact OWNER TO postgres;

--
-- TOC entry 171 (class 1259 OID 49217)
-- Name: contact_id_dataidentification_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE contact_id_dataidentification_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contact_id_dataidentification_seq OWNER TO postgres;

--
-- TOC entry 2007 (class 0 OID 0)
-- Dependencies: 171
-- Name: contact_id_dataidentification_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE contact_id_dataidentification_seq OWNED BY contact.id_dataidentification;


--
-- TOC entry 172 (class 1259 OID 49219)
-- Name: dataidentification; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dataidentification (
    id_dataidentification integer NOT NULL,
    identtype character(150)
);
ALTER TABLE public.dataidentification OWNER TO postgres;

--
-- TOC entry 173 (class 1259 OID 49222)
-- Name: dataidentification_id_dataidentification_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dataidentification_id_dataidentification_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dataidentification_id_dataidentification_seq OWNER TO postgres;

--
-- TOC entry 2008 (class 0 OID 0)
-- Dependencies: 173
-- Name: dataidentification_id_dataidentification_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dataidentification_id_dataidentification_seq OWNED BY dataidentification.id_dataidentification;


--
-- TOC entry 174 (class 1259 OID 49224)
-- Name: extraction; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE extraction (
    id_sdi integer NOT NULL,
    id_metadata bigint NOT NULL,
    date_extraction date NOT NULL
);


ALTER TABLE public.extraction OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 49227)
-- Name: extraction_id_sdi_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE extraction_id_sdi_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extraction_id_sdi_seq OWNER TO postgres;

--
-- TOC entry 2009 (class 0 OID 0)
-- Dependencies: 175
-- Name: extraction_id_sdi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE extraction_id_sdi_seq OWNED BY extraction.id_sdi;


--
-- TOC entry 176 (class 1259 OID 49229)
-- Name: geographicboundingbox; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geographicboundingbox (
    id_geographicboundingbox integer NOT NULL,
    maxx text,
    maxy text,
    minx text,
    miny text
);


ALTER TABLE public.geographicboundingbox OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 49232)
-- Name: geographicboundingbox_id_geographicboundingbox_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE geographicboundingbox_id_geographicboundingbox_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geographicboundingbox_id_geographicboundingbox_seq OWNER TO postgres;

--
-- TOC entry 2010 (class 0 OID 0)
-- Dependencies: 177
-- Name: geographicboundingbox_id_geographicboundingbox_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE geographicboundingbox_id_geographicboundingbox_seq OWNED BY geographicboundingbox.id_geographicboundingbox;


--
-- TOC entry 178 (class 1259 OID 49234)
-- Name: keyword; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE keyword (
    id_keyword integer NOT NULL,
    keywords character varying(250),
    thesaurus_title character varying(250),
    type character varying(100),
    id_dataidentification bigint NOT NULL
);


ALTER TABLE public.keyword OWNER TO postgres;

--
-- TOC entry 179 (class 1259 OID 49240)
-- Name: keyword_id_keyword_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE keyword_id_keyword_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.keyword_id_keyword_seq OWNER TO postgres;

--
-- TOC entry 2011 (class 0 OID 0)
-- Dependencies: 179
-- Name: keyword_id_keyword_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE keyword_id_keyword_seq OWNED BY keyword.id_keyword;


--
-- TOC entry 180 (class 1259 OID 49242)
-- Name: metadata; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE metadata (
    id_metadata integer NOT NULL,
    identifier character varying(2000),
    datestamp date,
    xml_text text,
    stdname character varying(100),
    xml xml
);


ALTER TABLE public.metadata OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 49248)
-- Name: metadata_id_metadata_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE metadata_id_metadata_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metadata_id_metadata_seq OWNER TO postgres;

--
-- TOC entry 2012 (class 0 OID 0)
-- Dependencies: 181
-- Name: metadata_id_metadata_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE metadata_id_metadata_seq OWNED BY metadata.id_metadata;


--
-- TOC entry 182 (class 1259 OID 49250)
-- Name: responsibleparty; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE responsibleparty (
    id_responsibleparty integer NOT NULL,
    city character varying(150),
    role character varying(150),
    organization character varying(250)
);


ALTER TABLE public.responsibleparty OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 49256)
-- Name: responsibleparty_id_responsibleparty_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE responsibleparty_id_responsibleparty_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.responsibleparty_id_responsibleparty_seq OWNER TO postgres;

--
-- TOC entry 2013 (class 0 OID 0)
-- Dependencies: 183
-- Name: responsibleparty_id_responsibleparty_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE responsibleparty_id_responsibleparty_seq OWNED BY responsibleparty.id_responsibleparty;


--
-- TOC entry 184 (class 1259 OID 49258)
-- Name: sdi; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sdi (
    id_sdi integer NOT NULL,
    name character varying(100),
    url character varying(250),
    url_csw character varying(300)
);


ALTER TABLE public.sdi OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 49264)
-- Name: sdi_id_sdi_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sdi_id_sdi_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sdi_id_sdi_seq OWNER TO postgres;

--
-- TOC entry 2014 (class 0 OID 0)
-- Dependencies: 185
-- Name: sdi_id_sdi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sdi_id_sdi_seq OWNED BY sdi.id_sdi;


--
-- TOC entry 1869 (class 2604 OID 49266)
-- Name: id_dataidentification; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact ALTER COLUMN id_dataidentification SET DEFAULT nextval('contact_id_dataidentification_seq'::regclass);


--
-- TOC entry 1870 (class 2604 OID 49267)
-- Name: id_dataidentification; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dataidentification ALTER COLUMN id_dataidentification SET DEFAULT nextval('dataidentification_id_dataidentification_seq'::regclass);


--
-- TOC entry 1871 (class 2604 OID 49268)
-- Name: id_sdi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY extraction ALTER COLUMN id_sdi SET DEFAULT nextval('extraction_id_sdi_seq'::regclass);


--
-- TOC entry 1872 (class 2604 OID 49269)
-- Name: id_geographicboundingbox; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geographicboundingbox ALTER COLUMN id_geographicboundingbox SET DEFAULT nextval('geographicboundingbox_id_geographicboundingbox_seq'::regclass);


--
-- TOC entry 1873 (class 2604 OID 49270)
-- Name: id_keyword; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY keyword ALTER COLUMN id_keyword SET DEFAULT nextval('keyword_id_keyword_seq'::regclass);


--
-- TOC entry 1874 (class 2604 OID 49271)
-- Name: id_metadata; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY metadata ALTER COLUMN id_metadata SET DEFAULT nextval('metadata_id_metadata_seq'::regclass);


--
-- TOC entry 1875 (class 2604 OID 49272)
-- Name: id_responsibleparty; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY responsibleparty ALTER COLUMN id_responsibleparty SET DEFAULT nextval('responsibleparty_id_responsibleparty_seq'::regclass);


--
-- TOC entry 1876 (class 2604 OID 49273)
-- Name: id_sdi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sdi ALTER COLUMN id_sdi SET DEFAULT nextval('sdi_id_sdi_seq'::regclass);


--
-- TOC entry 1878 (class 2606 OID 49275)
-- Name: contact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id_dataidentification, id_responsibleparty);


--
-- TOC entry 1880 (class 2606 OID 49277)
-- Name: dataidentification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dataidentification
    ADD CONSTRAINT dataidentification_pkey PRIMARY KEY (id_dataidentification);


--
-- TOC entry 1882 (class 2606 OID 49279)
-- Name: extraction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY extraction
    ADD CONSTRAINT extraction_pkey PRIMARY KEY (id_sdi, id_metadata, date_extraction);


--
-- TOC entry 1884 (class 2606 OID 49281)
-- Name: geographicboundingbox_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geographicboundingbox
    ADD CONSTRAINT geographicboundingbox_pkey PRIMARY KEY (id_geographicboundingbox);


--
-- TOC entry 1886 (class 2606 OID 49283)
-- Name: keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY keyword
    ADD CONSTRAINT keyword_pkey PRIMARY KEY (id_keyword);


--
-- TOC entry 1888 (class 2606 OID 49285)
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (id_metadata);


--
-- TOC entry 1890 (class 2606 OID 49287)
-- Name: responsibleparty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY responsibleparty
    ADD CONSTRAINT responsibleparty_pkey PRIMARY KEY (id_responsibleparty);


--
-- TOC entry 1892 (class 2606 OID 49289)
-- Name: sdi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sdi
    ADD CONSTRAINT sdi_pkey PRIMARY KEY (id_sdi);


--
-- TOC entry 2005 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT fk_contact_id_dataidentification FOREIGN KEY (id_dataidentification) REFERENCES dataidentification(id_dataidentification) ON DELETE CASCADE;


--
-- TOC entry 3091 (class 2606 OID 3281776)
-- Name: fk_contact_id_responsibleparty; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT fk_contact_id_responsibleparty FOREIGN KEY (id_responsibleparty) REFERENCES responsibleparty(id_responsibleparty) ON DELETE CASCADE;


--
-- TOC entry 3092 (class 2606 OID 3281781)
-- Name: fk_dataidentification_metadata; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dataidentification
    ADD CONSTRAINT fk_dataidentification_metadata FOREIGN KEY (id_dataidentification) REFERENCES metadata(id_metadata) ON DELETE CASCADE;


--
-- TOC entry 3093 (class 2606 OID 3281786)
-- Name: fk_extraction_id_metadata; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY extraction
    ADD CONSTRAINT fk_extraction_id_metadata FOREIGN KEY (id_metadata) REFERENCES metadata(id_metadata) ON DELETE CASCADE;


--
-- TOC entry 3094 (class 2606 OID 3281791)
-- Name: fk_extraction_id_sdi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY extraction
    ADD CONSTRAINT fk_extraction_id_sdi FOREIGN KEY (id_sdi) REFERENCES sdi(id_sdi) ON DELETE CASCADE;


--
-- TOC entry 3095 (class 2606 OID 3281796)
-- Name: fk_geographicboundingbox_dataidentification; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geographicboundingbox
    ADD CONSTRAINT fk_geographicboundingbox_dataidentification FOREIGN KEY (id_geographicboundingbox) REFERENCES dataidentification(id_dataidentification) ON DELETE CASCADE;


--
-- TOC entry 3096 (class 2606 OID 3281801)
-- Name: fk_keyword_id_dataidentification; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY keyword
    ADD CONSTRAINT fk_keyword_id_dataidentification FOREIGN KEY (id_dataidentification) REFERENCES dataidentification(id_dataidentification) ON DELETE CASCADE;


--
-- TOC entry 3204 (class 0 OID 0)
-- Dependencies: 293
-- Name: contact; Type: ACL; Schema: public; Owner: postgres
--


REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;

-- Completed on 2016-10-24 09:24:27

--
-- PostgreSQL database dump complete
--

