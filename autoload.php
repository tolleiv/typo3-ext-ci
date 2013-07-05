<?php
if (file_exists('vendor/autoload.php')) require_once 'vendor/autoload.php';
require_once '###path###/t3/typo3/sysext/core/Classes/Core/Bootstrap.php';
define('TYPO3_MODE', 'BE');
define('TYPO3_cliMode', TRUE);
unset($_SERVER['argv'][0]);
$_ENV['_'] = '###path###/t3/i.php';
require_once '###path###/t3/typo3/sysext/core/Classes/Core/CliBootstrap.php';
\TYPO3\CMS\Core\Core\CliBootstrap::checkEnvironmentOrDie();
require_once '###path###/t3/typo3/sysext/core/Classes/Core/Bootstrap.php';
\TYPO3\CMS\Core\Core\Bootstrap::getInstance()
		->baseSetup('')
		->loadConfigurationAndInitialize()
		->loadTypo3LoadedExtAndExtLocalconf(FALSE)
		->applyAdditionalConfigurationSettings()
		->initializeTypo3DbGlobal(TRUE);
