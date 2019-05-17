CREATE DATABASE  IF NOT EXISTS `taxi` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `taxi`;
-- MySQL dump 10.13  Distrib 5.7.26, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: taxi
-- ------------------------------------------------------
-- Server version	5.7.26-0ubuntu0.18.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cab`
--

DROP TABLE IF EXISTS `cab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cab` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `color` varchar(45) NOT NULL,
  `license_plate` varchar(45) NOT NULL,
  `car_model_id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_auto_car_model1_idx` (`car_model_id`),
  KEY `fk_cab_driver1_idx` (`driver_id`),
  CONSTRAINT `fk_auto_car_model1` FOREIGN KEY (`car_model_id`) REFERENCES `car_model` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_cab_driver1` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cab`
--

LOCK TABLES `cab` WRITE;
/*!40000 ALTER TABLE `cab` DISABLE KEYS */;
/*!40000 ALTER TABLE `cab` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cab_ride`
--

DROP TABLE IF EXISTS `cab_ride`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cab_ride` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `shift_id` int(11) DEFAULT NULL,
  `ride_start_time` timestamp NULL DEFAULT NULL,
  `ride_end_time` timestamp NULL DEFAULT NULL,
  `GPS_starting_point` text,
  `entrance` int(11) DEFAULT NULL,
  `GPS_destination` text,
  `canceled` tinyint(1) DEFAULT '0',
  `order_for_another` tinyint(1) DEFAULT '0',
  `pending_order` tinyint(1) DEFAULT '0',
  `payment_type_id` int(11) NOT NULL DEFAULT '1',
  `price` int(11) DEFAULT '100',
  `comment` text,
  `feedback` text,
  PRIMARY KEY (`id`),
  KEY `fk_cab_ride_customer1_idx` (`customer_id`),
  KEY `fk_cab_ride_payment_type1_idx` (`payment_type_id`),
  KEY `fk_cab_ride_shift1_idx` (`shift_id`),
  CONSTRAINT `fk_cab_ride_customer1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_cab_ride_payment_type1` FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_cab_ride_shift1` FOREIGN KEY (`shift_id`) REFERENCES `shift` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cab_ride`
--

LOCK TABLES `cab_ride` WRITE;
/*!40000 ALTER TABLE `cab_ride` DISABLE KEYS */;
/*!40000 ALTER TABLE `cab_ride` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cab_ride_status`
--

DROP TABLE IF EXISTS `cab_ride_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cab_ride_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cab_ride_id` int(11) NOT NULL,
  `shift_id` int(11) DEFAULT NULL,
  `status_time` int(11) DEFAULT '0',
  `ride_status` int(11) DEFAULT '0',
  `status_details` int(11) DEFAULT '0',
  `dispatcher_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cab_ride_status_cab_ride1_idx` (`cab_ride_id`),
  KEY `fk_cab_ride_status_dispatcher1_idx` (`dispatcher_id`),
  KEY `fk_cab_ride_status_shift1_idx` (`shift_id`),
  CONSTRAINT `fk_cab_ride_status_cab_ride1` FOREIGN KEY (`cab_ride_id`) REFERENCES `cab_ride` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cab_ride_status_dispatcher1` FOREIGN KEY (`dispatcher_id`) REFERENCES `dispatcher` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_cab_ride_status_shift1` FOREIGN KEY (`shift_id`) REFERENCES `shift` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cab_ride_status`
--

LOCK TABLES `cab_ride_status` WRITE;
/*!40000 ALTER TABLE `cab_ride_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `cab_ride_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_brand`
--

DROP TABLE IF EXISTS `car_brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `car_brand` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `brand_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_brand`
--

LOCK TABLES `car_brand` WRITE;
/*!40000 ALTER TABLE `car_brand` DISABLE KEYS */;
INSERT INTO `car_brand` VALUES (1,'Microcar'),(2,'AC'),(3,'Acura'),(4,'Admiral'),(5,'Alfa Romeo'),(6,'Alpina'),(7,'Aro'),(8,'Asia'),(9,'Aston Martin'),(10,'Audi'),(11,'BMW'),(12,'BYD'),(13,'Bentley'),(14,'Brilliance'),(15,'Bugatti'),(16,'Buick'),(17,'Cadillac'),(18,'Caterham'),(19,'ChangFeng'),(20,'Chery'),(21,'Chevrolet'),(22,'Chrysler'),(23,'Citroen'),(24,'DADI'),(25,'Dacia'),(26,'Daewoo'),(27,'Daihatsu'),(28,'Daimler'),(29,'De Tomaso'),(30,'Derways'),(31,'Dodge'),(32,'Doninvest'),(33,'Donkervoort'),(34,'Eagle'),(35,'FAW'),(36,'FSO'),(37,'FSR'),(38,'Ferrari'),(39,'Fiat'),(40,'Ford'),(41,'GMC'),(42,'Geely'),(43,'Geo'),(44,'Ginetta'),(45,'Gonow'),(46,'Great Wall'),(47,'Hafei'),(48,'Holden'),(49,'Honda'),(50,'Huanghai'),(51,'Hummer'),(52,'Hyundai'),(53,'Infiniti'),(54,'Intrall'),(55,'Iran Khodro'),(56,'Isuzu'),(57,'JMC'),(58,'Jaguar'),(59,'Jeep'),(60,'Jindei'),(61,'Kia'),(62,'Lamborghini'),(63,'Lancia'),(64,'Land Rover'),(65,'Landwind'),(66,'Lexus'),(67,'Lifan'),(68,'Lincoln'),(69,'Lotus'),(70,'MG'),(71,'MINI'),(72,'Mahindra'),(73,'Marcos'),(74,'Maruti'),(75,'Maserati'),(76,'Maybach'),(77,'Mazda'),(78,'McLaren'),(79,'Mercedes-Benz'),(80,'Mercury'),(81,'Metrocab'),(82,'Mitsubishi'),(83,'Mitsuoka'),(84,'Morgan'),(85,'Nissan'),(86,'Oldsmobile'),(87,'Opel'),(88,'PUCH'),(89,'Pagani'),(90,'Panoz'),(91,'Peugeot'),(92,'Plymouth'),(93,'Pontiac'),(94,'Porsche'),(95,'Proton'),(96,'Renault'),(97,'Roewe'),(98,'Rolls-Royce'),(99,'Rover'),(100,'SEAT'),(101,'Saab'),(102,'Saleen'),(103,'Samsung'),(104,'Saturn'),(105,'Scion'),(106,'Shenlong'),(107,'Shuanghuan'),(108,'Skoda'),(109,'Smart'),(110,'Spyker'),(111,'SsangYong'),(112,'Subaru'),(113,'Suzuki'),(114,'TVR'),(115,'Talbot'),(116,'Tata'),(117,'Tatra'),(118,'Tianma'),(119,'Tianye'),(120,'Tofas'),(121,'Toyota'),(122,'Trabant'),(123,'Venturi'),(124,'Volkswagen'),(125,'Volvo'),(126,'Vortex'),(127,'Wartburg'),(128,'Wiesmann'),(129,'Xin Kai'),(130,'Yzk'),(131,'ZX'),(132,'ВАЗ'),(133,'Велта'),(134,'ГАЗ'),(135,'ЕРАЗ'),(136,'СеАЗ'),(137,'КАМАЗ'),(138,'ЗАЗ'),(139,'ЗИЛ'),(140,'ИЖ'),(141,'ЛУАЗ'),(142,'Москвич'),(143,'УАЗ');
/*!40000 ALTER TABLE `car_brand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_model`
--

DROP TABLE IF EXISTS `car_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `car_model` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_name` varchar(255) NOT NULL,
  `car_brand_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_car_model_car_brand_idx` (`car_brand_id`),
  CONSTRAINT `fk_car_model_car_brand` FOREIGN KEY (`car_brand_id`) REFERENCES `car_brand` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1879 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_model`
