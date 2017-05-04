# -*- coding: utf-8 -*-
import pdb
import logging
import psycopg2
import time
import sys
import os
from shutil import rmtree
from optparse import OptionParser
from owslib.csw import CatalogueServiceWeb
from owslib.ows import ExceptionReport

##############################
# STRUCTURE FICHIER CSV :
# num_idg, name_idg, begin_record, end_record, MAXR, url_idg, url_csw
# exemple : 30,GeoPicardie,0,0,30,http://www.geopicardie.fr/,http://www.geopicardie.fr/geonetwork/srv/eng/csw-for-harvesters
# Pas d'en-têtes de colonnes, les lignes du CSV peuvent être commentées avec #
#
# begin_record et end_record : 1er et dernier enregistrements à récupérer, mettre à 0 pour récupérer tous les enregistrements
# MAXR : le "pas" de la requête, chaque requête récupèrera MAXR enregistrements qui seront aussitôt intégrés dans la base
##############################


# récupère les id en cours, pour rajouter les valeurs à la suite dans les tables de la base
def get_current_id(id_name, table):
    con = None
    con = psycopg2.connect("host=" + host + " port=" + port + " dbname=" + dbname + " user=" + user + " password=" + password)
#    con = psycopg2.connect("dbname=" + dbname + " user=" + user + " password=" + password)
    cur = con.cursor()
    query = 'select max(' + id_name + ') from ' + schema + '.' + table + ';'
    try:
        cur.execute(query)
        idt = cur.fetchone()[0] + 1
    except:
        idt = 0
    cur.close()
    con.close()
    return idt

#  vérifie si l'IDG existe déjà dans la table SDI
def id_sdi_already_exists(id_sdi):
    con = None
    con = psycopg2.connect("host=" + host + " port=" + port + " dbname=" + dbname + " user=" + user + " password=" + password)
#    con = psycopg2.connect("dbname=" + dbname + " user=" + user + " password=" + password)
    cur = con.cursor()
    query = 'select * from ' + schema + '.sdi where id_sdi=' + id_sdi;
    try:
        cur.execute(query)
        if not cur.fetchone():
            exists = False
        else :
            exists = True
    except:
        exists = False
    cur.close()
    con.close()
    return exists

#base et utilisateur postgres
host = 'localhost'
port = '5432'
dbname = 'csw_harvester'
schema = 'public'
user = 'postgres'
password = 'postgres'


# compteurs pour les identifiants (0)
id_metadata = get_current_id('id_metadata', 'metadata')
id_keyword = get_current_id('id_keyword', 'keyword')
id_responsibleparty = get_current_id('id_responsibleparty', 'responsibleparty')

logger = logging.getLogger('CSW harvester')
FORMAT = '%(asctime)-15s %(name)s: %(levelname)s: %(message)s'
LOG_FILE = 'csw-harvester.log'

outputschema = 'http://www.isotc211.org/2005/gmd'
sources = 'sources-csw.csv'
completion = False
#date = time.strftime("%d/%m/%Y") # dd/mm/yyyy, ex. '31/08/2015'. Par défaut, date du jour : time.strftime("%d/%m/%Y")
date = time.strftime("%Y-%m-%d") # yyyy-mm-dd, ex. '2015-08-31'. Par défaut, date du jour : time.strftime("%Y-%m-%d")

parser = OptionParser()

parser.add_option("-f", "--outputschema", dest="outputschema",
                  action="store", default=outputschema,
                  help="outputschema : default = " + outputschema)
parser.add_option("-s", "--sources", dest="sources",
                  action="store", default=sources,
                  help="CSV file, 7 fields separated by comma: num_idg, name_idg, begin_record, end_record, MAXR, url, url_idg")
parser.add_option("-l", "--log-file", dest="log_file",
                  action="store", default=LOG_FILE,
                  help="LOG file")
parser.add_option("-c", "--completion", dest="completion",
                  action="store_true", default=False,
                  help="completion mode")
