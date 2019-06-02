CREATE DATABASE  IF NOT EXISTS `taxi` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
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
  `color_id` int(11) NOT NULL,
  `license_plate` varchar(45) NOT NULL,
  `car_model_id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_auto_car_model1_idx` (`car_model_id`),
  KEY `fk_cab_driver1_idx` (`driver_id`),
  KEY `fk_cab_color1_idx` (`color_id`),
  CONSTRAINT `fk_auto_car_model1` FOREIGN KEY (`car_model_id`) REFERENCES `car_model` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cab_color1` FOREIGN KEY (`color_id`) REFERENCES `color` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_cab_driver1` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
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
  CONSTRAINT `fk_cab_ride_customer1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_cab_ride_payment_type1` FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_cab_ride_shift1` FOREIGN KEY (`shift_id`) REFERENCES `shift` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
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
  `status_details` varchar(255) DEFAULT NULL,
  `dispatcher_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cab_ride_status_cab_ride1_idx` (`cab_ride_id`),
  KEY `fk_cab_ride_status_dispatcher1_idx` (`dispatcher_id`),
  KEY `fk_cab_ride_status_shift1_idx` (`shift_id`),
  CONSTRAINT `fk_cab_ride_status_cab_ride1` FOREIGN KEY (`cab_ride_id`) REFERENCES `cab_ride` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cab_ride_status_dispatcher1` FOREIGN KEY (`dispatcher_id`) REFERENCES `dispatcher` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_cab_ride_status_shift1` FOREIGN KEY (`shift_id`) REFERENCES `shift` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
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
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8mb4;
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
  CONSTRAINT `fk_car_model_car_brand` FOREIGN KEY (`car_brand_id`) REFERENCES `car_brand` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1740 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_model`
--