--

LOCK TABLES `car_model` WRITE;
/*!40000 ALTER TABLE `car_model` DISABLE KEYS */;
INSERT INTO `car_model` VALUES (1,'MC 1',1),(3,'Ace',2),(4,'Aceca',2),(5,'Cobra',2),(6,'Mamba',2),(8,'CL',3),(9,'CSX',3),(10,'EL',3),(11,'Integra',3),(12,'Legend',3),(13,'MDX',3),(14,'NSX',3),(15,'RDX',3),(16,'RL',3),(17,'RSX',3),(18,'SLX',3),(19,'TL',3),(20,'TSX',3),(22,'Pickup',4),(24,'145',5),(25,'146',5),(26,'147',5),(27,'155',5),(28,'156',5),(29,'159',5),(30,'164',5),(31,'166',5),(32,'33',5),(33,'75',5),(34,'8C Competizione',5),(35,'90',5),(36,'Alfasud',5),(37,'Alfetta',5),(38,'Brera',5),(39,'GT',5),(40,'GTV',5),(41,'Giulietta',5),(42,'MiTo',5),(43,'Spider',5),(45,'B10',6),(46,'B12',6),(47,'B3',6),(48,'B7',6),(49,'B8',6),(50,'D10',6),(51,'Roadster S',6),(53,'10',7),(54,'24',7),(55,'243',7),(56,'244',7),(57,'245',7),(58,'246',7),(59,'Spartana',7),(61,'Hi-Topic',8),(62,'Retona',8),(63,'Rocsta',8),(65,'DB7',9),(66,'DB9',9),(67,'DBS',9),(68,'V12 Vanquish',9),(69,'V8 Vantage',9),(71,'100',10),(72,'200',10),(73,'5000',10),(74,'80',10),(75,'90',10),(76,'A2',10),(77,'A3',10),(78,'A4',10),(79,'A5',10),(80,'A6',10),(81,'A6 allroad quattro',10),(82,'A8',10),(83,'Cabriolet',10),(84,'Q5',10),(85,'Q7',10),(86,'R8',10),(87,'RS4',10),(88,'RS6',10),(89,'S2',10),(90,'S3',10),(91,'S4',10),(92,'S5',10),(93,'S6',10),(94,'S8',10),(95,'TT',10),(96,'V8',10),(98,'1 series',11),(99,'3 series',11),(100,'5 series',11),(101,'6 series',11),(102,'7 series',11),(103,'8 series',11),(104,'M3',11),(105,'M5',11),(106,'M6',11),(107,'X3',11),(108,'X5',11),(109,'X6',11),(110,'Z1',11),(111,'Z3',11),(112,'Z4',11),(113,'Z4 M',11),(114,'Z8',11),(116,'F0',12),(117,'F3',12),(118,'F6',12),(119,'F6',12),(120,'Flyer',12),(122,'Arnage',13),(123,'Azure',13),(124,'Brooklands',13),(125,'Continental',13),(126,'Continental Flying Spur',13),(127,'Continental GT',13),(128,'Mulsanne',13),(129,'Turbo RT',13),(131,'M1 (Zhonghua)',14),(132,'M2 (JunJie)',14),(133,'',14),(134,'EB 110',15),(135,'EB 112',15),(136,'Veyron 16.4',15),(138,'Century',16),(139,'Electra',16),(140,'Enclave',16),(141,'GL8',16),(142,'La Crosse',16),(143,'Le Sabre',16),(144,'Lucerne',16),(145,'Park Avenue',16),(146,'Rainer',16),(147,'Regal',16),(148,'RendezVous',16),(149,'Riviera',16),(150,'Roadmaster',16),(151,'Skylark',16),(152,'Terraza',16),(154,'BLS',17),(155,'CTS',17),(156,'Catera',17),(157,'DTS',17),(158,'De Ville',17),(159,'Eldorado',17),(160,'Escalade',17),(161,'Fleetwood',17),(162,'SRX',17),(163,'STS',17),(164,'Seville',17),(165,'XLR',17),(167,'C21',18),(168,'Super Seven',18),(170,'Flying',19),(171,'SUV',19),(173,'Amulet',20),(174,'B11 (Oriental Son)',20),(175,'B14',20),(176,'Eastar',20),(177,'Fora',20),(178,'Kimo',20),(179,'QQ',20),(180,'QQ 6',20),(181,'Swift',20),(182,'Tiggo',20),(183,'Windcloud',20),(185,'Alero',21),(186,'Astro',21),(187,'Avalanche',21),(188,'Aveo',21),(189,'Beretta',21),(190,'Blazer',21),(191,'Camaro',21),(192,'Caprice',21),(193,'Captiva',21),(194,'Cavalier',21),(195,'Celta',21),(196,'Chevi C2',21),(197,'Classic',21),(198,'Cobalt',21),(199,'Colorado',21),(200,'Conversion Van',21),(201,'Corsa',21),(202,'Corsica',21),(203,'Corvette',21),(204,'Cruze',21),(205,'Epica',21),(206,'Equinox',21),(207,'Evanda',21),(208,'Express',21),(209,'Geo Storm',21),(210,'Geo Tracker',21),(211,'HHR',21),(212,'Impala',21),(213,'Ipanema',21),(214,'K3500',21),(215,'Lacetti',21),(216,'Lanos',21),(217,'Lumina',21),(218,'Malibu',21),(219,'Meriva',21),(220,'Metro',21),(221,'Montana',21),(222,'Monte Carlo',21),(223,'Monza',21),(224,'Niva',21),(225,'Nova',21),(226,'Omega',21),(227,'Prizm',21),(228,'Prizma',21),(229,'Rezzo',21),(230,'S-10',21),(231,'SSR',21),(232,'Savana',21),(233,'Silver',21),(234,'Silverado',21),(235,'Spark',21),(236,'Starcraft',21),(237,'Suburban',21),(238,'Tahoe',21),(239,'Tracker',21),(240,'TrailBlazer',21),(241,'TransSport',21),(242,'Uplander',21),(243,'Van',21),(244,'Vectra',21),(245,'Venture',21),(246,'Viva',21),(247,'Zafira',21),(249,'300C',22),(250,'300M',22),(251,'Aspen',22),(252,'Cirrus',22),(253,'Concorde',22),(254,'Crossfire',22),(255,'Daytona',22),(256,'Grand Voyager',22),(257,'Intrepid',22),(258,'LHS',22),(259,'Le Baron',22),(260,'Neon',22),(261,'New Yorker',22),(262,'PT Cruiser',22),(263,'Pacifica',22),(264,'Prowler',22),(265,'Saratoga',22),(266,'Sebring',22),(267,'Stratus',22),(268,'Town&amp;Country',22),(269,'Viper',22),(270,'Vision',22),(271,'Voyager',22),(273,'AX',23),(274,'BX',23),(275,'Berlingo',23),(276,'C-Crosser',23),(277,'C-Triomphe',23),(278,'C1',23),(279,'C15',23),(280,'C2',23),(281,'C3',23),(282,'C3 Pluriel',23),(283,'C4',23),(284,'C4 Picasso',23),(285,'C5',23),(286,'C6',23),(287,'C8',23),(288,'CX',23),(289,'Evasion',23),(290,'Grand C4 Picasso',23),(291,'Jumper',23),(292,'Jumpy',23),(293,'Saxo',23),(294,'Visa',23),(295,'XM',23),(296,'Xantia',23),(297,'Xsara',23),(298,'Xsara Picasso',23),(299,'ZX',23),(301,'City Leading',24),(302,'Shuttle',24),(303,'Smoothing',24),(305,'1304',25),(306,'1310',25),(307,'1325',25),(308,'1410',25),(309,'Logan',25),(310,'Nova',25),(312,'Arcadia',26),(313,'Brougham',26),(314,'Chairman',26),(315,'Damas',26),(316,'Espero',26),(317,'Evanda',26),(318,'GX2',26),(319,'Gentra',26),(320,'Istana',26),(321,'Kalos',26),(322,'Korando',26),(323,'Labo',26),(324,'Lacetti',26),(325,'Lanos',26),(326,'Leganza',26),(327,'Lemans',26),(328,'Magnus',26),(329,'Matiz',26),(330,'Musso',26),(331,'Nexia',26),(332,'Nubira',26),(333,'Polonez',26),(334,'Prince',26),(335,'Racer',26),(336,'Rezzo',26),(337,'Statesman',26),(338,'Super Salon',26),(339,'Tacuma',26),(340,'Tico',26),(341,'Tosca',26),(342,'Windstorm',26),(344,'Altis',27),(345,'Applause',27),(346,'Atrai',27),(347,'Be-go',27),(348,'Boon',27),(349,'Charade',27),(350,'Coo',27),(351,'Copen',27),(352,'Cuore',27),(353,'Esse',27),(354,'Extol',27),(355,'Feroza',27),(356,'Gran Move',27),(357,'Hi Jet',27),(358,'Materia',27),(359,'Max',27),(360,'Mira',27),(361,'Mobe',27),(362,'Move',27),(363,'Naked',27),(364,'Opti',27),(365,'Pizar',27),(366,'Rocky',27),(367,'Sirion',27),(368,'Sonica',27),(369,'Storia',27),(370,'Tanto',27),(371,'Taruna',27),(372,'Terios',27),(373,'Trevis',27),(374,'Xenia',27),(375,'YRV',27),(376,'Zebra',27),(378,'Limousine',28),(379,'XJ',28),(381,'Guara',29),(382,'Pantera',29),(384,'Antelope',30),(385,'Aurora',30),(386,'Cowboy',30),(387,'DADI Shuttle',30),(388,'Land Crown',30),(389,'Plutus',30),(390,'Saladin',30),(391,'Shuttle',30),(393,'600',31),(394,'Avenger',31),(395,'Caliber',31),(396,'Caravan',31),(397,'Charger',31),(398,'Dakota',31),(399,'Daytona',31),(400,'Durango',31),(401,'Dynasty',31),(402,'Grand Caravan',31),(403,'Intrepid',31),(404,'Journey',31),(405,'Magnum',31),(406,'Monaco',31),(407,'Neon',31),(408,'Nitro',31),(409,'Omni',31),(410,'Ram',31),(411,'Shadow',31),(412,'Spirit',31),(413,'Stealth',31),(414,'Stratus',31),(415,'Viper',31),(417,'Assol',32),(418,'Kondor',32),(419,'Orion',32),(421,'D8',33),(423,'Summit',34),(424,'Talon',34),(425,'Vision',34),(427,'Admiral',35),(428,'Besturn',35),(429,'HQ3',35),(430,'Jinn',35),(431,'Vita',35),(433,'Polonez',36),(435,'Tarpan Honker',37),(437,'208',38),(438,'308',38),(439,'328',38),(440,'348',38),(441,'355 Berlinetta',38),(442,'355F1',38),(443,'360 Modena',38),(444,'360 Spider',38),(445,'365',38),(446,'412',38),(447,'456 GT',38),(448,'512 M',38),(449,'550 Barchetta',38),(450,'550 Maranello',38),(451,'575 Maranello',38),(452,'599 GTB',38),(453,'612 Scaglietti',38),(454,'Enzo',38),(455,'F355 GTS',38),(456,'F355 Spider',38),(457,'F40',38),(458,'F430',38),(459,'F50',38),(460,'GTB',38),(461,'Mondial 3.2',38),(462,'Mondial 8',38),(463,'Mondial T',38),(464,'Testarossa',38),(466,'124',39),(467,'126',39),(468,'127',39),(469,'131',39),(470,'242',39),(471,'500',39),(472,'600',39),(473,'850',39),(474,'Albea',39),(475,'Barchetta',39),(476,'Brava',39),(477,'Bravo',39),(478,'Cinquecento',39),(479,'Coupe',39),(480,'Croma',39),(481,'Doblo',39),(482,'Ducato',39),(483,'Duna',39),(484,'Fiorino',39),(485,'Grande Punto',39),(486,'Idea',39),(487,'Linea',39),(488,'Marea',39),(489,'Multipla',39),(490,'Palio',39),(491,'Panda',39),(492,'Punto',39),(493,'Regata',39),(494,'Ritmo',39),(495,'Scudo',39),(496,'Sedici',39),(497,'Seicento',39),(498,'Siena',39),(499,'Stilo',39),(500,'Strada',39),(501,'Tempra',39),(502,'Tipo',39),(503,'Ulysse',39),(504,'Uno',39),(505,'X 1/9',39),(506,'',39),(507,'Aerostar',40),(508,'Aspire',40),(509,'Bronco',40),(510,'C-Max',40),(511,'Capri',40),(512,'Consul',40),(513,'Contour',40),(514,'Cougar',40),(515,'Courier',40),(516,'Crown Victoria',40),(517,'Econoline',40),(518,'Econovan',40),(519,'Edge',40),(520,'Escape',40),(521,'Escort',40),(522,'Everest',40),(523,'Excursion',40),(524,'Expedition',40),(525,'Explorer',40),(526,'F150',40),(527,'F250',40),(528,'F350',40),(529,'Fairline',40),(530,'Festiva',40),(531,'Fiesta',40),(532,'Five Hundred',40),(533,'Focus',40),(534,'Freestar',40),(535,'Freestyle',40),(536,'Fusion',40),(537,'Galaxy',40),(538,'Granada',40),(539,'Ikon',40),(540,'Ka',40),(541,'Kuga',40),(542,'Laser',40),(543,'Maverick',40),(544,'Mondeo',40),(545,'Mustang',40),(546,'Orion',40),(547,'Probe',40),(548,'Puma',40),(549,'Ranger',40),(550,'S-MAX',40),(551,'Scorpio',40),(552,'Sierra',40),(553,'Taunus',40),(554,'Taurus',40),(555,'Tempo',40),(556,'Territory',40),(557,'Thunderbird',40),(558,'Tourneo Connect',40),(559,'Transit',40),(560,'Windstar',40),(562,'Acadia',41),(563,'Canyon',41),(564,'Envoy',41),(565,'Jimmy',41),(566,'Safary',41),(567,'Savana',41),(568,'Sierra',41),(569,'Suburban',41),(570,'Typhoon',41),(571,'Vandura',41),(572,'Yukon',41),(574,'MK',42),(575,'Otaka',42),(576,'Vision',42),(578,'206',43),(579,'Prizm',43),(580,'Shtorm',43),(581,'Tracker',43),(583,'G',44),(585,'Alter',45),(586,'GX6',45),(588,'Deer',46),(589,'Hover',46),(590,'Pegasus',46),(591,'Peri',46),(592,'SUV',46),(593,'Safe',46),(594,'Sailor',46),(595,'Sing',46),(596,'Sokol',46),(597,'Wingle',46),(599,'Brio',47),(600,'Princip',47),(601,'Simbo',47),(603,'Caprice',48),(604,'Commodore',48),(605,'Statesman',48),(607,'Accord',49),(608,'Airwave',49),(609,'Ascot',49),(610,'Avancier',49),(611,'CR-V',49),(612,'CRX',49),(613,'Capa',49),(614,'City',49),(615,'Civic',49),(616,'Concerto',49),(617,'Del Sol',49),(618,'Domani',49),(619,'Element',49),(620,'Elysion',49),(621,'FR-V',49),(622,'Fit',49),(623,'HR-V',49),(624,'Insight',49),(625,'Inspire',49),(626,'Integra',49),(627,'Jazz',49),(628,'Lagreat',49),(629,'Legend',49),(630,'Life',49),(631,'Logo',49),(632,'Mobilio',49),(633,'NSX',49),(634,'Odyssey',49),(635,'Orthia',49),(636,'Partner',49),(637,'Passport',49),(638,'Pilot',49),(639,'Prelude',49),(640,'Rafaga',49),(641,'Ridgeline',49),(642,'S-MX',49),(643,'S2000',49),(644,'Saber',49),(645,'Shuttle',49),(646,'Spike',49),(647,'Stepwgn',49),(648,'Strea M',49),(649,'That\'S',49),(650,'Today',49),(651,'Torneo',49),(652,'Vamos',49),(653,'Vigor',49),(654,'Z',49),(655,'Zest',49),(657,'Antelope',50),(658,'Landscape',50),(659,'Major',50),(660,'Plutus',50),(662,'H1',51),(663,'H2',51),(664,'H3',51),(666,'Accent',52),(667,'Atos',52),(668,'Avante',52),(669,'Azera',52),(670,'Centennial',52),(671,'Coupe',52),(672,'Dynasty',52),(673,'Elantra',52),(674,'Entourage',52),(675,'Equis',52),(676,'Galloper',52),(677,'Genesis',52),(678,'Getz',52),(679,'Grandeur',52),(680,'H1 (Starex)',52),(681,'H100',52),(682,'H200',52),(683,'Lantra',52),(684,'Lavita',52),(685,'Marcia',52),(686,'Matrix',52),(687,'NF Sonata',52),(688,'Pony',52),(689,'Porter',52),(690,'S Coupe',52),(691,'Santa Fe',52),(692,'Santa Fe Classic',52),(693,'Santamo',52),(694,'Sonata',52),(695,'Stelar',52),(696,'Terracan',52),(697,'Tiburon',52),(698,'Trajet',52),(699,'Tucson',52),(700,'Tuscani',52),(701,'Veracruz',52),(702,'Verna',52),(703,'XG',52),(704,'i10',52),(705,'i30',52),(707,'EX',53),(708,'FX',53),(709,'G COUPE',53),(710,'G SEDAN',53),(711,'I',53),(712,'J30',53),(713,'M',53),(714,'Q45',53),(715,'QX',53),(717,'Honker',54),(718,'Lublin',54),(720,'Pars',55),(721,'Samand',55),(723,'Amigo',56),(724,'Ascender',56),(725,'Aska',56),(726,'Axiom',56),(727,'Bighorn',56),(728,'Crosswind',56),(729,'D-Max',56),(730,'Faster',56),(731,'Filly',56),(732,'Gemini',56),(733,'MU',56),(734,'Midi',56),(735,'Rodeo',56),(736,'Trooper',56),(737,'Vehi Cross',56),(738,'Wizard',56),(740,'Baodian',57),(742,'420',58),(743,'E-Type',58),(744,'S-Type',58),(745,'Sovereign',58),(746,'X-Type',58),(747,'XF',58),(748,'XJ',58),(749,'XJ220',58),(750,'XJR',58),(751,'XJS',58),(752,'XK',58),(753,'mark',58),(755,'Cherokee',59),(756,'Commander',59),(757,'Compass',59),(758,'Grand Cherokee',59),(759,'Liberty',59),(760,'Patriot',59),(761,'Wrangler',59),(763,'Haise',60),(765,'Avella',61),(766,'Besta',61),(767,'Carens',61),(768,'Carnival',61),(769,'Ceed',61),(770,'Cerato',61),(771,'Clarus',61),(772,'Cosmos',61),(773,'Elan',61),(774,'Enterprise',61),(775,'GrandBird',61),(776,'Joice',61),(777,'K',61),(778,'Magentis',61),(779,'Opirus',61),(780,'Optima',61),(781,'Picanto',61),(782,'Potentia',61),(783,'Pregio',61),(784,'Pride',61),(785,'Retona',61),(786,'Rio',61),(787,'Sedona',61),(788,'Sephia',61),(789,'Shuma',61),(790,'Sorento',61),(791,'Spectra',61),(792,'Sportage',61),(793,'Visto',61),(794,'X-Trek',61),(796,'Countach',62),(797,'Diablo',62),(798,'Espada',62),(799,'Gallardo',62),(800,'LM-002',62),(801,'Murcielago',62),(803,'Dedra',63),(804,'Delta',63),(805,'Fulvia',63),(806,'Kappa',63),(807,'Lybra',63),(808,'Musa',63),(809,'Phedra',63),(810,'Prisma',63),(811,'Thema',63),(812,'Thesis',63),(813,'Trevi',63),(814,'Ypsilon',63),(815,'Zeta',63),(817,'Defender',64),(818,'Discovery',64),(819,'Freelander',64),(820,'Range Rover',64),(821,'Range Rover Sport',64),(823,'SUV',65),(824,'X6',65),(826,'ES',66),(827,'GS',66),(828,'GX',66),(829,'IS',66),(830,'LS',66),(831,'LX',66),(832,'RX',66),(833,'SC',66),(835,'Breez',67),(837,'Aviator',68),(838,'Blackwood',68),(839,'Continental',68),(840,'LS',68),(841,'MKX',68),(842,'MKZ',68),(843,'Mark',68),(844,'Mark LT',68),(845,'Navigator',68),(846,'Town Car',68),(848,'Elise',69),(849,'Esprit',69),(850,'Europa',69),(851,'Exige',69),(852,'Seven',69),(854,'7',70),(855,'Express',70),(856,'MGF',70),(857,'Midget',70),(858,'TF',70),(859,'XPower SV',70),(860,'ZR',70),(861,'ZS',70),(862,'ZT',70),(864,'Clubman',71),(865,'Cooper',71),(866,'One',71),(868,'Armada',72),(869,'CJ',72),(870,'Commander',72),(871,'Marshal',72),(873,'Mantaray',73),(874,'Mantis',73),(876,'1000',74),(877,'800',74),(878,'Esteem',74),(879,'Gypsy',74),(880,'Omni',74),(881,'Zen',74),(883,'228',75),(884,'3200 GT',75),(885,'4300 GT Coupe',75),(886,'Coupe',75),(887,'Ghibli',75),(888,'Ghibli II',75),(889,'Gran Sport',75),(890,'Gran Turismo',75),(891,'M 128',75),(892,'Quattroporte',75),(893,'Spyder',75),(895,'57',76),(896,'57S',76),(897,'62',76),(898,'62S',76),(900,'121',77),(901,'2',77),(902,'3',77),(903,'323',77),(904,'5',77),(905,'6',77),(906,'626',77),(907,'929',77),(908,'Allegro',77),(909,'Atenza',77),(910,'Az-wagon',77),(911,'B-Series',77),(912,'BT-50',77),(913,'Bongo-Friendee',77),(914,'CX-7',77),(915,'CX-9',77),(916,'Capella',77),(917,'Carol',77),(918,'Demio',77),(919,'Efini MS-8',77),(920,'Familia',77),(921,'Fighter',77),(922,'Lantis',77),(923,'Levante',77),(924,'Luci',77),(925,'MPV',77),(926,'MPV 2',77),(927,'MX3',77),(928,'MX5',77),(929,'MX6',77),(930,'Millenia',77),(931,'Pick-Up',77),(932,'Premacy',77),(933,'Proceed',77),(934,'Protege',77),(935,'RX-4',77),(936,'RX-7',77),(937,'RX-8',77),(938,'Scrum',77),(939,'Sentia',77),(940,'Tribute',77),(941,'Verisa',77),(942,'Xedos 6',77),(943,'Xedos 9',77),(945,'F1',78),(947,'A-класс',79),(948,'B-класс',79),(949,'C-класс',79),(950,'CL-класс',79),(951,'CLC-класс',79),(952,'CLK-класс',79),(953,'CLS-класс',79),(954,'E-класс',79),(955,'G-класс',79),(956,'GL-класс',79),(957,'GLK-класс',79),(958,'M-класс',79),(959,'Pullmann',79),(960,'R-класс',79),(961,'S-класс',79),(962,'SL-класс',79),(963,'SLK-класс',79),(964,'SLR-класс',79),(965,'Sprinter',79),(966,'V-класс',79),(967,'Vaneo',79),(968,'Vario',79),(969,'Viano',79),(970,'Vito',79),(971,'W123',79),(972,'W124',79),(974,'Cougar',80),(975,'Grand Marquis',80),(976,'Mariner',80),(977,'Milan',80),(978,'Mountaineer',80),(979,'Mystique',80),(980,'Sable',80),(981,'Topaz',80),(982,'Tracer',80),(983,'Villager',80),(985,'Taxi',81),(987,'3000 GT',82),(988,'Airtrek',82),(989,'Aspire',82),(990,'Bravo',82),(991,'Carisma',82),(992,'Challenger',82),(993,'Chariot',82),(994,'Colt',82),(995,'Debonair',82),(996,'Delica',82),(997,'Diamante',82),(998,'Dingo',82),(999,'Dion',82),(1000,'EK',82),(1001,'Eclipse',82),(1002,'Emeraude',82),(1003,'Endeavor',82),(1004,'Eterna',82),(1005,'FTO',82),(1006,'Fuso Canter',82),(1007,'GTO',82),(1008,'Galant',82),(1009,'Grandis',82),(1010,'L200',82),(1011,'L300',82),(1012,'L400',82),(1013,'Lancer',82),(1014,'Lancer Cedia',82),(1015,'Lancer Evolution',82),(1016,'Legnum',82),(1017,'Libero',82),(1018,'Magna',82),(1019,'Minica',82),(1020,'Mirage',82),(1021,'Montero',82),(1022,'Montero Sport',82),(1023,'Outlander',82),(1024,'Outlander XL',82),(1025,'Pajero',82),(1026,'Pajero IO',82),(1027,'Pajero Junior',82),(1028,'Pajero Mini',82),(1029,'Pajero Pinin',82),(1030,'Pajero Sport',82),(1031,'Precis',82),(1032,'Proudia',82),(1033,'RVR',82),(1034,'Raider',82),(1035,'Sigma',82),(1036,'Space Gear',82),(1037,'Space Runner',82),(1038,'Space Star',82),(1039,'Space Wagon',82),(1040,'Toppo',82),(1041,'Town Box',82),(1042,'Town Box Wide',82),(1043,'Triton',82),(1044,'i',82),(1046,'Galue',83),(1047,'Le-Seyde',83),(1049,'4/4',84),(1050,'Aero 8',84),(1051,'Plus 4',84),(1052,'Plus 8',84),(1054,'100NX',85),(1055,'180SX',85),(1056,'200SX',85),(1057,'240SX',85),(1058,'280ZX',85),(1059,'300ZX',85),(1060,'350Z',85),(1061,'AD',85),(1062,'Almera',85),(1063,'Almera Classic',85),(1064,'Almera Tino',85),(1065,'Altima',85),(1066,'Armada',85),(1067,'Avenir',85),(1068,'Bassara',85),(1069,'Bluebird',85),(1070,'Bluebird Sylphy',85),(1071,'Caravan',85),(1072,'Cedric',85),(1073,'Cefiro',85),(1074,'Cherry',85),(1075,'Cima',85),(1076,'Civilian',85),(1077,'Crew',85),(1078,'Cube',85),(1079,'Datsun',85),(1080,'Elgrand',85),(1081,'Expert',85),(1082,'Fairlady',85),(1083,'Frontier',85),(1084,'Gloria',85),(1085,'Largo',85),(1086,'Laurel',85),(1087,'Leopard',85),(1088,'Liberty',85),(1089,'Livina Geniss',85),(1090,'Lucino',85),(1091,'March',85),(1092,'Maxima',85),(1093,'Maxima QX',85),(1094,'Micra',85),(1095,'Mistral',85),(1096,'Moco',85),(1097,'Murano',85),(1098,'NP300',85),(1099,'Navara',85),(1100,'Note',85),(1101,'Otti',85),(1102,'Pathfinder',85),(1103,'Pathfinder Aramada',85),(1104,'Patrol',85),(1105,'Pickup',85),(1106,'Prairie',85),(1107,'Presage',85),(1108,'Presea',85),(1109,'President',85),(1110,'Primastar',85),(1111,'Primera',85),(1112,'Pulsar',85),(1113,'Qashqai',85),(1114,'Quest',85),(1115,'R\'nessa',85),(1116,'Rasheen',85),(1117,'Rogue',85),(1118,'Safari',85),(1119,'Sentra',85),(1120,'Serena',85),(1121,'Silvia',85),(1122,'Skyline',85),(1123,'Stagea',85),(1124,'Stanza',85),(1125,'Sunny',85),(1126,'Teana',85),(1127,'Terrano',85),(1128,'Tiida',85),(1129,'Tiida latio',85),(1130,'Tino',85),(1131,'Titan',85),(1132,'Vanette',85),(1133,'Versa',85),(1134,'Wingroad',85),(1135,'X-Trail',85),(1136,'Xterra',85),(1138,'Achieva',86),(1139,'Alero',86),(1140,'Aurora',86),(1141,'Bravada',86),(1142,'Cutlass',86),(1143,'Cutlass Calais',86),(1144,'Cutlass Ciera',86),(1145,'Cutlass Cruiser',86),(1146,'Cutlass Supreme',86),(1147,'Delta',86),(1148,'Eighty Eight',86),(1149,'Intrigue',86),(1150,'Nineghty eight',86),(1151,'Omega',86),(1152,'Silhouette',86),(1154,'Admiral',87),(1155,'Agila',87),(1156,'Antara',87),(1157,'Arena',87),(1158,'Ascona',87),(1159,'Astra',87),(1160,'Calibra',87),(1161,'Campo',87),(1162,'Combo',87),(1163,'Corsa',87),(1164,'Frontera',87),(1165,'GT',87),(1166,'Insignia',87),(1167,'Kadett',87),(1168,'Manta',87),(1169,'Meriva',87),(1170,'Monterey',87),(1171,'Monza',87),(1172,'Movano',87),(1173,'Olimpia',87),(1174,'Omega',87),(1175,'Rekord',87),(1176,'Senator',87),(1177,'Signum',87),(1178,'Sintra',87),(1179,'Speedster',87),(1180,'Tigra',87),(1181,'Vectra',87),(1182,'Vita',87),(1183,'Vivaro',87),(1184,'Zafira',87),(1186,'Pinzgauer',88),(1188,'Zonda',89),(1190,'Esperante',90),(1192,'1007',91),(1193,'106',91),(1194,'107',91),(1195,'204',91),(1196,'205',91),(1197,'206',91),(1198,'207',91),(1199,'305',91),(1200,'306',91),(1201,'307',91),(1202,'308',91),(1203,'4007',91),(1204,'405',91),(1205,'406',91),(1206,'407',91),(1207,'504',91),(1208,'505',91),(1209,'604',91),(1210,'605',91),(1211,'607',91),(1212,'608',91),(1213,'806',91),(1214,'807',91),(1215,'Boxer',91),(1216,'Expert',91),(1217,'Partner',91),(1218,'',91),(1219,'Acclaim',92),(1220,'Breeze',92),(1221,'Laser',92),(1222,'Neon',92),(1223,'Prowler',92),(1224,'Sundance',92),(1225,'Voyager',92),(1227,'Aztec',93),(1228,'Bonneville',93),(1229,'Firebird',93),(1230,'G5',93),(1231,'G6',93),(1232,'G7',93),(1233,'G8',93),(1234,'GTO',93),(1235,'Grand AM',93),(1236,'Grand Prix',93),(1237,'Lemans',93),(1238,'Montana',93),(1239,'Phoenix',93),(1240,'Solstice',93),(1241,'Sunbird',93),(1242,'Sunfire',93),(1243,'Torrent',93),(1244,'Trans AM',93),(1245,'Trans Sport',93),(1246,'Vibe',93),(1247,'Wave',93),(1249,'911',94),(1250,'924',94),(1251,'928',94),(1252,'944',94),(1253,'968',94),(1254,'996',94),(1255,'997',94),(1256,'Boxster',94),(1257,'Carrera GT',94),(1258,'Cayenne',94),(1259,'Cayman',94),(1261,'315',95),(1262,'415',95),(1263,'Persona',95),(1264,'Putra',95),(1265,'Satria',95),(1267,'10',96),(1268,'11',96),(1269,'14',96),(1270,'18',96),(1271,'19',96),(1272,'21',96),(1273,'25',96),(1274,'30',96),(1275,'4',96),(1276,'5',96),(1277,'8',96),(1278,'9',96),(1279,'Avantime',96),(1280,'Clio',96),(1281,'Espace',96),(1282,'Express',96),(1283,'Fuego',96),(1284,'Grand Espace',96),(1285,'Grand Scenic',96),(1286,'Kangoo',96),(1287,'Koleos',96),(1288,'Laguna',96),(1289,'Logan',96),(1290,'Magnum',96),(1291,'Mascott',96),(1292,'Master',96),(1293,'Megane',96),(1294,'Midlum',96),(1295,'Modus',96),(1296,'Nevada',96),(1297,'Premium',96),(1298,'Rapid',96),(1299,'Safrane',96),(1300,'Scenic',96),(1301,'Sport Spyder',96),(1302,'Symbol',96),(1303,'Trafic',96),(1304,'Twingo',96),(1305,'Vel Satis',96),(1307,'750',97),(1309,'Corniche',98),(1310,'Park Ward',98),(1311,'Phantom',98),(1312,'Silver Seraph',98),(1313,'Silver Spur',98),(1315,'100',99),(1316,'200',99),(1317,'213',99),(1318,'25',99),(1319,'2600',99),(1320,'400',99),(1321,'45',99),(1322,'600',99),(1323,'75',99),(1324,'800',99),(1325,'City',99),(1326,'MGF',99),(1327,'Maestro',99),(1328,'Metro',99),(1329,'Mini',99),(1330,'Streetwise',99),(1332,'Alhambra',100),(1333,'Altea',100),(1334,'Arosa',100),(1335,'Cordoba',100),(1336,'Exeo',100),(1337,'Freetrack',100),(1338,'Ibiza',100),(1339,'Inca',100),(1340,'Leon',100),(1341,'Marbella',100),(1342,'Toledo',100),(1343,'XL',100),(1345,'9-2',101),(1346,'9-3',101),(1347,'9-5',101),(1348,'9-7X',101),(1349,'900',101),(1350,'900 II',101),(1351,'9000',101),(1353,'S7',102),(1355,'SM3',103),(1356,'SM5',103),(1357,'SM7',103),(1359,'Astra',104),(1360,'Aura',104),(1361,'ION',104),(1362,'Ion Red Line',104),(1363,'LS',104),(1364,'LW',104),(1365,'Outlook',104),(1366,'SC1',104),(1367,'SC2',104),(1368,'SL',104),(1369,'SL2',104),(1370,'SW',104),(1371,'Sky',104),(1372,'VUE',104),(1374,'tC',105),(1375,'xA',105),(1376,'xB',105),(1377,'xD',105),(1380,'SCEO',107),(1382,'105, 120',108),(1383,'Fabia',108),(1384,'Favorit',108),(1385,'Felicia',108),(1386,'Forman',108),(1387,'Octavia',108),(1388,'Octavia Scout',108),(1389,'Octavia Tour',108),(1390,'Praktik',108),(1391,'Rapid',108),(1392,'Roomster',108),(1393,'Superb',108),(1395,'City',109),(1396,'Forfour',109),(1397,'Fortwo',109),(1398,'Roadster',109),(1400,'C8',110),(1402,'Actyon',111),(1403,'Actyon Sport',111),(1404,'Chairman',111),(1405,'Istana',111),(1406,'Korando',111),(1407,'Korando Family',111),(1408,'Kyron',111),(1409,'Musso',111),(1410,'Musso Sports',111),(1411,'Rexton',111),(1412,'Rodius',111),(1414,'Baja',112),(1415,'Dias Wagon',112),(1416,'E10',112),(1417,'E12',112),(1418,'Forester',112),(1419,'Impreza',112),(1420,'Impreza WRX STI',112),(1421,'Justy',112),(1422,'Legacy',112),(1423,'Leone',112),(1424,'Libero',112),(1425,'Outback',112),(1426,'Pleo',112),(1427,'R1',112),(1428,'R2',112),(1429,'SVX',112),(1430,'Sambar',112),(1431,'Stella',112),(1432,'Traviq',112),(1433,'Tribeca',112),(1434,'Vivio',112),(1436,'Aerio',113),(1437,'Alto',113),(1438,'Baleno',113),(1439,'Cappuccino',113),(1440,'Cultus',113),(1441,'Equator',113),(1442,'Escudo',113),(1443,'Esteem',113),(1444,'Every',113),(1445,'Forenza',113),(1446,'Geo',113),(1447,'Grand Vitara',113),(1448,'Ignis',113),(1449,'Jimny',113),(1450,'Kei',113),(1451,'Lapin',113),(1452,'Liana',113),(1453,'Reno',113),(1454,'SX4',113),(1455,'Samurai',113),(1456,'Sidekick',113),(1457,'Solio',113),(1458,'Splash',113),(1459,'Swift',113),(1460,'Twin',113),(1461,'Verona',113),(1462,'Vitara',113),(1463,'Wagon R+',113),(1464,'X-90',113),(1465,'XL-7',113),(1467,'Cerbera',114),(1468,'Chimaera',114),(1469,'Griffith',114),(1470,'T350',114),(1471,'Tamora',114),(1472,'Tuscan',114),(1474,'1307-1510',115),(1475,'Horizon',115),(1476,'Tagora',115),(1478,'Indica',116),(1480,'613',117),(1481,'700',117),(1482,'815',117),(1484,'Century',118),(1486,'Admiral',119),(1487,'Banner',119),(1489,'Dogan',120),(1490,'Kartal',120),(1491,'Sahin',120),(1492,'Serce',120),(1493,'Tempra',120),(1495,'4 Runner',121),(1496,'Allex',121),(1497,'Allion',121),(1498,'Alphard',121),(1499,'Altezza',121),(1500,'Aristo',121),(1501,'Aurion',121),(1502,'Auris',121),(1503,'Avalon',121),(1504,'Avensis',121),(1505,'Avensis Verso',121),(1506,'Aygo',121),(1507,'Bandeirante',121),(1508,'Brevis',121),(1509,'Caldina',121),(1510,'Cami',121),(1511,'Camry',121),(1512,'Camry Solara',121),(1513,'Carina',121),(1514,'Carina E',121),(1515,'Carina ED',121),(1516,'Cavalier',121),(1517,'Celica',121),(1518,'Celsior',121),(1519,'Century',121),(1520,'Chaser',121),(1521,'Coaster',121),(1522,'Corolla',121),(1523,'Corolla Ceres',121),(1524,'Corolla Fielder',121),(1525,'Corolla Levin',121),(1526,'Corolla Runx',121),(1527,'Corolla Spacio',121),(1528,'Corolla Verso',121),(1529,'Corona',121),(1530,'Corona Premio',121),(1531,'Corsa',121),(1532,'Cressida',121),(1533,'Cresta',121),(1534,'Crown',121),(1535,'Crown Athlete',121),(1536,'Crown Majesta',121),(1537,'Crown Royal',121),(1538,'Curren',121),(1539,'Cynos',121),(1540,'Duet',121),(1541,'Echo',121),(1542,'Estima',121),(1543,'Estima Lucida',121),(1544,'FJ Cruiser',121),(1545,'Fortuner',121),(1546,'Funcargo',121),(1547,'Gaia',121),(1548,'Grand hiace',121),(1549,'Granvia',121),(1550,'Harrier',121),(1551,'Hiace',121),(1552,'Highlander',121),(1553,'Hilux',121),(1554,'Hilux Surf',121),(1555,'Ipsum',121),(1556,'Isis',121),(1557,'Ist',121),(1558,'Kluger',121),(1559,'Land Cruiser',121),(1560,'Land Cruiser Prado',121),(1561,'Lite Ace',121),(1562,'MR2',121),(1563,'MRS',121),(1564,'Mark II',121),(1565,'Mark X',121),(1566,'Matrix',121),(1567,'Nadia',121),(1568,'Noah',121),(1569,'Opa',121),(1570,'Origin',121),(1571,'Paseo',121),(1572,'Passo',121),(1573,'Picnic',121),(1574,'Platz',121),(1575,'Porte',121),(1576,'Premio',121),(1577,'Previa',121),(1578,'Prius',121),(1579,'Probox',121),(1580,'Progres',121),(1581,'Pronard',121),(1582,'Ractis',121),(1583,'Raum',121),(1584,'Rav 4',121),(1585,'Regius',121),(1586,'Regius ACE',121),(1587,'Rush',121),(1588,'Scepter',121),(1589,'Scion',121),(1590,'Sequoia',121),(1591,'Sera',121),(1592,'Sienna',121),(1593,'Sienta',121),(1594,'Soarer',121),(1595,'Solara',121),(1596,'Sparky',121),(1597,'Sprinter',121),(1598,'Sprinter Marino',121),(1599,'Starlet',121),(1600,'Succeed',121),(1601,'Supra',121),(1602,'Tacoma',121),(1603,'Tercel',121),(1604,'Town Ace',121),(1605,'Tundra',121),(1606,'Verossa',121),(1607,'Vios',121),(1608,'Vista',121),(1609,'Vitz',121),(1610,'Voltz',121),(1611,'Voxy',121),(1612,'Will Cypha',121),(1613,'Will VS',121),(1614,'Windom',121),(1615,'Wish',121),(1616,'Yaris',121),(1617,'Yaris Verso',121),(1618,'bB',121),(1619,'',121),(1620,'600',122),(1621,'601',122),(1623,'300',123),(1624,'400',123),(1625,'Fetish',123),(1627,'Beetle',124),(1628,'Bora',124),(1629,'Caddy',124),(1630,'California',124),(1631,'Camper',124),(1632,'Caravelle',124),(1633,'Corrado',124),(1634,'Country Buggy',124),(1635,'Crafter',124),(1636,'EOS',124),(1637,'EuroVan',124),(1638,'Fox',124),(1639,'Gol',124),(1640,'Golf',124),(1641,'Golf Plus',124),(1642,'Iltis',124),(1643,'Jetta',124),(1644,'Kaefer',124),(1645,'LT',124),(1646,'Lupo',124),(1647,'Multivan',124),(1648,'NEW Beetle',124),(1649,'Parati',124),(1650,'Passat',124),(1651,'Passat CC',124),(1652,'Phaeton',124),(1653,'Pointer',124),(1654,'Polo',124),(1655,'Quantum',124),(1656,'Santana',124),(1657,'Scirocco',124),(1658,'Sharan',124),(1659,'Taro',124),(1660,'Tiguan',124),(1661,'Touareg',124),(1662,'Touran',124),(1663,'Transporter',124),(1664,'Vento',124),(1666,'140',125),(1667,'164',125),(1668,'240',125),(1669,'260',125),(1670,'340',125),(1671,'360',125),(1672,'440',125),(1673,'460',125),(1674,'480',125),(1675,'740',125),(1676,'744',125),(1677,'745',125),(1678,'760',125),(1679,'780',125),(1680,'850',125),(1681,'940',125),(1682,'944',125),(1683,'945',125),(1684,'960',125),(1685,'C30',125),(1686,'C70',125),(1687,'S40',125),(1688,'S60',125),(1689,'S70',125),(1690,'S80',125),(1691,'S90',125),(1692,'V40',125),(1693,'V50',125),(1694,'V70',125),(1695,'V90',125),(1696,'XC60',125),(1697,'XC70',125),(1698,'XC90',125),(1700,'Estina',126),(1702,'353',127),(1704,'Roadster',128),(1706,'Pickup X3',129),(1707,'SR-V X3',129),(1708,'SUV X3',129),(1710,'Dragon',130),(1711,'Fine',130),(1712,'Flying',130),(1713,'Liebao',130),(1715,'Grand Tiger',131),(1716,'landmark',131),(1718,'1111',132),(1719,'1922',132),(1720,'2101',132),(1721,'2102',132),(1722,'2103',132),(1723,'2104',132),(1724,'2105',132),(1725,'2106',132),(1726,'2107',132),(1727,'2108',132),(1728,'2109',132),(1729,'21099',132),(1730,'2110',132),(1731,'2111',132),(1732,'2112',132),(1733,'2113',132),(1734,'2114',132),(1735,'2115',132),(1736,'2120',132),(1737,'2121',132),(1738,'2123',132),(1739,'2129',132),(1740,'2131',132),(1741,'2328',132),(1742,'2329',132),(1743,'2345',132),(1744,'2346',132),(1745,'2347',132),(1746,'2364',132),(1747,'2723',132),(1748,'Kalina',132),(1749,'Priora',132),(1751,'Автокам-2160',133),(1753,'12',134),(1754,'13',134),(1755,'14',134),(1756,'17310',134),(1757,'21',134),(1758,'22',134),(1759,'2217',134),(1760,'22171',134),(1761,'2308',134),(1762,'2310',134),(1763,'2330',134),(1764,'24',134),(1765,'24-10',134),(1766,'2402',134),(1767,'2705',134),(1768,'2752',134),(1769,'3102',134),(1770,'3103',134),(1771,'3104',134),(1772,'3105',134),(1773,'3106',134),(1774,'3110',134),(1775,'31105',134),(1776,'3111',134),(1777,'3120',134),(1778,'3129',134),(1779,'3221',134),(1780,'3234',134),(1781,'3302',134),(1782,'3307',134),(1783,'3308',134),(1784,'3309',134),(1785,'3310',134),(1786,'52/53',134),(1787,'66',134),(1788,'67',134),(1789,'69',134),(1790,'M-1',134),(1791,'M-20',134),(1792,'Volga Siber',134),(1794,'762',135),(1796,'1111',136),(1798,'1111',137),(1799,'43',137),(1800,'53',137),(1801,'54',137),(1802,'55',137),(1803,'65',137),(1805,'965',138),(1806,'966',138),(1807,'968',138),(1808,'968М',138),(1809,'Sens',138),(1810,'Таврия',138),(1812,'114',139),(1813,'115',139),(1814,'117',139),(1815,'130',139),(1816,'4104',139),(1817,'41047',139),(1818,'4741',139),(1819,'5301',139),(1821,'2117',140),(1822,'2125',140),(1823,'2126 / Ода',140),(1824,'2715',140),(1825,'2717',140),(1826,'412',140),(1828,'1302',141),(1829,'967',141),(1830,'967М',141),(1831,'969',141),(1832,'969А',141),(1833,'969Б',141),(1834,'969М',141),(1836,'2125',142),(1837,'2135',142),(1838,'2137',142),(1839,'2138',142),(1840,'2140',142),(1841,'2141',142),(1842,'2901',142),(1843,'400',142),(1844,'401',142),(1845,'402',142),(1846,'403',142),(1847,'407',142),(1848,'408',142),(1849,'410',142),(1850,'412',142),(1851,'426',142),(1852,'427',142),(1853,'Князь Владимир',142),(1854,'Святогор',142),(1855,'Юрий Долгорукий',142),(1857,'2206',143),(1858,'2362',143),(1859,'3150',143),(1860,'3151',143),(1861,'31512',143),(1862,'31514',143),(1863,'31519',143),(1864,'315195 / Hunter',143),(1865,'3153',143),(1866,'3159',143),(1867,'3160',143),(1868,'3162',143),(1869,'3163 / Patriot',143),(1870,'3165',143),(1871,'3303',143),(1872,'3309',143),(1873,'3741',143),(1874,'3909',143),(1875,'3962',143),(1876,'459',143),(1877,'469',143);
/*!40000 ALTER TABLE `car_model` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `authToken` varchar(255) DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone_number_UNIQUE` (`phone_number`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (3,'Герман','79222989966','test@example.com','b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326af5a2ea6d103fd07c95385ffab0cacbc86','qMOOzhdguuWVWhkyWPXfVkKZawwgZNXD','2019-05-17 15:14:49','2019-05-17 15:14:49');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispatcher`
--

DROP TABLE IF EXISTS `dispatcher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dispatcher` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(128) NOT NULL,
  `lasr_name` varchar(128) NOT NULL,
  `patronymic` varchar(128) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `authToken` varchar(255) DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone_number_UNIQUE` (`phone_number`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispatcher`
--

LOCK TABLES `dispatcher` WRITE;
/*!40000 ALTER TABLE `dispatcher` DISABLE KEYS */;
/*!40000 ALTER TABLE `dispatcher` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver`
--

DROP TABLE IF EXISTS `driver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `driver` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(128) NOT NULL,
  `last_name` varchar(128) NOT NULL,
  `patronymic` varchar(128) NOT NULL,
  `birth_date` date NOT NULL,
  `phone_number` varchar(30) NOT NULL,
  `driving_license_number` varchar(128) NOT NULL,
  `expiry_date` date NOT NULL,
  `working` tinyint(1) DEFAULT '0',
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `authToken` varchar(255) DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone_number_UNIQUE` (`phone_number`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver`
--

LOCK TABLES `driver` WRITE;
/*!40000 ALTER TABLE `driver` DISABLE KEYS */;
/*!40000 ALTER TABLE `driver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_type`
--

DROP TABLE IF EXISTS `payment_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_type`
--

LOCK TABLES `payment_type` WRITE;
/*!40000 ALTER TABLE `payment_type` DISABLE KEYS */;
INSERT INTO `payment_type` VALUES (1,'Cash');
/*!40000 ALTER TABLE `payment_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shift`
--

DROP TABLE IF EXISTS `shift`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shift` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) NOT NULL,
  `shift_start_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `shift_end_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_shift_driver1_idx` (`driver_id`),
  CONSTRAINT `fk_shift_driver1` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shift`
--

LOCK TABLES `shift` WRITE;
/*!40000 ALTER TABLE `shift` DISABLE KEYS */;
/*!40000 ALTER TABLE `shift` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'taxi'
--
/*!50003 DROP PROCEDURE IF EXISTS `cabRideStatusCheck` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`anonlatte`@`%` PROCEDURE `cabRideStatusCheck`(IN cab_ride_id int)
BEGIN
    DECLARE shift_id_check int DEFAULT NULL;
    set shift_id_check = (SELECT @shift_id_check:=shift_id FROM cab_ride WHERE cab_ride.id = cab_ride_id);
    IF shift_id_check IS NOT NULL THEN
        SELECT first_name, last_name, phone_number, license_plate, color, model_name, brand_name, ride_status FROM cab_ride, driver, shift, cab, car_model, car_brand, cab_ride_status WHERE cab_ride.id=cab_ride_id AND cab.driver_id = driver.id AND cab_ride.shift_id = shift.id AND shift.driver_id = driver.id AND cab.car_model_id = car_model.id AND car_model.car_brand_id = car_brand.id AND cab.active = 1;
    ELSE
        SELECT '' as first_name, '' as last_name, '' as phone_number, '' as license_plate, '' as color, '' as model_name, '' as brand_name, 0 as ride_status FROM cab_ride WHERE cab_ride.id=cab_ride_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-05-17 20:28:38