parser.add_option("-d", "--date", dest="date",
                  action="store", default=date,
                  help="Extraction date")


def init_logging(log_file, level=logging.INFO):
    logging.basicConfig(format=FORMAT, level=level)
    root = logging.getLogger('')
    formatter = logging.Formatter(FORMAT)
    hdlr = logging.FileHandler(log_file)
    hdlr.setFormatter(formatter)
    root.addHandler(hdlr)


# création du dictionnaire vide de la bdd : dico de dico
# clés = noms des tables puis clés = noms des colonnes
def create_dico_bdd():
    dico_bdd = {'sdi' : {'id_sdi':[], 'name':[], 'url':[], 'url_csw':[]},
            'extraction' : {'id_sdi':[], 'id_metadata':[], 'date_extraction':[]},
            'metadata' : {'id_metadata':[], 'identifier':[], 'datestamp':[], 'xml':[], 'stdname':[]},
            'dataidentification' : {'id_dataidentification':[], 'identtype':[]},
            'geographicboundingbox' : {'id_geographicboundingbox':[], 'maxx':[], 'maxy':[], 'minx':[], 'miny':[]},
            'keyword' : {'id_keyword':[], 'keywords':[], 'thesaurus_title':[], 'type':[], 'id_dataidentification':[]},
            'contact' : {'id_dataidentification':[], 'id_responsibleparty':[], 'type_contact':[]},
            'responsibleparty' : {'id_responsibleparty':[], 'city':[], 'role':[], 'organization':[]}
            }

    return dico_bdd


