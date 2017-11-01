class rotating_rsync_backup::install
{
  if !defined( Class['rotating_rsync_backup'] ) {
    fail( 'rotating_rsync_backup subclasses should not be declared on their own.' )
  }

  $ensure = $::rotating_rsync_backup::ensure ? {
    /(present|installed)/ => 'present',
    default               => 'absent',
  }

  vcsrepo { $::rotating_rsync_backup::installpath:
    ensure   => $ensure,
    provider => 'git',
    source   => $::rotating_rsync_backup::source_repo,
    revision => $::rotating_rsync_backup::source_revision,
    user     => 'root',
  }
}
