<?php

require_once 'vendor/autoload.php';

error_reporting(E_ALL & ~(E_STRICT | E_NOTICE | E_DEPRECATED | E_WARNING));

define('TYPO3_MODE','BE');
define('TYPO3_cliMode', TRUE);
unset($_SERVER['argv'][0]);

define('TYPO3_OS', stristr(PHP_OS,'win')&&!stristr(PHP_OS,'darwin')?'WIN':'');
define('PATH_thisScript', __DIR__.'/t3/typo3');
define('PATH_site', __DIR__.'/t3/');		// the path to the website folder (see init.php)
define('PATH_t3lib', PATH_site.'t3lib/');
define('PATH_typo3conf', PATH_site.'typo3conf/');
define('TYPO3_mainDir', 'typo3/');		// This is the directory of the backend administration for the sites of this TYPO3 installation.
define('PATH_typo3', PATH_site.TYPO3_mainDir);
define('PATH_tslib', PATH_site.'typo3/sysext/cms/tslib/');


global $TYPO3_CONF_VARS,$TYPO3_DB;

// ******************
// Including config
// ******************
require_once(PATH_t3lib.'class.t3lib_div.php');
require_once(PATH_t3lib.'class.t3lib_extmgm.php');

require(PATH_t3lib.'config_default.php');

$TYPO3_DB = t3lib_div::makeInstance('t3lib_DB');
