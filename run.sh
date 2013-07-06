#!/bin/bash

export test_typo3_branch test_db_host test_db_user test_db_password test_db_name
export test_no_tests_flag test_quiet_flag test_install_extbase_flag test_install_fluid_flag test_miau_flag test_travis_flag

qprint() {
	if (( ${test_quiet_flag:-0} == 0 )) ; then
		echo $1
	fi
}

run() {
	qprint "Preparing tests"
	CWD=`pwd`
	prepare_files $CWD $1


	if (( ${test_travis_flag:-0} == 0 )) ; then
		curl -sS https://getcomposer.org/installer | php  -d detect_unicode=Off -d apc.enable_cli=Off
		php -d detect_unicode=Off -d apc.enable_cli=Off composer.phar install --dev
		PHPUNIT=vendor/bin/phpunit
	else
		PHPUNIT=phpunit
	fi

	cloneorupdate "${CWD}/Core" "git://git.typo3.org/Packages/TYPO3.CMS.git" "${2}"
	cloneorupdate "${CWD}/t3/typo3conf/ext/phpunit" "git://git.typo3.org/TYPO3v4/Extensions/phpunit.git" "master"

	cd t3;
	[ ! -e typo3_src ] && ln -s ../Core typo3_src
	[ ! -e typo3 ] && ln -s typo3_src/typo3
	[ ! -e t3lib ] && ln -s typo3_src/t3lib
	[ ! -e index.php ] && ln -s typo3/index.php
	touch i.php

	if (( ${test_no_tests_flag:-0} == 1 )) ; then
		qprint "Preparation done"
	else
		qprint "Running the actual tests"
		cd $CWD
		$PHPUNIT --verbose --testsuite "${1}_all"
	fi
}

usage() {
	printf "%b" "

You're doing it wrong.

Usage

  run.sh [options] [version]

Options

  [version]                            - Supports "4.7", "6.0", "6.1" and "master" for now

  --extension=<name>                    - The extension which should be tested
  --quiet                               - Avoid too much output
  --no-tests                            - Prepare everything but do not trigger the tests
  --travis                              - Special setup for travis-ci builds which assume
                                          that we're within a checked out extension folder.
                                          To speed testing, this also uses the exisiting
                                          phpunit installation.      
  --db-(host|user|password|name)	- MySQL Database connection - needed in case you're
  					  running test with db-based fixtures.

  --install-extbase                     - Not implemented yet
  --install-fluid                       - Not implemented yet

"
}
cloneorupdate() {
	if [ ! -d $1 ] ; then
		git clone --recursive --quiet --branch $3 $2 $1
	else
		bash -c "cd $1 && git stash >/dev/null && git pull >/dev/null && git submodule update >/dev/null"
	fi
}

prepare_files() {
	
	if (( ${test_travis_flag:-0} == 1 )) ; then
		BASENAME=`basename "${1}"`
		cd ..
		mkdir -p "${1}/../${BASENAME}_/t3/typo3conf/ext"
		mv "./${BASENAME}" "${1}/../${BASENAME}_/t3/typo3conf/ext/${2}"
		mv "./${BASENAME}_" "./${BASENAME}"
		cd "./${BASENAME}"
	else
		mkdir -p "${1}/t3/typo3conf/ext"
	fi	
	

############################ phpunit.xml ##############################

		cat > "${1}/phpunit.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<phpunit backupGlobals="false" backupStaticAttributes="false" processIsolation="false"
		 stopOnFailure="false" syntaxCheck="true" bootstrap="autoload.php"
EOF

	if (( ${test_miau_flag:-0} == 1 )) ; then
		cat >> "${1}/phpunit.xml" <<EOF
		 colors="true"
		 printerFile="vendor/whatthejeff/nyancat-phpunit-resultprinter/src/NyanCat/PHPUnit/ResultPrinter.php"
		 printerClass="NyanCat\PHPunit\ResultPrinter"
EOF
	fi
cat >> "${1}/phpunit.xml" <<EOF
	><testsuites>
		<testsuite name="${2}_all">
			<directory suffix="Test.php">t3/typo3conf/ext/${2}/Tests/Unit</directory>
		</testsuite>
	</testsuites>
</phpunit>
EOF

##########################################################

	\curl -sSL https://raw.github.com/tolleiv/typo3-ext-ci/master/composer.json > "${1}/composer.json"
	\curl -sSL https://raw.github.com/tolleiv/typo3-ext-ci/master/LocalConfiguration.php > "${1}/t3/typo3conf/LocalConfiguration.php"
	\curl -sSL https://raw.github.com/tolleiv/typo3-ext-ci/master/localconf.php > "${1}/t3/typo3conf/localconf.php"

	case "$test_typo3_branch" in

		TYPO3_4-7|TYPO3_4-6|TYPO3_4-5)
				\curl -sSL https://raw.github.com/tolleiv/typo3-ext-ci/master/autoload_4.7.php > "${1}/autoload.php" ;;

		*)
				\curl -sSL https://raw.github.com/tolleiv/typo3-ext-ci/master/autoload.php > "${1}/autoload.php" ;;
	esac

	sed -i -e "s~###dbhost###~${test_db_host:=###path###/db.sqlite}~" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###dbhost###~${test_db_host}~" "${1}/t3/typo3conf/localconf.php"
	sed -i -e "s~###dbuser###~${test_db_user:=nothing}~" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###dbuser###~${test_db_user}~" "${1}/t3/typo3conf/localconf.php"
	sed -i -e "s~###dbpassword###~${test_db_password:=nothing}~" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###dbpassword###~${test_db_password}~" "${1}/t3/typo3conf/localconf.php"
	sed -i -e "s~###dbname###~${test_db_name:=nothing}~" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###dbname###~${test_db_name}~" "${1}/t3/typo3conf/localconf.php"

	sed -i -e "s~###path###~${1}~g" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###path###~${1}~g" "${1}/t3/typo3conf/localconf.php"
	sed -i -e "s~###path###~${1}~g" "${1}/autoload.php"
	sed -i -e "s~###ext###~${2}~g" "${1}/t3/typo3conf/LocalConfiguration.php"
	sed -i -e "s~###ext###~${2}~g" "${1}/t3/typo3conf/localconf.php"

##########################################################
}


# Parse CLI arguments.
while (( $# > 0 )) ; do
	token="${1#--}"
	shift
	case "$token" in
		extension=*)
			export "test_extension"="${token/extension=/}"
		;;

		no-tests|quiet|install-extbase|install-fluid|miau|travis)
			export "test_${token/-/_}_flag"=1
		;;
		db-host=*|db-user=*|db-password=*|db-name=*)
			K="${token/=.*/}"
			V="${token/db-(host|user|password|name)=/}
			export "test_${K/-/_}"=$V
		;;

		4.5|4.6|4.7|6.0|6.1)
			export "test_typo3_branch"="TYPO3_${token/\./-}"
		;;
		master)
			export "test_typo3_branch"="${token}"
		;;

		*)
			usage
			exit 1
		;;
	esac
done

run "$test_extension" "$test_typo3_branch"
