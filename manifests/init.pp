class rotating_rsync_backup (
  $ensure               = 'present',
  $source_repo          = 'https://github.com/whefter/rotating-rsync-backup.git',
  $source_revision      = 'master',
  $source_ensure        = 'present',
  $installpath          = '/usr/share/rotating-rsync-backup',
  $configpath           = '/etc/rotating-rsync-backup',
  $jobs                 = {},
  $declare_storeconfigs = false,
  $storeconfigs_tag     = $::fqdn,
) {
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
