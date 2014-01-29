<?php

class {#projectNamespace}_Registry extends EarthIT_Registry
{
	public function getDbAdapter() {
		if( $this->dbAdapter === null ) {
			$this->dbAdapter = Doctrine_DBAL_DriverManager::getConnection( $this->getConfig('dbc') );
		}
		return $this->dbAdapter;
	}
}
