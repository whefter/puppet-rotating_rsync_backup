class rotating_rsync_backup (
  $ensure               = 'present',
  $source_repo          = $::rotating_rsync_backup::params::source_repo,
  $source_revision      = $::rotating_rsync_backup::params::source_revision,
  $installpath          = $::rotating_rsync_backup::params::installpath,
  $configpath           = $::rotating_rsync_backup::params::configpath,
  
  $jobs                 = {},
  $declare_storeconfigs = false,
  $storeconfigs_tag     = $::fqdn,
)
inherits ::rotating_rsync_backup::params
{
  $config_path_ensure = $ensure ? {
    /(present|installed)/ => 'directory',
    default               => 'absent',
  }

  class { 'rotating_rsync_backup::install':
  }

  file { $configpath:
    ensure => $config_path_ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  create_resources( rotating_rsync_backup::job, $jobs )

  if $declare_storeconfigs {
    Rotating_rsync_backup::Job <<| tag == $storeconfigs_tag |>>
  }
}