LOCK TABLES `car_model` WRITE;
/*!40000 ALTER TABLE `car_model` DISABLE KEYS */;
INSERT INTO `car_model` VALUES (1,'MC 1',1),(2,'Ace',2),(3,'Aceca',2),(4,'Cobra',2),(5,'Mamba',2),(6,'CL',3),(7,'CSX',3),(8,'EL',3),(9,'Integra',3),(10,'Legend',3),(11,'MDX',3),(12,'NSX',3),(13,'RDX',3),(14,'RL',3),(15,'RSX',3),(16,'SLX',3),(17,'TL',3),(18,'TSX',3),(19,'Pickup',4),(20,'145',5),(21,'146',5),(22,'147',5),(23,'155',5),(24,'156',5),(25,'159',5),(26,'164',5),(27,'166',5),(28,'33',5),(29,'75',5),(30,'8C Competizione',5),(31,'90',5),(32,'Alfasud',5),(33,'Alfetta',5),(34,'Brera',5),(35,'GT',5),(36,'GTV',5),(37,'Giulietta',5),(38,'MiTo',5),(39,'Spider',5),(40,'B10',6),(41,'B12',6),(42,'B3',6),(43,'B7',6),(44,'B8',6),(45,'D10',6),(46,'Roadster S',6),(47,'10',7),(48,'24',7),(49,'243',7),(50,'244',7),(51,'245',7),(52,'246',7),(53,'Spartana',7),(54,'Hi-Topic',8),(55,'Retona',8),(56,'Rocsta',8),(57,'DB7',9),(58,'DB9',9),(59,'DBS',9),(60,'V12 Vanquish',9),(61,'V8 Vantage',9),(62,'100',10),(63,'200',10),(64,'5000',10),(65,'80',10),(66,'90',10),(67,'A2',10),(68,'A3',10),(69,'A4',10),(70,'A5',10),(71,'A6',10),(72,'A6 allroad quattro',10),(73,'A8',10),(74,'Cabriolet',10),(75,'Q5',10),(76,'Q7',10),(77,'R8',10),(78,'RS4',10),(79,'RS6',10),(80,'S2',10),(81,'S3',10),(82,'S4',10),(83,'S5',10),(84,'S6',10),(85,'S8',10),(86,'TT',10),(87,'V8',10),(88,'1 series',11),(89,'3 series',11),(90,'5 series',11),(91,'6 series',11),(92,'7 series',11),(93,'8 series',11),(94,'M3',11),(95,'M5',11),(96,'M6',11),(97,'X3',11),(98,'X5',11),(99,'X6',11),(100,'Z1',11),(101,'Z3',11),(102,'Z4',11),(103,'Z4 M',11),(104,'Z8',11),(105,'F0',12),(106,'F3',12),(107,'F6',12),(108,'F6',12),(109,'Flyer',12),(110,'Arnage',13),(111,'Azure',13),(112,'Brooklands',13),(113,'Continental',13),(114,'Continental Flying Spur',13),(115,'Continental GT',13),(116,'Mulsanne',13),(117,'Turbo RT',13),(118,'M1 (Zhonghua)',14),(119,'M2 (JunJie)',14),(120,'',14),(121,'EB 110',15),(122,'EB 112',15),(123,'Veyron 16.4',15),(124,'Century',16),(125,'Electra',16),(126,'Enclave',16),(127,'GL8',16),(128,'La Crosse',16),(129,'Le Sabre',16),(130,'Lucerne',16),(131,'Park Avenue',16),(132,'Rainer',16),(133,'Regal',16),(134,'RendezVous',16),(135,'Riviera',16),(136,'Roadmaster',16),(137,'Skylark',16),(138,'Terraza',16),(139,'BLS',17),(140,'CTS',17),(141,'Catera',17),(142,'DTS',17),(143,'De Ville',17),(144,'Eldorado',17),(145,'Escalade',17),(146,'Fleetwood',17),(147,'SRX',17),(148,'STS',17),(149,'Seville',17),(150,'XLR',17),(151,'C21',18),(152,'Super Seven',18),(153,'Flying',19),(154,'SUV',19),(155,'Amulet',20),(156,'B11 (Oriental Son)',20),(157,'B14',20),(158,'Eastar',20),(159,'Fora',20),(160,'Kimo',20),(161,'QQ',20),(162,'QQ 6',20),(163,'Swift',20),(164,'Tiggo',20),(165,'Windcloud',20),(166,'Alero',21),(167,'Astro',21),(168,'Avalanche',21),(169,'Aveo',21),(170,'Beretta',21),(171,'Blazer',21),(172,'Camaro',21),(173,'Caprice',21),(174,'Captiva',21),(175,'Cavalier',21),(176,'Celta',21),(177,'Chevi C2',21),(178,'Classic',21),(179,'Cobalt',21),(180,'Colorado',21),(181,'Conversion Van',21),(182,'Corsa',21),(183,'Corsica',21),(184,'Corvette',21),(185,'Cruze',21),(186,'Epica',21),(187,'Equinox',21),(188,'Evanda',21),(189,'Express',21),(190,'Geo Storm',21),(191,'Geo Tracker',21),(192,'HHR',21),(193,'Impala',21),(194,'Ipanema',21),(195,'K3500',21),(196,'Lacetti',21),(197,'Lanos',21),(198,'Lumina',21),(199,'Malibu',21),(200,'Meriva',21),(201,'Metro',21),(202,'Montana',21),(203,'Monte Carlo',21),(204,'Monza',21),(205,'Niva',21),(206,'Nova',21),(207,'Omega',21),(208,'Prizm',21),(209,'Prizma',21),(210,'Rezzo',21),(211,'S-10',21),(212,'SSR',21),(213,'Savana',21),(214,'Silver',21),(215,'Silverado',21),(216,'Spark',21),(217,'Starcraft',21),(218,'Suburban',21),(219,'Tahoe',21),(220,'Tracker',21),(221,'TrailBlazer',21),(222,'TransSport',21),(223,'Uplander',21),(224,'Van',21),(225,'Vectra',21),(226,'Venture',21),(227,'Viva',21),(228,'Zafira',21),(229,'300C',22),(230,'300M',22),(231,'Aspen',22),(232,'Cirrus',22),(233,'Concorde',22),(234,'Crossfire',22),(235,'Daytona',22),(236,'Grand Voyager',22),(237,'Intrepid',22),(238,'LHS',22),(239,'Le Baron',22),(240,'Neon',22),(241,'New Yorker',22),(242,'PT Cruiser',22),(243,'Pacifica',22),(244,'Prowler',22),(245,'Saratoga',22),(246,'Sebring',22),(247,'Stratus',22),(248,'Town&amp;Country',22),(249,'Viper',22),(250,'Vision',22),(251,'Voyager',22),(252,'AX',23),(253,'BX',23),(254,'Berlingo',23),(255,'C-Crosser',23),(256,'C-Triomphe',23),(257,'C1',23),(258,'C15',23),(259,'C2',23),(260,'C3',23),(261,'C3 Pluriel',23),(262,'C4',23),(263,'C4 Picasso',23),(264,'C5',23),(265,'C6',23),(266,'C8',23),(267,'CX',23),(268,'Evasion',23),(269,'Grand C4 Picasso',23),(270,'Jumper',23),(271,'Jumpy',23),(272,'Saxo',23),(273,'Visa',23),(274,'XM',23),(275,'Xantia',23),(276,'Xsara',23),(277,'Xsara Picasso',23),(278,'ZX',23),(279,'City Leading',24),(280,'Shuttle',24),(281,'Smoothing',24),(282,'1304',25),(283,'1310',25),(284,'1325',25),(285,'1410',25),(286,'Logan',25),(287,'Nova',25),(288,'Arcadia',26),(289,'Brougham',26),(290,'Chairman',26),(291,'Damas',26),(292,'Espero',26),(293,'Evanda',26),(294,'GX2',26),(295,'Gentra',26),(296,'Istana',26),(297,'Kalos',26),(298,'Korando',26),(299,'Labo',26),(300,'Lacetti',26),(301,'Lanos',26),(302,'Leganza',26),(303,'Lemans',26),(304,'Magnus',26),(305,'Matiz',26),(306,'Musso',26),(307,'Nexia',26),(308,'Nubira',26),(309,'Polonez',26),(310,'Prince',26),(311,'Racer',26),(312,'Rezzo',26),(313,'Statesman',26),(314,'Super Salon',26),(315,'Tacuma',26),(316,'Tico',26),(317,'Tosca',26),(318,'Windstorm',26),(319,'Altis',27),(320,'Applause',27),(321,'Atrai',27),(322,'Be-go',27),(323,'Boon',27),(324,'Charade',27),(325,'Coo',27),(326,'Copen',27),(327,'Cuore',27),(328,'Esse',27),(329,'Extol',27),(330,'Feroza',27),(331,'Gran Move',27),(332,'Hi Jet',27),(333,'Materia',27),(334,'Max',27),(335,'Mira',27),(336,'Mobe',27),(337,'Move',27),(338,'Naked',27),(339,'Opti',27),(340,'Pizar',27),(341,'Rocky',27),(342,'Sirion',27),(343,'Sonica',27),(344,'Storia',27),(345,'Tanto',27),(346,'Taruna',27),(347,'Terios',27),(348,'Trevis',27),(349,'Xenia',27),(350,'YRV',27),(351,'Zebra',27),(352,'Limousine',28),(353,'XJ',28),(354,'Guara',29),(355,'Pantera',29),(356,'Antelope',30),(357,'Aurora',30),(358,'Cowboy',30),(359,'DADI Shuttle',30),(360,'Land Crown',30),(361,'Plutus',30),(362,'Saladin',30),(363,'Shuttle',30),(364,'600',31),(365,'Avenger',31),(366,'Caliber',31),(367,'Caravan',31),(368,'Charger',31),(369,'Dakota',31),(370,'Daytona',31),(371,'Durango',31),(372,'Dynasty',31),(373,'Grand Caravan',31),(374,'Intrepid',31),(375,'Journey',31),(376,'Magnum',31),(377,'Monaco',31),(378,'Neon',31),(379,'Nitro',31),(380,'Omni',31),(381,'Ram',31),(382,'Shadow',31),(383,'Spirit',31),(384,'Stealth',31),(385,'Stratus',31),(386,'Viper',31),(387,'Assol',32),(388,'Kondor',32),(389,'Orion',32),(390,'D8',33),(391,'Summit',34),(392,'Talon',34),(393,'Vision',34),(394,'Admiral',35),(395,'Besturn',35),(396,'HQ3',35),(397,'Jinn',35),(398,'Vita',35),(399,'Polonez',36),(400,'Tarpan Honker',37),(401,'208',38),(402,'308',38),(403,'328',38),(404,'348',38),(405,'355 Berlinetta',38),(406,'355F1',38),(407,'360 Modena',38),(408,'360 Spider',38),(409,'365',38),(410,'412',38),(411,'456 GT',38),(412,'512 M',38),(413,'550 Barchetta',38),(414,'550 Maranello',38),(415,'575 Maranello',38),(416,'599 GTB',38),(417,'612 Scaglietti',38),(418,'Enzo',38),(419,'F355 GTS',38),(420,'F355 Spider',38),(421,'F40',38),(422,'F430',38),(423,'F50',38),(424,'GTB',38),(425,'Mondial 3.2',38),(426,'Mondial 8',38),(427,'Mondial T',38),(428,'Testarossa',38),(429,'124',39),(430,'126',39),(431,'127',39),(432,'131',39),(433,'242',39),(434,'500',39),(435,'600',39),(436,'850',39),(437,'Albea',39),(438,'Barchetta',39),(439,'Brava',39),(440,'Bravo',39),(441,'Cinquecento',39),(442,'Coupe',39),(443,'Croma',39),(444,'Doblo',39),(445,'Ducato',39),(446,'Duna',39),(447,'Fiorino',39),(448,'Grande Punto',39),(449,'Idea',39),(450,'Linea',39),(451,'Marea',39),(452,'Multipla',39),(453,'Palio',39),(454,'Panda',39),(455,'Punto',39),(456,'Regata',39),(457,'Ritmo',39),(458,'Scudo',39),(459,'Sedici',39),(460,'Seicento',39),(461,'Siena',39),(462,'Stilo',39),(463,'Strada',39),(464,'Tempra',39),(465,'Tipo',39),(466,'Ulysse',39),(467,'Uno',39),(468,'X 1/9',39),(469,'',39),(470,'Aerostar',40),(471,'Aspire',40),(472,'Bronco',40),(473,'C-Max',40),(474,'Capri',40),(475,'Consul',40),(476,'Contour',40),(477,'Cougar',40),(478,'Courier',40),(479,'Crown Victoria',40),(480,'Econoline',40),(481,'Econovan',40),(482,'Edge',40),(483,'Escape',40),(484,'Escort',40),(485,'Everest',40),(486,'Excursion',40),(487,'Expedition',40),(488,'Explorer',40),(489,'F150',40),(490,'F250',40),(491,'F350',40),(492,'Fairline',40),(493,'Festiva',40),(494,'Fiesta',40),(495,'Five Hundred',40),(496,'Focus',40),(497,'Freestar',40),(498,'Freestyle',40),(499,'Fusion',40),(500,'Galaxy',40),(501,'Granada',40),(502,'Ikon',40),(503,'Ka',40),(504,'Kuga',40),(505,'Laser',40),(506,'Maverick',40),(507,'Mondeo',40),(508,'Mustang',40),(509,'Orion',40),(510,'Probe',40),(511,'Puma',40),(512,'Ranger',40),(513,'S-MAX',40),(514,'Scorpio',40),(515,'Sierra',40),(516,'Taunus',40),(517,'Taurus',40),(518,'Tempo',40),(519,'Territory',40),(520,'Thunderbird',40),(521,'Tourneo Connect',40),(522,'Transit',40),(523,'Windstar',40),(524,'Acadia',41),(525,'Canyon',41),(526,'Envoy',41),(527,'Jimmy',41),(528,'Safary',41),(529,'Savana',41),(530,'Sierra',41),(531,'Suburban',41),(532,'Typhoon',41),(533,'Vandura',41),(534,'Yukon',41),(535,'MK',42),(536,'Otaka',42),(537,'Vision',42),(538,'206',43),(539,'Prizm',43),(540,'Shtorm',43),(541,'Tracker',43),(542,'G',44),(543,'Alter',45),(544,'GX6',45),(545,'Deer',46),(546,'Hover',46),(547,'Pegasus',46),(548,'Peri',46),(549,'SUV',46),(550,'Safe',46),(551,'Sailor',46),(552,'Sing',46),(553,'Sokol',46),(554,'Wingle',46),(555,'Brio',47),(556,'Princip',47),(557,'Simbo',47),(558,'Caprice',48),(559,'Commodore',48),(560,'Statesman',48),(561,'Accord',49),(562,'Airwave',49),(563,'Ascot',49),(564,'Avancier',49),(565,'CR-V',49),(566,'CRX',49),(567,'Capa',49),(568,'City',49),(569,'Civic',49),(570,'Concerto',49),(571,'Del Sol',49),(572,'Domani',49),(573,'Element',49),(574,'Elysion',49),(575,'FR-V',49),(576,'Fit',49),(577,'HR-V',49),(578,'Insight',49),(579,'Inspire',49),(580,'Integra',49),(581,'Jazz',49),(582,'Lagreat',49),(583,'Legend',49),(584,'Life',49),(585,'Logo',49),(586,'Mobilio',49),(587,'NSX',49),(588,'Odyssey',49),(589,'Orthia',49),(590,'Partner',49),(591,'Passport',49),(592,'Pilot',49),(593,'Prelude',49),(594,'Rafaga',49),(595,'Ridgeline',49),(596,'S-MX',49),(597,'S2000',49),(598,'Saber',49),(599,'Shuttle',49),(600,'Spike',49),(601,'Stepwgn',49),(602,'Strea M',49),(603,'That\'S',49),(604,'Today',49),(605,'Torneo',49),(606,'Vamos',49),(607,'Vigor',49),(608,'Z',49),(609,'Zest',49),(610,'Antelope',50),(611,'Landscape',50),(612,'Major',50),(613,'Plutus',50),(614,'H1',51),(615,'H2',51),(616,'H3',51),(617,'Accent',52),(618,'Atos',52),(619,'Avante',52),(620,'Azera',52),(621,'Centennial',52),(622,'Coupe',52),(623,'Dynasty',52),(624,'Elantra',52),(625,'Entourage',52),(626,'Equis',52),(627,'Galloper',52),(628,'Genesis',52),(629,'Getz',52),(630,'Grandeur',52),(631,'H1 (Starex)',52),(632,'H100',52),(633,'H200',52),(634,'Lantra',52),(635,'Lavita',52),(636,'Marcia',52),(637,'Matrix',52),(638,'NF Sonata',52),(639,'Pony',52),(640,'Porter',52),(641,'S Coupe',52),(642,'Santa Fe',52),(643,'Santa Fe Classic',52),(644,'Santamo',52),(645,'Sonata',52),(646,'Stelar',52),(647,'Terracan',52),(648,'Tiburon',52),(649,'Trajet',52),(650,'Tucson',52),(651,'Tuscani',52),(652,'Veracruz',52),(653,'Verna',52),(654,'XG',52),(655,'i10',52),(656,'i30',52),(657,'EX',53),(658,'FX',53),(659,'G COUPE',53),(660,'G SEDAN',53),(661,'I',53),(662,'J30',53),(663,'M',53),(664,'Q45',53),(665,'QX',53),(666,'Honker',54),(667,'Lublin',54),(668,'Pars',55),(669,'Samand',55),(670,'Amigo',56),(671,'Ascender',56),(672,'Aska',56),(673,'Axiom',56),(674,'Bighorn',56),(675,'Crosswind',56),(676,'D-Max',56),(677,'Faster',56),(678,'Filly',56),(679,'Gemini',56),(680,'MU',56),(681,'Midi',56),(682,'Rodeo',56),(683,'Trooper',56),(684,'Vehi Cross',56),(685,'Wizard',56),(686,'Baodian',57),(687,'420',58),(688,'E-Type',58),(689,'S-Type',58),(690,'Sovereign',58),(691,'X-Type',58),(692,'XF',58),(693,'XJ',58),(694,'XJ220',58),(695,'XJR',58),(696,'XJS',58),(697,'XK',58),(698,'mark',58),(699,'Cherokee',59),(700,'Commander',59),(701,'Compass',59),(702,'Grand Cherokee',59),(703,'Liberty',59),(704,'Patriot',59),(705,'Wrangler',59),(706,'Haise',60),(707,'Avella',61),(708,'Besta',61),(709,'Carens',61),(710,'Carnival',61),(711,'Ceed',61),(712,'Cerato',61),(713,'Clarus',61),(714,'Cosmos',61),(715,'Elan',61),(716,'Enterprise',61),(717,'GrandBird',61),(718,'Joice',61),(719,'K',61),(720,'Magentis',61),(721,'Opirus',61),(722,'Optima',61),(723,'Picanto',61),(724,'Potentia',61),(725,'Pregio',61),(726,'Pride',61),(727,'Retona',61),(728,'Rio',61),(729,'Sedona',61),(730,'Sephia',61),(731,'Shuma',61),(732,'Sorento',61),(733,'Spectra',61),(734,'Sportage',61),(735,'Visto',61),(736,'X-Trek',61),(737,'Countach',62),(738,'Diablo',62),(739,'Espada',62),(740,'Gallardo',62),(741,'LM-002',62),(742,'Murcielago',62),(743,'Dedra',63),(744,'Delta',63),(745,'Fulvia',63),(746,'Kappa',63),(747,'Lybra',63),(748,'Musa',63),(749,'Phedra',63),(750,'Prisma',63),(751,'Thema',63),(752,'Thesis',63),(753,'Trevi',63),(754,'Ypsilon',63),(755,'Zeta',63),(756,'Defender',64),(757,'Discovery',64),(758,'Freelander',64),(759,'Range Rover',64),(760,'Range Rover Sport',64),(761,'SUV',65),(762,'X6',65),(763,'ES',66),(764,'GS',66),(765,'GX',66),(766,'IS',66),(767,'LS',66),(768,'LX',66),(769,'RX',66),(770,'SC',66),(771,'Breez',67),(772,'Aviator',68),(773,'Blackwood',68),(774,'Continental',68),(775,'LS',68),(776,'MKX',68),(777,'MKZ',68),(778,'Mark',68),(779,'Mark LT',68),(780,'Navigator',68),(781,'Town Car',68),(782,'Elise',69),(783,'Esprit',69),(784,'Europa',69),(785,'Exige',69),(786,'Seven',69),(787,'7',70),(788,'Express',70),(789,'MGF',70),(790,'Midget',70),(791,'TF',70),(792,'XPower SV',70),(793,'ZR',70),(794,'ZS',70),(795,'ZT',70),(796,'Clubman',71),(797,'Cooper',71),(798,'One',71),(799,'Armada',72),(800,'CJ',72),(801,'Commander',72),(802,'Marshal',72),(803,'Mantaray',73),(804,'Mantis',73),(805,'1000',74),(806,'800',74),(807,'Esteem',74),(808,'Gypsy',74),(809,'Omni',74),(810,'Zen',74),(811,'228',75),(812,'3200 GT',75),(813,'4300 GT Coupe',75),(814,'Coupe',75),(815,'Ghibli',75),(816,'Ghibli II',75),(817,'Gran Sport',75),(818,'Gran Turismo',75),(819,'M 128',75),(820,'Quattroporte',75),(821,'Spyder',75),(822,'57',76),(823,'57S',76),(824,'62',76),(825,'62S',76),(826,'121',77),(827,'2',77),(828,'3',77),(829,'323',77),(830,'5',77),(831,'6',77),(832,'626',77),(833,'929',77),(834,'Allegro',77),(835,'Atenza',77),(836,'Az-wagon',77),(837,'B-Series',77),(838,'BT-50',77),(839,'Bongo-Friendee',77),(840,'CX-7',77),(841,'CX-9',77),(842,'Capella',77),(843,'Carol',77),(844,'Demio',77),(845,'Efini MS-8',77),(846,'Familia',77),(847,'Fighter',77),(848,'Lantis',77),(849,'Levante',77),(850,'Luci',77),(851,'MPV',77),(852,'MPV 2',77),(853,'MX3',77),(854,'MX5',77),(855,'MX6',77),(856,'Millenia',77),(857,'Pick-Up',77),(858,'Premacy',77),(859,'Proceed',77),(860,'Protege',77),(861,'RX-4',77),(862,'RX-7',77),(863,'RX-8',77),(864,'Scrum',77),(865,'Sentia',77),(866,'Tribute',77),(867,'Verisa',77),(868,'Xedos 6',77),(869,'Xedos 9',77),(870,'F1',78),(871,'A-класс',79),(872,'B-класс',79),(873,'C-класс',79),(874,'CL-класс',79),(875,'CLC-класс',79),(876,'CLK-класс',79),(877,'CLS-класс',79),(878,'E-класс',79),(879,'G-класс',79),(880,'GL-класс',79),(881,'GLK-класс',79),(882,'M-класс',79),(883,'Pullmann',79),(884,'R-класс',79),(885,'S-класс',79),(886,'SL-класс',79),(887,'SLK-класс',79),(888,'SLR-класс',79),(889,'Sprinter',79),(890,'V-класс',79),(891,'Vaneo',79),(892,'Vario',79),(893,'Viano',79),(894,'Vito',79),(895,'W123',79),(896,'W124',79),(897,'Cougar',80),(898,'Grand Marquis',80),(899,'Mariner',80),(900,'Milan',80),(901,'Mountaineer',80),(902,'Mystique',80),(903,'Sable',80),(904,'Topaz',80),(905,'Tracer',80),(906,'Villager',80),(907,'Taxi',81),(908,'3000 GT',82),(909,'Airtrek',82),(910,'Aspire',82),(911,'Bravo',82),(912,'Carisma',82),(913,'Challenger',82),(914,'Chariot',82),(915,'Colt',82),(916,'Debonair',82),(917,'Delica',82),(918,'Diamante',82),(919,'Dingo',82),(920,'Dion',82),(921,'EK',82),(922,'Eclipse',82),(923,'Emeraude',82),(924,'Endeavor',82),(925,'Eterna',82),(926,'FTO',82),(927,'Fuso Canter',82),(928,'GTO',82),(929,'Galant',82),(930,'Grandis',82),(931,'L200',82),(932,'L300',82),(933,'L400',82),(934,'Lancer',82),(935,'Lancer Cedia',82),(936,'Lancer Evolution',82),(937,'Legnum',82),(938,'Libero',82),(939,'Magna',82),(940,'Minica',82),(941,'Mirage',82),(942,'Montero',82),(943,'Montero Sport',82),(944,'Outlander',82),(945,'Outlander XL',82),(946,'Pajero',82),(947,'Pajero IO',82),(948,'Pajero Junior',82),(949,'Pajero Mini',82),(950,'Pajero Pinin',82),(951,'Pajero Sport',82),(952,'Precis',82),(953,'Proudia',82),(954,'RVR',82),(955,'Raider',82),(956,'Sigma',82),(957,'Space Gear',82),(958,'Space Runner',82),(959,'Space Star',82),(960,'Space Wagon',82),(961,'Toppo',82),(962,'Town Box',82),(963,'Town Box Wide',82),(964,'Triton',82),(965,'i',82),(966,'Galue',83),(967,'Le-Seyde',83),(968,'4/4',84),(969,'Aero 8',84),(970,'Plus 4',84),(971,'Plus 8',84),(972,'100NX',85),(973,'180SX',85),(974,'200SX',85),(975,'240SX',85),(976,'280ZX',85),(977,'300ZX',85),(978,'350Z',85),(979,'AD',85),(980,'Almera',85),(981,'Almera Classic',85),(982,'Almera Tino',85),(983,'Altima',85),(984,'Armada',85),(985,'Avenir',85),(986,'Bassara',85),(987,'Bluebird',85),(988,'Bluebird Sylphy',85),(989,'Caravan',85),(990,'Cedric',85),(991,'Cefiro',85),(992,'Cherry',85),(993,'Cima',85),(994,'Civilian',85),(995,'Crew',85),(996,'Cube',85),(997,'Datsun',85),(998,'Elgrand',85),(999,'Expert',85),(1000,'Fairlady',85),(1001,'Frontier',85),(1002,'Gloria',85),(1003,'Largo',85),(1004,'Laurel',85),(1005,'Leopard',85),(1006,'Liberty',85),(1007,'Livina Geniss',85),(1008,'Lucino',85),(1009,'March',85),(1010,'Maxima',85),(1011,'Maxima QX',85),(1012,'Micra',85),(1013,'Mistral',85),(1014,'Moco',85),(1015,'Murano',85),(1016,'NP300',85),(1017,'Navara',85),(1018,'Note',85),(1019,'Otti',85),(1020,'Pathfinder',85),(1021,'Pathfinder Aramada',85),(1022,'Patrol',85),(1023,'Pickup',85),(1024,'Prairie',85),(1025,'Presage',85),(1026,'Presea',85),(1027,'President',85),(1028,'Primastar',85),(1029,'Primera',85),(1030,'Pulsar',85),(1031,'Qashqai',85),(1032,'Quest',85),(1033,'R\'nessa',85),(1034,'Rasheen',85),(1035,'Rogue',85),(1036,'Safari',85),(1037,'Sentra',85),(1038,'Serena',85),(1039,'Silvia',85),(1040,'Skyline',85),(1041,'Stagea',85),(1042,'Stanza',85),(1043,'Sunny',85),(1044,'Teana',85),(1045,'Terrano',85),(1046,'Tiida',85),(1047,'Tiida latio',85),(1048,'Tino',85),(1049,'Titan',85),(1050,'Vanette',85),(1051,'Versa',85),(1052,'Wingroad',85),(1053,'X-Trail',85),(1054,'Xterra',85),(1055,'Achieva',86),(1056,'Alero',86),(1057,'Aurora',86),(1058,'Bravada',86),(1059,'Cutlass',86),(1060,'Cutlass Calais',86),(1061,'Cutlass Ciera',86),(1062,'Cutlass Cruiser',86),(1063,'Cutlass Supreme',86),(1064,'Delta',86),(1065,'Eighty Eight',86),(1066,'Intrigue',86),(1067,'Nineghty eight',86),(1068,'Omega',86),(1069,'Silhouette',86),(1070,'Admiral',87),(1071,'Agila',87),(1072,'Antara',87),(1073,'Arena',87),(1074,'Ascona',87),(1075,'Astra',87),(1076,'Calibra',87),(1077,'Campo',87),(1078,'Combo',87),(1079,'Corsa',87),(1080,'Frontera',87),(1081,'GT',87),(1082,'Insignia',87),(1083,'Kadett',87),(1084,'Manta',87),(1085,'Meriva',87),(1086,'Monterey',87),(1087,'Monza',87),(1088,'Movano',87),(1089,'Olimpia',87),(1090,'Omega',87),(1091,'Rekord',87),(1092,'Senator',87),(1093,'Signum',87),(1094,'Sintra',87),(1095,'Speedster',87),(1096,'Tigra',87),(1097,'Vectra',87),(1098,'Vita',87),(1099,'Vivaro',87),(1100,'Zafira',87),(1101,'Pinzgauer',88),(1102,'Zonda',89),(1103,'Esperante',90),(1104,'1007',91),(1105,'106',91),(1106,'107',91),(1107,'204',91),(1108,'205',91),(1109,'206',91),(1110,'207',91),(1111,'305',91),(1112,'306',91),(1113,'307',91),(1114,'308',91),(1115,'4007',91),(1116,'405',91),(1117,'406',91),(1118,'407',91),(1119,'504',91),(1120,'505',91),(1121,'604',91),(1122,'605',91),(1123,'607',91),(1124,'608',91),(1125,'806',91),(1126,'807',91),(1127,'Boxer',91),(1128,'Expert',91),(1129,'Partner',91),(1130,'',91),(1131,'Acclaim',92),(1132,'Breeze',92),(1133,'Laser',92),(1134,'Neon',92),(1135,'Prowler',92),(1136,'Sundance',92),(1137,'Voyager',92),(1138,'Aztec',93),(1139,'Bonneville',93),(1140,'Firebird',93),(1141,'G5',93),(1142,'G6',93),(1143,'G7',93),(1144,'G8',93),(1145,'GTO',93),(1146,'Grand AM',93),(1147,'Grand Prix',93),(1148,'Lemans',93),(1149,'Montana',93),(1150,'Phoenix',93),(1151,'Solstice',93),(1152,'Sunbird',93),(1153,'Sunfire',93),(1154,'Torrent',93),(1155,'Trans AM',93),(1156,'Trans Sport',93),(1157,'Vibe',93),(1158,'Wave',93),(1159,'911',94),(1160,'924',94),(1161,'928',94),(1162,'944',94),(1163,'968',94),(1164,'996',94),(1165,'997',94),(1166,'Boxster',94),(1167,'Carrera GT',94),(1168,'Cayenne',94),(1169,'Cayman',94),(1170,'315',95),(1171,'415',95),(1172,'Persona',95),(1173,'Putra',95),(1174,'Satria',95),(1175,'10',96),(1176,'11',96),(1177,'14',96),(1178,'18',96),(1179,'19',96),(1180,'21',96),(1181,'25',96),(1182,'30',96),(1183,'4',96),(1184,'5',96),(1185,'8',96),(1186,'9',96),(1187,'Avantime',96),(1188,'Clio',96),(1189,'Espace',96),(1190,'Express',96),(1191,'Fuego',96),(1192,'Grand Espace',96),(1193,'Grand Scenic',96),(1194,'Kangoo',96),(1195,'Koleos',96),(1196,'Laguna',96),(1197,'Logan',96),(1198,'Magnum',96),(1199,'Mascott',96),(1200,'Master',96),(1201,'Megane',96),(1202,'Midlum',96),(1203,'Modus',96),(1204,'Nevada',96),(1205,'Premium',96),(1206,'Rapid',96),(1207,'Safrane',96),(1208,'Scenic',96),(1209,'Sport Spyder',96),(1210,'Symbol',96),(1211,'Trafic',96),(1212,'Twingo',96),(1213,'Vel Satis',96),(1214,'750',97),(1215,'Corniche',98),(1216,'Park Ward',98),(1217,'Phantom',98),(1218,'Silver Seraph',98),(1219,'Silver Spur',98),(1220,'100',99),(1221,'200',99),(1222,'213',99),(1223,'25',99),(1224,'2600',99),(1225,'400',99),(1226,'45',99),(1227,'600',99),(1228,'75',99),(1229,'800',99),(1230,'City',99),(1231,'MGF',99),(1232,'Maestro',99),(1233,'Metro',99),(1234,'Mini',99),(1235,'Streetwise',99),(1236,'Alhambra',100),(1237,'Altea',100),(1238,'Arosa',100),(1239,'Cordoba',100),(1240,'Exeo',100),(1241,'Freetrack',100),(1242,'Ibiza',100),(1243,'Inca',100),(1244,'Leon',100),(1245,'Marbella',100),(1246,'Toledo',100),(1247,'XL',100),(1248,'9-2',101),(1249,'9-3',101),(1250,'9-5',101),(1251,'9-7X',101),(1252,'900',101),(1253,'900 II',101),(1254,'9000',101),(1255,'S7',102),(1256,'SM3',103),(1257,'SM5',103),(1258,'SM7',103),(1259,'Astra',104),(1260,'Aura',104),(1261,'ION',104),(1262,'Ion Red Line',104),(1263,'LS',104),(1264,'LW',104),(1265,'Outlook',104),(1266,'SC1',104),(1267,'SC2',104),(1268,'SL',104),(1269,'SL2',104),(1270,'SW',104),(1271,'Sky',104),(1272,'VUE',104),(1273,'tC',105),(1274,'xA',105),(1275,'xB',105),(1276,'xD',105),(1277,'SCEO',107),(1278,'105, 120',108),(1279,'Fabia',108),(1280,'Favorit',108),(1281,'Felicia',108),(1282,'Forman',108),(1283,'Octavia',108),(1284,'Octavia Scout',108),(1285,'Octavia Tour',108),(1286,'Praktik',108),(1287,'Rapid',108),(1288,'Roomster',108),(1289,'Superb',108),(1290,'City',109),(1291,'Forfour',109),(1292,'Fortwo',109),(1293,'Roadster',109),(1294,'C8',110),(1295,'Actyon',111),(1296,'Actyon Sport',111),(1297,'Chairman',111),(1298,'Istana',111),(1299,'Korando',111),(1300,'Korando Family',111),(1301,'Kyron',111),(1302,'Musso',111),(1303,'Musso Sports',111),(1304,'Rexton',111),(1305,'Rodius',111),(1306,'Baja',112),(1307,'Dias Wagon',112),(1308,'E10',112),(1309,'E12',112),(1310,'Forester',112),(1311,'Impreza',112),(1312,'Impreza WRX STI',112),(1313,'Justy',112),(1314,'Legacy',112),(1315,'Leone',112),(1316,'Libero',112),(1317,'Outback',112),(1318,'Pleo',112),(1319,'R1',112),(1320,'R2',112),(1321,'SVX',112),(1322,'Sambar',112),(1323,'Stella',112),(1324,'Traviq',112),(1325,'Tribeca',112),(1326,'Vivio',112),(1327,'Aerio',113),(1328,'Alto',113),(1329,'Baleno',113),(1330,'Cappuccino',113),(1331,'Cultus',113),(1332,'Equator',113),(1333,'Escudo',113),(1334,'Esteem',113),(1335,'Every',113),(1336,'Forenza',113),(1337,'Geo',113),(1338,'Grand Vitara',113),(1339,'Ignis',113),(1340,'Jimny',113),(1341,'Kei',113),(1342,'Lapin',113),(1343,'Liana',113),(1344,'Reno',113),(1345,'SX4',113),(1346,'Samurai',113),(1347,'Sidekick',113),(1348,'Solio',113),(1349,'Splash',113),(1350,'Swift',113),(1351,'Twin',113),(1352,'Verona',113),(1353,'Vitara',113),(1354,'Wagon R+',113),(1355,'X-90',113),(1356,'XL-7',113),(1357,'Cerbera',114),(1358,'Chimaera',114),(1359,'Griffith',114),(1360,'T350',114),(1361,'Tamora',114),(1362,'Tuscan',114),(1363,'1307-1510',115),(1364,'Horizon',115),(1365,'Tagora',115),(1366,'Indica',116),(1367,'613',117),(1368,'700',117),(1369,'815',117),(1370,'Century',118),(1371,'Admiral',119),(1372,'Banner',119),(1373,'Dogan',120),(1374,'Kartal',120),(1375,'Sahin',120),(1376,'Serce',120),(1377,'Tempra',120),(1378,'4 Runner',121),(1379,'Allex',121),(1380,'Allion',121),(1381,'Alphard',121),(1382,'Altezza',121),(1383,'Aristo',121),(1384,'Aurion',121),(1385,'Auris',121),(1386,'Avalon',121),(1387,'Avensis',121),(1388,'Avensis Verso',121),(1389,'Aygo',121),(1390,'Bandeirante',121),(1391,'Brevis',121),(1392,'Caldina',121),(1393,'Cami',121),(1394,'Camry',121),(1395,'Camry Solara',121),(1396,'Carina',121),(1397,'Carina E',121),(1398,'Carina ED',121),(1399,'Cavalier',121),(1400,'Celica',121),(1401,'Celsior',121),(1402,'Century',121),(1403,'Chaser',121),(1404,'Coaster',121),(1405,'Corolla',121),(1406,'Corolla Ceres',121),(1407,'Corolla Fielder',121),(1408,'Corolla Levin',121),(1409,'Corolla Runx',121),(1410,'Corolla Spacio',121),(1411,'Corolla Verso',121),(1412,'Corona',121),(1413,'Corona Premio',121),(1414,'Corsa',121),(1415,'Cressida',121),(1416,'Cresta',121),(1417,'Crown',121),(1418,'Crown Athlete',121),(1419,'Crown Majesta',121),(1420,'Crown Royal',121),(1421,'Curren',121),(1422,'Cynos',121),(1423,'Duet',121),(1424,'Echo',121),(1425,'Estima',121),(1426,'Estima Lucida',121),(1427,'FJ Cruiser',121),(1428,'Fortuner',121),(1429,'Funcargo',121),(1430,'Gaia',121),(1431,'Grand hiace',121),(1432,'Granvia',121),(1433,'Harrier',121),(1434,'Hiace',121),(1435,'Highlander',121),(1436,'Hilux',121),(1437,'Hilux Surf',121),(1438,'Ipsum',121),(1439,'Isis',121),(1440,'Ist',121),(1441,'Kluger',121),(1442,'Land Cruiser',121),(1443,'Land Cruiser Prado',121),(1444,'Lite Ace',121),(1445,'MR2',121),(1446,'MRS',121),(1447,'Mark II',121),(1448,'Mark X',121),(1449,'Matrix',121),(1450,'Nadia',121),(1451,'Noah',121),(1452,'Opa',121),(1453,'Origin',121),(1454,'Paseo',121),(1455,'Passo',121),(1456,'Picnic',121),(1457,'Platz',121),(1458,'Porte',121),(1459,'Premio',121),(1460,'Previa',121),(1461,'Prius',121),(1462,'Probox',121),(1463,'Progres',121),(1464,'Pronard',121),(1465,'Ractis',121),(1466,'Raum',121),(1467,'Rav 4',121),(1468,'Regius',121),(1469,'Regius ACE',121),(1470,'Rush',121),(1471,'Scepter',121),(1472,'Scion',121),(1473,'Sequoia',121),(1474,'Sera',121),(1475,'Sienna',121),(1476,'Sienta',121),(1477,'Soarer',121),(1478,'Solara',121),(1479,'Sparky',121),(1480,'Sprinter',121),(1481,'Sprinter Marino',121),(1482,'Starlet',121),(1483,'Succeed',121),(1484,'Supra',121),(1485,'Tacoma',121),(1486,'Tercel',121),(1487,'Town Ace',121),(1488,'Tundra',121),(1489,'Verossa',121),(1490,'Vios',121),(1491,'Vista',121),(1492,'Vitz',121),(1493,'Voltz',121),(1494,'Voxy',121),(1495,'Will Cypha',121),(1496,'Will VS',121),(1497,'Windom',121),(1498,'Wish',121),(1499,'Yaris',121),(1500,'Yaris Verso',121),(1501,'bB',121),(1502,'',121),(1503,'600',122),(1504,'601',122),(1505,'300',123),(1506,'400',123),(1507,'Fetish',123),(1508,'Beetle',124),(1509,'Bora',124),(1510,'Caddy',124),(1511,'California',124),(1512,'Camper',124),(1513,'Caravelle',124),(1514,'Corrado',124),(1515,'Country Buggy',124),(1516,'Crafter',124),(1517,'EOS',124),(1518,'EuroVan',124),(1519,'Fox',124),(1520,'Gol',124),(1521,'Golf',124),(1522,'Golf Plus',124),(1523,'Iltis',124),(1524,'Jetta',124),(1525,'Kaefer',124),(1526,'LT',124),(1527,'Lupo',124),(1528,'Multivan',124),(1529,'NEW Beetle',124),(1530,'Parati',124),(1531,'Passat',124),(1532,'Passat CC',124),(1533,'Phaeton',124),(1534,'Pointer',124),(1535,'Polo',124),(1536,'Quantum',124),(1537,'Santana',124),(1538,'Scirocco',124),(1539,'Sharan',124),(1540,'Taro',124),(1541,'Tiguan',124),(1542,'Touareg',124),(1543,'Touran',124),(1544,'Transporter',124),(1545,'Vento',124),(1546,'140',125),(1547,'164',125),(1548,'240',125),(1549,'260',125),(1550,'340',125),(1551,'360',125),(1552,'440',125),(1553,'460',125),(1554,'480',125),(1555,'740',125),(1556,'744',125),(1557,'745',125),(1558,'760',125),(1559,'780',125),(1560,'850',125),(1561,'940',125),(1562,'944',125),(1563,'945',125),(1564,'960',125),(1565,'C30',125),(1566,'C70',125),(1567,'S40',125),(1568,'S60',125),(1569,'S70',125),(1570,'S80',125),(1571,'S90',125),(1572,'V40',125),(1573,'V50',125),(1574,'V70',125),(1575,'V90',125),(1576,'XC60',125),(1577,'XC70',125),(1578,'XC90',125),(1579,'Estina',126),(1580,'353',127),(1581,'Roadster',128),(1582,'Pickup X3',129),(1583,'SR-V X3',129),(1584,'SUV X3',129),(1585,'Dragon',130),(1586,'Fine',130),(1587,'Flying',130),(1588,'Liebao',130),(1589,'Grand Tiger',131),(1590,'landmark',131),(1591,'1111',132),(1592,'1922',132),(1593,'2101',132),(1594,'2102',132),(1595,'2103',132),(1596,'2104',132),(1597,'2105',132),(1598,'2106',132),(1599,'2107',132),(1600,'2108',132),(1601,'2109',132),(1602,'21099',132),(1603,'2110',132),(1604,'2111',132),(1605,'2112',132),(1606,'2113',132),(1607,'2114',132),(1608,'2115',132),(1609,'2120',132),(1610,'2121',132),(1611,'2123',132),(1612,'2129',132),(1613,'2131',132),(1614,'2328',132),(1615,'2329',132),(1616,'2345',132),(1617,'2346',132),(1618,'2347',132),(1619,'2364',132),(1620,'2723',132),(1621,'Kalina',132),(1622,'Priora',132),(1623,'Автокам-2160',133),(1624,'12',134),(1625,'13',134),(1626,'14',134),(1627,'17310',134),(1628,'21',134),(1629,'22',134),(1630,'2217',134),(1631,'22171',134),(1632,'2308',134),(1633,'2310',134),(1634,'2330',134),(1635,'24',134),(1636,'24-10',134),(1637,'2402',134),(1638,'2705',134),(1639,'2752',134),(1640,'3102',134),(1641,'3103',134),(1642,'3104',134),(1643,'3105',134),(1644,'3106',134),(1645,'3110',134),(1646,'31105',134),(1647,'3111',134),(1648,'3120',134),(1649,'3129',134),(1650,'3221',134),(1651,'3234',134),(1652,'3302',134),(1653,'3307',134),(1654,'3308',134),(1655,'3309',134),(1656,'3310',134),(1657,'52/53',134),(1658,'66',134),(1659,'67',134),(1660,'69',134),(1661,'M-1',134),(1662,'M-20',134),(1663,'Volga Siber',134),(1664,'762',135),(1665,'1111',136),(1666,'1111',137),(1667,'43',137),(1668,'53',137),(1669,'54',137),(1670,'55',137),(1671,'65',137),(1672,'965',138),(1673,'966',138),(1674,'968',138),(1675,'968М',138),(1676,'Sens',138),(1677,'Таврия',138),(1678,'114',139),(1679,'115',139),(1680,'117',139),(1681,'130',139),(1682,'4104',139),(1683,'41047',139),(1684,'4741',139),(1685,'5301',139),(1686,'2117',140),(1687,'2125',140),(1688,'2126 / Ода',140),(1689,'2715',140),(1690,'2717',140),(1691,'412',140),(1692,'1302',141),(1693,'967',141),(1694,'967М',141),(1695,'969',141),(1696,'969А',141),(1697,'969Б',141),(1698,'969М',141),(1699,'2125',142),(1700,'2135',142),(1701,'2137',142),(1702,'2138',142),(1703,'2140',142),(1704,'2141',142),(1705,'2901',142),(1706,'400',142),(1707,'401',142),(1708,'402',142),(1709,'403',142),(1710,'407',142),(1711,'408',142),(1712,'410',142),(1713,'412',142),(1714,'426',142),(1715,'427',142),(1716,'Князь Владимир',142),(1717,'Святогор',142),(1718,'Юрий Долгорукий',142),(1719,'2206',143),(1720,'2362',143),(1721,'3150',143),(1722,'3151',143),(1723,'31512',143),(1724,'31514',143),(1725,'31519',143),(1726,'315195 / Hunter',143),(1727,'3153',143),(1728,'3159',143),(1729,'3160',143),(1730,'3162',143),(1731,'3163 / Patriot',143),(1732,'3165',143),(1733,'3303',143),(1734,'3309',143),(1735,'3741',143),(1736,'3909',143),(1737,'3962',143),(1738,'459',143),(1739,'469',143);
/*!40000 ALTER TABLE `car_model` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `color`
--

DROP TABLE IF EXISTS `color`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `color` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `color`
--

LOCK TABLES `color` WRITE;
/*!40000 ALTER TABLE `color` DISABLE KEYS */;
INSERT INTO `color` VALUES (1,'(GM) Бежево-золотистый'),(2,'(GM) Светло-серый'),(3,'(GM) Ярко-красный'),(4,'(GM) Ярко-синий'),(5,'(ИЖ) Вишнёвый'),(6,'(ИЖ) Золотисто-бежевый'),(7,'(ИЖ) Серебристо-вишнёвый'),(8,'(ИЖ) Серебристо-серо-графитовый'),(9,'(ИЖ) Серебристо-тёмно-синий'),(10,'(ИЖ) Серебристый'),(11,'(ИЖ) Серый серебристый'),(12,'(ИЖ) Сине-зелёный'),(13,'(ИЖ) Тёмно-зелёный'),(14,'(ИЖ) Тёмно-синий'),(15,'(УАЗ) Тёмно-коричневый'),(16,'(УАЗ) Тёмно-серо-зелёный'),(17,'Бежево-жёлтый'),(18,'Бежево-коричневый'),(19,'Бежево-красный'),(20,'Бежево-сиреневый'),(21,'Бежевый'),(22,'Белая двухслойная'),(23,'Бело-жёлтый'),(24,'Белый'),(25,'Белый металлик'),(26,'Голубой'),(27,'Желто-зелёный'),(28,'Желто-золотой'),(29,'Жёлтый'),(30,'Зелено-голубой'),(31,'Зелено-синий'),(32,'Зелёный'),(33,'Золотисто-зелёный'),(34,'Золотисто-коричневый'),(35,'Золотисто-красный'),(36,'Золотисто-оливковый'),(37,'Золотистый тёмно-зелёный'),(38,'Коричневый'),(39,'Красно-коричневый'),(40,'Красный'),(41,'Красный металлик'),(42,'Металлик серо-бежевый'),(43,'Мускари'),(44,'Оливково-зелёный'),(45,'Оранжево-коричневый'),(46,'Оранжевый'),(47,'Оттенок тёмно-синего'),(48,'Оттенок чёрного'),(49,'Салатовый'),(50,'Светло-бежевый'),(51,'Светло-голубой'),(52,'Светло-жёлтый'),(53,'Светло-серый'),(54,'Светло-синий'),(55,'Светло-фиолетовый'),(56,'Светлый серо-бежевый'),(57,'Серебристо-бежево-розовый'),(58,'Серебристо-бежевый'),(59,'Серебристо-бело-молочный'),(60,'Серебристо-бледно-серый'),(61,'Серебристо-голубоватый'),(62,'Серебристо-голубой'),(63,'Серебристо-жёлто-зелёный'),(64,'Серебристо-жёлтый'),(65,'Серебристо-зелёно-голубой'),(66,'Серебристо-зеленоватый'),(67,'Серебристо-зелёный'),(68,'Серебристо-коричневый'),(69,'Серебристо-красно-оранжевый'),(70,'Серебристо-красный'),(71,'Серебристо-молочно-зелёный'),(72,'Серебристо-светло оранжевый'),(73,'Серебристо-серо-бежевый'),(74,'Серебристо-серо-голубоватый'),(75,'Серебристо-серо-графитовый'),(76,'Серебристо-серо-зеленоватый'),(77,'Серебристо-серо-зелёный'),(78,'Серебристо-серо-золотистый'),(79,'Серебристо-серо-коричневый'),(80,'Серебристо-серо-синий'),(81,'Серебристо-серый'),(82,'Серебристо-синий'),(83,'Серебристо-сиреневый'),(84,'Серебристо-тёмно серый'),(85,'Серебристо-тёмно-зелёный'),(86,'Серебристо-тёмно-серо-синий'),(87,'Серебристо-тёмно-синий'),(88,'Серебристо-фиолетовый'),(89,'Серебристо-чёрный'),(90,'Серебристо-ярко-зелёный'),(91,'Серебристо-ярко-синий'),(92,'Серебристо-ярко-фиолетовый'),(93,'Серебристый'),(94,'Серебристый болотно-зелёный'),(95,'Серебристый коричнево-зелёный'),(96,'Серебристый оранжевый'),(97,'Серебристый светло-серый'),(98,'Серебристый сине-зелёный'),(99,'Серебристый сине-фиолетовый'),(100,'Серебристый стальной'),(101,'Серебристый тёмно-бордовый'),(102,'Серебристый тёмно-красный'),(103,'Серебристый тёмно-синий'),(104,'Серебристый тёмно-фиолетовый'),(105,'Серебристый фиолетовый'),(106,'Серебристый ярко-красный'),(107,'Серебристый-бежевый'),(108,'Серебристый-желто-зелёный'),(109,'Серебристый-зеленовато-серый'),(110,'Серо-бежевый'),(111,'Серо-белый'),(112,'Серо-голубой'),(113,'Серо-зеленоватый'),(114,'Серо-зелёный'),(115,'Серо-коричневый'),(116,'Серо-синий'),(117,'Серо-фиолетовый'),(118,'Серо-чёрный'),(119,'Серый'),(120,'Сине-зелёный'),(121,'Сине-фиолетовый'),(122,'Синий'),(123,'Сливочно-белый'),(124,'Снежно-белый'),(125,'Средне-стальной'),(126,'Тёмно коричневый'),(127,'Тёмно-алый'),(128,'Тёмно-бежевый'),(129,'Тёмно-бордовый'),(130,'Тёмно-вишнёво-малиновый'),(131,'Тёмно-вишнёвый'),(132,'Тёмно-вишнёвый металлик'),(133,'Тёмно-голубой'),(134,'Тёмно-зелёный'),(135,'Тёмно-коричневый'),(136,'Тёмно-красный'),(137,'Тёмно-серебристо-красный'),(138,'Тёмно-серый'),(139,'Тёмно-сине-зелёный'),(140,'Тёмно-синий'),(141,'Тёмно-филетовый'),(142,'Тёмно-фиолетовый'),(143,'Фиолетово-синий'),(144,'Фиолетовый'),(145,'Цвет морской волны'),(146,'Чёрный'),(147,'Чёрный, двойная эмаль'),(148,'Ярко-жёлтый'),(149,'Ярко-зелёный'),(150,'Ярко-красный'),(151,'Ярко-синий'),(152,'Ярко-фиолетовый');
/*!40000 ALTER TABLE `color` ENABLE KEYS */;
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
  UNIQUE KEY `phone_number_UNIQUE` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
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
  `surname` varchar(128) NOT NULL,
  `patronymic` varchar(128) NOT NULL,
  `birth_date` date NOT NULL,
  `phone_number` varchar(30) NOT NULL,
  `working` tinyint(1) DEFAULT '0',
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `authToken` varchar(255) DEFAULT NULL,
  `activated` tinyint(1) DEFAULT '0',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  UNIQUE KEY `phone_number_UNIQUE` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver`
--

LOCK TABLES `driver` WRITE;
/*!40000 ALTER TABLE `driver` DISABLE KEYS */;
/*!40000 ALTER TABLE `driver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver_documents`
--

DROP TABLE IF EXISTS `driver_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `driver_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) NOT NULL,
  `passport_number` varchar(11) NOT NULL,
  `passport_image` varchar(255) NOT NULL,
  `driving_license_number` varchar(128) NOT NULL,
  `expiry_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `driving_license_image` varchar(255) NOT NULL,
  `sts_photo` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `passport_number_UNIQUE` (`passport_number`),
  UNIQUE KEY `driving_license_number_UNIQUE` (`driving_license_number`),
  KEY `fk_driver_documents_driver1_idx` (`driver_id`),
  CONSTRAINT `fk_driver_documents_driver1` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver_documents`
--

LOCK TABLES `driver_documents` WRITE;
/*!40000 ALTER TABLE `driver_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `driver_documents` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
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
  CONSTRAINT `fk_shift_driver1` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
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
CREATE DEFINER=`root`@`%` PROCEDURE `cabRideStatusCheck`(IN cab_ride_id int)
BEGIN
    DECLARE shift_id_check int DEFAULT NULL;
    set shift_id_check = (SELECT @shift_id_check:=shift_id FROM cab_ride WHERE cab_ride.id = cab_ride_id);
    IF shift_id_check IS NOT NULL THEN
        SELECT first_name, surname, phone_number, license_plate, color.description, model_name, brand_name, ride_status FROM cab_ride, color, driver, shift, cab, car_model, car_brand, cab_ride_status WHERE cab_ride.id=cab_ride_id AND cab.driver_id = driver.id AND cab.color_id = color.id AND cab_ride.shift_id = shift.id AND shift.driver_id = driver.id AND cab.car_model_id = car_model.id AND car_model.car_brand_id = car_brand.id AND cab.active = 1;
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

-- Dump completed on 2019-06-02 15:37:32
