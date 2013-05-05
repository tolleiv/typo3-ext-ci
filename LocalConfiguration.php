<?php
return array(
	'DB' => array(
		'database' => 'nothing', 'host' => '###path###/db.sqlite', 'password' => 'nothing', 'username' => 'nothing',
	),
	'EXT' => array(
		'extListArray' => array(
			'filelist','version','tsconfig_help','context_help','extra_page_cm_options','impexp','belog','about',
			'cshmanual','aboutmodules','setup','opendocs','install','dbal','adodb','extbase',
			'phpunit',
			'###ext###'
		)
	),
	'EXTCONF' => array(
		'dbal' => array(
			'handlerCfg' => array(
				'_DEFAULT' => array(
					'type' => 'adodb',
					'config' => array(
						'database' => TRUE,
						'driver' => 'sqlite://###path###/db.sqlite'
					)
				)
			)
		)
	)
);