def get_records(num, name, begin_record, end_record, MAXR, url, url_csw):

    (options, args) = parser.parse_args()
    completion = options.completion

    try:
        csw = CatalogueServiceWeb(url_csw)
    except:
        logger.error('Cannot connect to %s' % url_csw)
        return
    while True:
        try:
            # nb d'enregistrements à récupérer
            nb_records = end_record - begin_record + 1
            # si le nb d'enregistrements à récupérer est plus petit que MAXR
            if end_record and nb_records < MAXR:
                MAXR = nb_records

            #type_query = PropertyIsEqualTo('csw:Type', 'dataset')
            queries = {#'constraints' : [type_query],
                       'maxrecords' : MAXR,
                       'esn': 'full',
                       'outputschema': outputschema,
                       'startposition': begin_record}

            # on récupère les MAXR (ou moins) premiers enregistrements

            csw.getrecords2(**queries)
            break
        except ExceptionReport as e:
            begin_record = begin_record + 1
            logger.error('error : %s ; starting from the next record %s' % (e,begin_record))

    # pour les mettre dans un dico
    csw_records = csw.records
    # si on est en mode "complétion" : il ne doit pas y avoir de doublons au niveau des id longs de md
    if completion == True:        
        check_id_md(csw_records, num, options.date)
    # si end_record est spécifié et possible, on le prend en compte :
    if end_record and end_record < csw.results['matches'] :
        getMATCHES = end_record
    # si non : récupèrera tous les enregistrements
    else:
        getMATCHES = csw.results['matches'] # nb d'enregistrements du catalogue
    logger.info('matches %s (from %s to %s) ; first record %s ; nextrecord %s ; returned %s' % (getMATCHES-begin_record+1, begin_record, getMATCHES, queries['startposition'], csw.results['nextrecord'], csw.results['returned']))

    # création du dico vide pour stocker les valeurs
    dico_bdd = create_dico_bdd()

    # vérif des métadonnées : si une fiche ne comporte pas toutes les rubriques recherchées, elle ne sera pas traitée
    values_checked = check_md(name, csw_records.values())
    # récupération des données à rentrer dans la base : un dico par table, un sous-dico par colonne
    dico_values = get_xml_values(dico_bdd, values_checked, csw_records.keys(), name, url, url_csw, num)
    # si l'IDG existe (relance du script à une date ultérieure ou suite à bug), il ne faut pas rajouter la ligne correspondant à l'idg dans la table sdi puisqu'elle y est déjà
    if id_sdi_already_exists(num):
        for key in dico_values['sdi'].keys():
            dico_values['sdi'][key] = []
    # peuplement de la base
    fill_db(dico_values)
    logger.info('%s first values from %s inserted into database' % (MAXR, name))
    # récupère les enregistrements suivants
    while (csw.results['nextrecord'] <= getMATCHES):
        try:
            queries['startposition'] = csw.results['nextrecord']
            while True:
                try:

                    # si rajouter MAXR enregistrements en récupèrerait trop par rapport au end_record spécifié :
                    if csw.results['nextrecord'] + MAXR - 1 > getMATCHES :
                        queries['maxrecords'] = ((getMATCHES - begin_record) % MAXR) + 1 # nb d'enregistrements restant à récupérer
                    csw.getrecords2(**queries)
                    break
                except ExceptionReport as e:
                    queries['startposition'] = queries['startposition'] + 1
                    logger.error('error : %s ; starting from the next record %s' % (e,queries['startposition']))
        except Exception as e:
            logger.error(e)
            continue
        csw_records = csw.records
        # si on est en mode "complétion" : il ne doit pas y avoir de doublons au niveau des id longs de md
        if completion == True:
            check_id_md(csw_records, num, options.date)
        logger.info('matches %s (from %s to %s) ; first record %s ; nextrecord %s ; returned %s' % (getMATCHES-begin_record+1, begin_record, getMATCHES, queries['startposition'], csw.results['nextrecord'], csw.results['returned']))
        # création du dico vide pour stocker les valeurs
        dico_bdd = create_dico_bdd()
        # vérif des métadonnées : si une fiche ne comporte pas toutes les rubriques recherchées, elle ne sera pas traitée
        values_checked = check_md(name, csw_records.values())
        # mise à jour des identifiants
        id_metadata = get_current_id('id_metadata', 'metadata')
        id_keyword = get_current_id('id_keyword', 'keyword')
        id_responsibleparty = get_current_id('id_responsibleparty', 'responsibleparty')
        # récupération des données à rentrer dans la base : un dico par table, un sous-dico par colonne
        dico_values = get_xml_values(dico_bdd, values_checked, csw_records.keys(), name, url, url_csw, num)
        # il ne faut pas rajouter la ligne correspondant à l'idg dans la table sdi puisqu'elle y est déjà
        if id_sdi_already_exists(num):
            for key in dico_values['sdi'].keys():
                dico_values['sdi'][key] = []
        # peuplement de la base
        fill_db(dico_values)
        logger.info('%s next values from %s inserted into database' % (csw.results['returned'], name))

    return csw_records


