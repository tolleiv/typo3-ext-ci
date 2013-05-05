<?php

$typo_db_username = 'nothing';
$typo_db_password = 'nothing';
$typo_db_host = '###path###/db.sqlite';
$typo_db = 'nothing';

$GLOBALS['TYPO3_CONF_VARS']['EXT']['extList'] = 'cms,setup,install,rsaauth,saltedpasswords,extbase,fluid,version,workspaces,phpunit,###ext###';
$GLOBALS['TYPO3_CONF_VARS']['EXT']['extList_FE'] = 'cms,setup,install,rsaauth,saltedpasswords,extbase,fluid,version,workspaces,phpunit,###ext###';
$GLOBALS['TYPO3_CONF_VARS']['EXT']['extCache'] = FALSE;

$GLOBALS['TYPO3_CONF_VARS']['SYS']['displayErrors'] = '1';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['enableDeprecationLog'] = FALSE;
$GLOBALS['TYPO3_CONF_VARS']['SYS']['useCachingFramework'] = FALSE;
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching'] = array(
	'cacheConfigurations' => array(
		'cache_hash' => array(
			'frontend' => 't3lib_cache_frontend_VariableFrontend',
			'backend' => 't3lib_cache_backend_NullBackend',
			'options' => array(),
		),
		'cache_pages' => array(
			'frontend' => 't3lib_cache_frontend_VariableFrontend',
			'backend' => 't3lib_cache_backend_NullBackend',
			'options' => array(),
		),
		'cache_pagesection' => array(
			'frontend' => 't3lib_cache_frontend_VariableFrontend',
			'backend' => 't3lib_cache_backend_NullBackend',
			'options' => array(),
		),
		'cache_phpcode' => array(
			'frontend' => 't3lib_cache_frontend_PhpFrontend',
			'backend' => 't3lib_cache_backend_NullBackend',
			'options' => array(),
		),
		'cache_runtime' => array(
			'frontend' => 't3lib_cache_frontend_VariableFrontend',
			'backend' => 't3lib_cache_backend_NullBackend',
			'options' => array(),
		),
	),
);
$TYPO3_CONF_VARS['EXTCONF']['dbal'] = array(
	'handlerCfg' => array(
		'_DEFAULT' => array(
			'type' => 'adodb',
			'config' => array(
				'database' => TRUE,
				'driver' => 'sqlite://'.$typo_db_host
			)
		)
	)
);