# récupération des données à rentrer dans la base
def get_xml_values(dico_values, values, keys, name, url, url_csw, num):

    (options, args) = parser.parse_args()
    date = options.date

    global id_metadata
    global id_keyword
    global id_responsibleparty

    # table METADATA
    dico_values['metadata']['id_metadata'] = range(id_metadata, id_metadata + len(values))
    dico_values['metadata']['identifier'] = [i for i in keys]
    get_value_list(values, dico_values['metadata']['datestamp'], 'datetimestamp', -1)
    get_value_list(values, dico_values['metadata']['xml'], 'xml', -1)
    get_value_list(values, dico_values['metadata']['stdname'], 'stdname', 100)

    # table DATAIDENTIFICATION
    dico_values['dataidentification']['id_dataidentification'] = range(id_metadata, id_metadata + len(values))
    get_value_list(values, dico_values['dataidentification']['identtype'], 'identification.identtype', 150)

    # table KEYWORD
    liste_keywords = [i.identification.keywords for i in values]
    for index, liste in enumerate(liste_keywords):
        for dico in liste:
            for keyword in dico['keywords']:
                dico_values['keyword']['id_keyword'].append(id_keyword)
                dico_values['keyword']['id_dataidentification'].append(index + id_metadata)
                try:
                    dico_values['keyword']['keywords'].append(keyword[:250])
                    dico_values['keyword']['thesaurus_title'].append(dico['thesaurus']['title'])
                    dico_values['keyword']['type'].append(dico['type'][:50])
                except (AttributeError, TypeError):
                    dico_values['keyword']['keywords'].append(None)
                    dico_values['keyword']['thesaurus_title'].append(None)
                    dico_values['keyword']['type'].append(None)
                id_keyword+=1

    # table GEOGRAPHICBOUNDINGBOX
    dico_values['geographicboundingbox']['id_geographicboundingbox'] = range(id_metadata, id_metadata + len(values))
    get_value_list(values, dico_values['geographicboundingbox']['maxx'], 'identification.bbox.maxx', 50)
    get_value_list(values, dico_values['geographicboundingbox']['minx'], 'identification.bbox.minx', 50)
    get_value_list(values, dico_values['geographicboundingbox']['maxy'], 'identification.bbox.maxy', 50)
    get_value_list(values, dico_values['geographicboundingbox']['miny'], 'identification.bbox.miny', 50)

    # tables RESPONSIBLEPARTY et CONTACT
    contacts = [i.identification.contact for i in values]
    contributors = [i.identification.contributor for i in values]
    creators = [i.identification.creator for i in values]
    get_value_resp(dico_values, contacts, 'contact', 'yes')
    get_value_resp(dico_values, creators, 'creator', 'no')
    get_value_resp(dico_values, contributors, 'contributor', 'no')

    # table EXTRACTION
    dico_values['extraction']['id_sdi'] = [num for i in values]
    dico_values['extraction']['id_metadata'] = range(id_metadata, id_metadata + len(values))
    dico_values['extraction']['date_extraction'] = [date for i in values] # dd/mm/yyyy, ex. 31/08/2015

    # table SDI
    dico_values['sdi']['id_sdi'] = [num]
    dico_values['sdi']['name'] = [name]
    dico_values['sdi']['url'] = [url]
    dico_values['sdi']['url_csw'] = [url_csw]

    # incrément de l'id
    id_metadata = id_metadata + len(values)

    return dico_values


# pour les valeurs de responsibleparty
def get_value_resp(dico_values, bigliste, type_contact, id_yes):
    global id_responsibleparty
    for index, liste in enumerate(bigliste):
        for el in liste:
            if id_yes == 'yes':
                dico_values['contact']['id_dataidentification'].append(index + id_metadata)
            dico_values['contact']['id_responsibleparty'].append(id_responsibleparty)
            dico_values['contact']['type_contact'].append(type_contact)
            dico_values['responsibleparty']['id_responsibleparty'].append(id_responsibleparty)
            try:
                dico_values['responsibleparty']['city'].append(el.city)
            except(AttributeError, TypeError):
                dico_values['responsibleparty']['city'].append(None)
            try:
                dico_values['responsibleparty']['role'].append(el.role)
            except(AttributeError, TypeError):
                dico_values['responsibleparty']['role'].append(None)
            try:
                dico_values['responsibleparty']['organization'].append(el.organization)
            except(AttributeError, TypeError):
                dico_values['responsibleparty']['organization'].append(None)
            id_responsibleparty+=1


# vérifie si l'identifiant long de la md est déjà dans la base pour une idg et une même date
def check_id_md(csw_records, id_sdi, date_extraction):

    # list of future ids
    future_ids = csw_records.keys()

    # list of current ids
    con = None
    con = psycopg2.connect("host=" + host + " port=" + port + " dbname=" + dbname + " user=" + user + " password=" + password)
#    con = psycopg2.connect("dbname=" + dbname + " user=" + user + " password=" + password)
    cur = con.cursor()
    query = 'select metadata.identifier from ' + schema + '.metadata, ' + schema + '.sdi, '  \
    + schema + '.extraction where metadata.id_metadata = extraction.id_metadata and extraction.id_sdi = sdi.id_sdi and sdi.id_sdi = ' \
    + id_sdi + " and extraction.date_extraction='" + date_extraction + "';"
    cur.execute(query)
    current_ids = [record[0] for record in cur]
    cur.close()
    con.close()

    # vérif
    for id_md in future_ids:
        if id_md in current_ids:
            csw_records.pop(id_md)


# vérifie si la métadonnée comporte bien les rubriques recherchées
def check_md(name, values):
    values_checked = []
    nb_bad = 0
    for i in values:
        if all([hasattr(i, 'datetimestamp'),
                hasattr(i, 'xml'),
                hasattr(i, 'stdname'),
                hasattr(i, 'identification')]):
            if all([hasattr(i.identification, 'identtype'),
                    hasattr(i.identification, 'keywords'),
                    hasattr(i.identification, 'contact'),
                    hasattr(i.identification, 'contributor'),
                    hasattr(i.identification, 'creator'),
                    hasattr(i.identification, 'bbox')]):
                if all([hasattr(i.identification.bbox, 'maxx'),
                        hasattr(i.identification.bbox, 'maxy'),
                        hasattr(i.identification.bbox, 'minx'),
                        hasattr(i.identification.bbox, 'miny')]):
                    values_checked.append(i)
                else:
                    nb_bad = nb_bad + 1
    if nb_bad != 0:
        logger.info('%s : nb de fiches ne possédant pas les rubriques requises : %s' % (name, nb_bad))
    return values_checked


# pour récupérer les valeurs quand il y a plusieurs attributs emboîtés
def get_value_list(values, liste, path, nb_max_char):
    for i in values:
        try:
            attr = reduce(getattr, path.split("."), i) # http://stackoverflow.com/questions/11975781/
            if nb_max_char > 0:
                liste.append(attr[:nb_max_char])
            else:
                liste.append(attr)
        except(AttributeError, TypeError):
            liste.append(None)
            pass


# remplissage de la base postgres à partir du dico des valeurs
def fill_db(dico_values):
    con = None
    con = psycopg2.connect("host=" + host + " port=" + port + " dbname=" + dbname + " user=" + user + " password=" + password)
#    con = psycopg2.connect("dbname=" + dbname + " user=" + user + " password=" + password)
    cur = con.cursor()
    list_table = ['sdi','metadata','extraction','dataidentification','geographicboundingbox','keyword','responsibleparty','contact']
    for table in list_table:
        colonnes = dico_values[table].keys()
        s = ['%s' for i in colonnes] # ["%s", "%s", "%s", ...]
        str_colonnes = ', '.join(colonnes) # "column1, column2, column3, ..."
        str_s = ', '.join(s) # "%s, %s, %s"
        query = "INSERT INTO " + schema + '.' + table + " (" + str_colonnes + ") VALUES (" + str_s + ")"
        # turns dico_values[table] into list of lists
        list_lists = [dico_values[table][i] for i in colonnes]
        # zip lists of list_lists (sorry)
        val = map(list, zip(*list_lists))
        cur.executemany(query, val)
    con.commit()


def main():
    (options, args) = parser.parse_args()
    sources = options.sources
    outputschema = options.outputschema
    log_file = options.log_file
    init_logging(log_file)
    try:
        CSWsources = open(sources)
    except:
        logger.error("Unable to open : %s" % sources)
        sys.exit()

    for source in CSWsources.readlines():
        if source[0] != '#':
            num = source.split(',')[0]
            name = source.split(',')[1]
            begin_record = int(source.split(',')[2])
            end_record = int(source.split(',')[3])
            MAXR = int(source.split(',')[4])
            url = source.split(',')[5]
            url_csw = source.split(',')[6].strip('\n')
            csw_records = get_records(num, name, begin_record, end_record, MAXR, url, url_csw)


if __name__ == "__main__":
    sys.exit(main())
